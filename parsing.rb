require_relative "statements"
require_relative "expressions"

module Parsing
	IDENTIFIER_PATTERN	= /^[a-zA-Z_][a-zA-Z_0-9]*(:[a-zA-Z_][a-zA-Z_0-9]*)*$/
	STRING_PATTERN		= /^".*"$/
	NUMBER_PATTERN		= /^-?\d+(\.\d+)?$/
	OPERATORS		= ["==", "!=", ">", ">=", "<", "<="]

	class Cursor
		attr_reader :position

		def initialize(tokens, position=0)
			@tokens		= tokens
			@position	= position
		end

		def [](value)
			@tokens[@position + value]
		end

		def shift
			value = @tokens[@position]
			@position += 1
			return value
		end

		def empty?
			@position >= @tokens.length
		end

		def dup
			Cursor.new @tokens, @position
		end

		def to_s
			@tokens[@position..-1].to_s
		end

		def length
			@tokens.length - @position
		end

		def move_to(other)
			@position = other.position
		end
	end

	class Parser
		def is_identifier?(name)
			 IDENTIFIER_PATTERN =~ name
		end

		def is_string?(token)
			 STRING_PATTERN =~ token
		end

		def is_number?(token)
			NUMBER_PATTERN =~ token
		end

		def expect(expectation, cursor)
			actual	= cursor.shift
			throw "#{actual} isn't #{expectation}" unless actual == expectation
		end

		def parse_identifier(cursor)
			name = cursor.shift
			throw :missing_identifier unless is_identifier? name
			return Expressions::Identifier.new name
		end

		def parse_paramter_list(cursor, param_parser)
			expect "(", cursor

			result = []
			while not cursor.empty? and cursor[0] != ")"
				param = send param_parser, cursor
				result << param

				if cursor[0] == ","
					cursor.shift
				elsif cursor[0] != ")"
					throw :malformed_parameter_declarations
				end
			end

			expect ")", cursor

			return result
		end

		def parse_type(cursor)
			type = cursor.shift
			if ["Number", "String"].member? type
				return type
			else
				throw "Unknown type #{type}"
			end
		end

		def parse_param_declartation(cursor)
			type		= parse_type cursor
			identifier	= parse_identifier cursor	
			return identifier
		end

		def parse_parameter_declarations(cursor)
			return parse_paramter_list cursor, :parse_param_declartation
		end

		def parse_call_parameters(cursor)
			return parse_paramter_list cursor, :parse_expression
		end

		def parse_call(cursor)
			name		= parse_identifier cursor
			parameters	= parse_call_parameters cursor

			return Expressions::Call.new name, parameters
		end

		def parse_string_literal(cursor)
			token = cursor.shift
			if is_string? token
				return Primitives::Literal.new token[1...-1]
			else
				throw :couldnt_parse_string
			end
		end

		def parse_number_literal(cursor)
			token = cursor.shift
			if is_number? token
				return Primitives::Literal.new token.to_f
			else
				throw :couldnt_parse_number
			end
		end

		def parse_literal(cursor)
			parse_any cursor, [:parse_string_literal, :parse_number_literal]
		end

		def parse_any(original_cursor, parses)
			until parses.empty?
				parse = parses.shift

				begin
					working_cursor	= original_cursor.dup
					result		= send parse, working_cursor

					original_cursor.move_to working_cursor
					return result

				rescue Object => e
					throw e if parses.empty?
				end
			end
		end

		def parse_string_expression(cursor)
			expect "[", cursor
			expression = parse_expression cursor
			expect "]", cursor
			return expression
		end

		def parse_string(cursor)
			first_expr	= parse_any cursor, [:parse_string_literal, :parse_string_expression]
			exprs		= [first_expr]

			while true
				begin
					expr = parse_any cursor, [:parse_literal, :parse_string_expression]
					exprs << expr
				rescue => e
					break
				end
			end

			return Expressions::StringExpression.new exprs
		end

		def parse_body(cursor)
			body = []
			while not cursor.empty? and cursor[0] != "}"
				statement = parse_statement cursor
				body << statement
			end
			return Statements::Block.new body
		end

		def parse_block(cursor)
			expect "{", cursor
			body = parse_body cursor
			expect "}", cursor
			return body
		end

		def parse_operator(cursor)
			token = cursor.shift
			if OPERATORS.member? token
				return token
			else
				throw "Unknown operator #{token}"
			end
		end

		def parse_operator_usage(cursor)
			lhs		= parse_sub_expression cursor
			operator	= parse_operator cursor
			rhs		= parse_sub_expression cursor
			return Expressions::OperatorCall.new operator, lhs, rhs
		end

		def parse_sub_expression(cursor)
			parse_any cursor, [
				:parse_call,
				:parse_string,
				:parse_literal,
				:parse_identifier
			]
		end

		def parse_expression(cursor)
			parse_any cursor, [
				:parse_operator_usage,
				:parse_sub_expression
			]
		end

		def parse_set_var(cursor)
			expect "set", cursor
			name	= parse_identifier cursor
			value	= parse_expression cursor
			return Statements::SetVar.new name, value
		end

		def parse_block_or_statement(cursor)
			parse_any cursor, [:parse_statement, :parse_block]
		end

		def parse_if(cursor)
			expect "if", cursor
			expect "(", cursor
			condition = parse_expression cursor
			expect ")", cursor
			if_true = parse_block_or_statement cursor
			expect "else", cursor
			if_false = parse_block_or_statement cursor
			return Statements::If.new condition, if_true, if_false
		end

		def parse_statement(cursor)
			parse_any cursor, [
				:parse_scope_definition,
				:parse_proc_definition,
				:parse_set_var,
				:parse_if,
				:parse_expression
			]
		end

		def parse_proc_definition(cursor)
			expect "proc", cursor

			name		= parse_identifier cursor
			parameters	= parse_parameter_declarations cursor
			body		= parse_block cursor

			return Statements::ProcDefinition.new name, parameters, body
		end

		def parse_scope_definition(cursor)
			expect "scope", cursor
			name	= parse_identifier cursor
			body	= parse_block cursor
			return Statements::ScopeDefinition.new name, body
		end

		def parse(tokens)
			cursor = Cursor.new tokens
			begin
				parse_body cursor
			rescue => e
				puts cursor.to_s
				throw e
			end
		end
	end

	def Parsing.parse(cursor)
		Parsing::Parser.new.parse(cursor)
	end
end
