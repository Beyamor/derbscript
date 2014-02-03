require_relative "statements"
require_relative "expressions"

module Parsing
	class Parser
		def expect(expectation, tokens)
			actual	= tokens.shift
			throw "#{actual} isn't #{expectation}" unless actual == expectation
		end

		def parse_identifier(tokens)
			name = tokens.shift
			throw :missing_identifier unless is_identifier? name
			return Expressions::Identifier.new name
		end

		def parse_paramter_list(tokens, param_parser)
			expect "(", tokens

			result = []
			while not tokens.empty? and tokens[0] != ")"
				param = send param_parser, tokens
				result << param

				if tokens[0] == ","
					tokens.shift
				elsif tokens[0] != ")"
					throw :malformed_parameter_declaration
				end
			end

			expect ")", tokens

			return result
		end

		def parse_parameter_declaration(tokens)
			return parse_paramter_list tokens, :parse_identifier
		end

		def parse_call_parameters(tokens)
			return parse_paramter_list tokens, :parse_expression
		end

		def parse_call(tokens)
			name		= parse_identifier tokens
			parameters	= parse_call_parameters tokens
			
			return Expressions::Call.new name, parameters
		end

		def parse_literal(tokens)
			token = tokens.shift

			if is_string? token
				return Primitives::Literal.new token
			else
				throw :couldnt_parse_literal
			end
		end

		def parse_any(original_tokens, parses)
			until parses.empty?
				parse = parses.shift

				begin
					working_tokens	= original_tokens.dup
					result		= send parse, working_tokens

					# At this point, we've succeeded,
					# so destructively consume the actual token stream
					while working_tokens.length < original_tokens.length
						original_tokens.shift
					end

					return result

				rescue Object => e
					throw e if parses.empty?
				end
			end
		end

		def parse_expression(tokens)
			parse_any tokens, [:parse_call, :parse_literal, :parse_identifier]
		end

		def parse_set_var(tokens)
			expect "set", tokens
			name	= parse_identifier tokens
			value	= parse_expression tokens
			return Statements::SetVar.new name, value
		end

		def parse_statement(tokens)
			parse_any tokens, [:parse_set_var, :parse_expression]
		end

		def parse_block(tokens)
			expect "{", tokens

			body = []
			while not tokens.empty? and tokens[0] != "}"
				statement = parse_statement tokens
				body << statement
			end

			expect "}", tokens

			return body
		end

		def parse_proc(tokens)
			expect "proc", tokens

			name		= parse_identifier(tokens)
			parameters	= parse_parameter_declaration(tokens)
			body		= parse_block(tokens)

			return Statements::ProcDefinition.new name, parameters, body
		end

		def is_identifier?(name)
			/^[a-zA-Z_][a-zA-Z_0-9]*$/ =~ name
		end

		def is_string?(token)
			/^".*"$/ =~ token
		end

		def parse(tokens)
			result, updated_tokens = parse_proc tokens.dup
			throw :couldnt_parse unless result
			return result
		end
	end

	def Parsing.parse(tokens)
		Parsing::Parser.new.parse(tokens)
	end
end
