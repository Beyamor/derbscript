require_relative "statements"
require_relative "expressions"

module Parsing
	class Parser

		def parse_identifier(tokens)
			name = tokens.shift
			throw :missing_identifier unless is_identifier? name
			return name
		end

		def parse_paramter_list(tokens, param_parser)
			open_paren = tokens.shift
			throw :missing_open_paren unless open_paren == "("

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

			close_paren = tokens.shift
			throw :missing_close_paren unless close_paren == ")"

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
				return token
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

		def parse_statement(tokens)
			parse_any tokens, [:parse_expression]
		end

		def parse_block(tokens)
			open_scope = tokens.shift
			throw :missing_open_scope unless open_scope == "{"

			body = []
			while not tokens.empty? and tokens[0] != "}"
				statement = parse_statement tokens
				body << statement
			end

			close_scope = tokens.shift
			throw :missing_close_scope unless close_scope == "}"

			return body
		end

		def parse_proc(tokens)
			declaration = tokens.shift
			throw :missing_proc_declaration unless declaration and declaration == "proc"

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
