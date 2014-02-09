require_relative "statements"
require_relative "expressions"
require_relative "primitives"
require_relative "environment"

module Parsing
	class NumberParslet
		def parse(parser, token)
			Expressions::Literal.new token.text.to_f
		end
	end

	class StringParslet
		def parse(parser, token)
			Expressions::Literal.new token.text
		end
	end

	class ResolveVarParslet
		def parse(parser, token)
			Expressions::ResolveVar.new Environment::Identifier.new token.text
		end
	end

	class ParensParslet
		def parse(parser, token)
			expression = parser.parse_expression
			parser.expect ")"
			return expression
		end
	end

	module Infix
		attr_reader :precedence
		def initialize(precedence)
			@precedence = precedence
		end
	end

	class BinaryOperatorParselet
		include Infix

		def parse(parser, left, token)
			right = parser.parse_expression @precedence
			return Expressions::OperatorCall.new token.type, left, right
		end
	end

	class CallParselet
		include Infix

		def parse(parser, name, token)
			arguments = []
			while parser.next_token.type != ")"
				argument = parser.parse_expression
				arguments << argument
				if parser.next_token.type != ")"
					parser.expect ","
				end
			end
			parser.expect ")"
			return Expressions::Call.new name, arguments
		end
	end

	class NumericAssignmentParselet
		include Infix

		def parse(parser, var, token)
			value = parser.parse_expression
			return Expressions::NumericAssignment.new var, value
		end
	end

	class Parser		
		attr_accessor :type_map

		def initialize(grammar)
			@grammar = grammar
		end

		def next_token
			@tokens[0]
		end

		def next_precedence
			parselet = @grammar.infix next_token.type

			if parselet
				parselet.precedence
			else
				0
			end
		end

		def parse_precedence_expression(min_precedence=0)
			token	= @tokens.shift
			prefix	= @grammar.prefix token.type
			throw "Could not parse #{token.type}:#{token.text}" unless prefix

			left = prefix.parse self, token
			while min_precedence < next_precedence
				token	= @tokens.shift
				infix	= @grammar.infix token.type
				left	= infix.parse self, left, token
			end

			return left
		end

		def parse_string_literal
			token = @tokens.shift
			return Expressions::Literal.new token.text
		end

		def parse_string_interpolation
			expect "["
			expression = parse_expression
			expect "]"
			return expression
		end

		def parse_string_expression
			expressions = []
			
			while true
				if next_token.type == :string
					expressions << parse_string_literal
				elsif next_token.type == "["
					expressions << parse_string_interpolation
				else
					break
				end
			end

			return Expressions::StringExpression.new expressions
		end

		def parse_expression(min_precedence=0)
			if next_token.type == :string or next_token.type == "["
				parse_string_expression
			else
				parse_precedence_expression(min_precedence)
			end
		end

		def parse_block_body
			statements = []
			while true
				devour_terminators
				if @tokens.empty? or next_token.type == :end or next_token.type == "}"
					break
				end

				statement = parse_statement
				statements << statement
			end
			return Statements::Block.new statements
		end

		def parse_block
			expect "{"
			body = parse_block_body
			expect "}"
			return body
		end

		def parse_name
			token = @tokens.shift
			throw "#{token} isnt name" unless token.type == :name
			return Environment::Identifier.new token.text
		end

		def parse_unqualified_name
			name = parse_name
			throw "Unexpected qualified name #{name}" if name.is_qualified?
			return name
		end

		def parse_var
			return Expressions::ResolveVar.new parse_name
		end

		def devour_terminators
			while next_token.type == :terminator
				@tokens.shift
			end
		end

		def parse_type
			token = @tokens.shift
			throw "Unknown type #{token}" unless @type_map.member? token.text
			type = @type_map[token.text]
			return type
		end

		def parse_params_definition
			params = []
			expect "("
			devour_terminators
			until next_token.type == ")"
				type	= parse_type
				name	= parse_name
				param	= Primitives::ParamDefinition.new name, type
				params << param
				if next_token.type != ")"
					expect ","
				end
				devour_terminators
			end
			expect ")"
			return params
		end

		def parse_statement
			if @grammar.has_statement? next_token.text
				@grammar.statement(next_token.text).call self
			else
				expression = parse_expression
				expect :terminator
				return expression
			end
		end

		def parse_block_or_statement
			if next_token.type == "{"
				parse_block
			else
				parse_statement
			end
		end

		def parse_program
			parse_block_body
		end

		def parse(tokens)
			@tokens = tokens
			parse_program
		end

		def expect(token_type)
			devour_terminators unless token_type == :terminator
			token = @tokens.shift
			throw "Expected #{token_type} but got #{token.type}" unless token.type == token_type
		end	

		def expect_text(text)
			token = @tokens.shift
			throw "Expected #{text} but got #{token.text}" unless token.text == text
		end
	end
end
