require_relative "statements.rb"

module Parsing
	class Parser
		def try_parsing_parameter_declaration(tokens)
			open_paren = tokens.shift
			throw :missing_open_paren unless open_paren == "("

			# TODO args

			close_paren = tokens.shift
			throw :missing_close_paren unless close_paren == ")"
		end

		def try_parsing_scope(tokens)
			open_scope = tokens.shift
			throw :missing_open_scope unless open_scope == "{"

			# TODO body
			
			close_scope = tokens.shift
			throw :missing_close_scope unless close_scope == "}"
		end

		def try_parsing_proc(tokens)
			declaration = tokens.shift
			throw :missing_proc_declaration unless declaration and declaration == "proc"

			name = tokens.shift
			throw :missing_proc_name unless is_identifier name

			parameters	= try_parsing_parameter_declaration(tokens)
			body		= try_parsing_scope(tokens)

			return [Statements::Proc.new(name, parameters, body), tokens]
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
