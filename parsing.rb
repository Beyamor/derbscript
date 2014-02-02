require_relative "statements"
require_relative "expressions"

module Parsing
	class Parser

		def try_parsing_identifier(tokens)
			name = tokens.shift
			throw :missing_identifier unless is_identifier name
			return name
		end

		def try_parsing_parameter_declaration(tokens)
			open_paren = tokens.shift
			throw :missing_open_paren unless open_paren == "("

			# TODO args
			while not tokens.empty? and tokens[0] != ")"
				tokens.shift
			end

			close_paren = tokens.shift
			throw :missing_close_paren unless close_paren == ")"

			return []
		end

		def try_parsing_call(tokens)
			name		= try_parsing_identifier tokens
			parameters	= try_parsing_parameter_declaration tokens

			return Expressions::Call.new name, parameters
		end

		def try_parsing_statement(tokens)
			call		= try_parsing_call tokens
			terminator	= tokens.shift
			throw :missing_semicolon unless terminator == ";"
			return call
		end

		def try_parsing_scope(tokens)
			open_scope = tokens.shift
			throw :missing_open_scope unless open_scope == "{"

			body = []
			while not tokens.empty? and tokens[0] != "}"
				statement = try_parsing_statement tokens
				body << statement
			end

			close_scope = tokens.shift
			throw :missing_close_scope unless close_scope == "}"

			return body
		end

		def try_parsing_proc(tokens)
			declaration = tokens.shift
			throw :missing_proc_declaration unless declaration and declaration == "proc"

			name		= try_parsing_identifier(tokens)
			parameters	= try_parsing_parameter_declaration(tokens)
			body		= try_parsing_scope(tokens)

			return Statements::ProcDefinition.new name, parameters, body
		end

		def is_identifier(name)
			/^[a-zA-Z_][a-zA-Z_0-9]*$/ =~ name
		end

		def parse(tokens)
			result, updated_tokens = try_parsing_proc tokens.dup
			throw :couldnt_parse unless result
			return result
		end
	end

	def Parsing.parse(tokens)
		Parsing::Parser.new.parse(tokens)
	end
end
