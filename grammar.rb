require_relative "parsing"

module Grammar
	class Grammar
		def initialize
			@infix_parselets	= {}
			@prefix_parselets	= {}
			@statement_transforms	= {}
		end

		def prefix(token_type)
			@prefix_parselets[token_type]
		end

		def infix(token_type)
			@infix_parselets[token_type]
		end

		def register_prefix(token_type, parselet)
			@prefix_parselets[token_type] = parselet
		end

		def register_infix(token_type, parselet)
			@infix_parselets[token_type] = parselet
		end

		def prefixes(prefixes)
			prefixes.each {|type, parselet| register_prefix type, parselet}
		end

		def infixes(infixes)
			infixes.each {|type, parselet| register_infix type, parselet}
		end

		def binary_operators(operators)
			operators.each {|type, precedence| register_infix type, Parsing::BinaryOperatorParselet.new(precedence)}
		end

		def register_statement(prefix, transform)
			@statement_transforms[prefix] = transform
		end

		def has_statement?(prefix)
			statement prefix
		end

		def statement(prefix)
			@statement_transforms[prefix]
		end

		def statements(statements)
			statements.each do |prefix, transform|
				register_statement(prefix, lambda do |parser|
					parser.expect_text prefix
					return transform.call parser
				end)
			end
		end

		def self.describe(description)
			grammar = Grammar.new
			description.each {|method, data| grammar.send method, data}
			return grammar
		end
	end
end
