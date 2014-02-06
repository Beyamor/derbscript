require_relative "statements"
require_relative "expressions"

module Parsing
	PRECEDENCES = {
		"+"		=> 3,
		"-"		=> 3,
		"*"		=> 4,
		"\\"		=> 4,
		"PREFIX"	=> 7,
		"CALL"		=> 10
	}

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

	class NameParslet
		def parse(parser, token)
			Expressions::Identifier.new token.text
		end
	end

	class ParensParslet
		def parse(parser, token)
			expression = parser.parse_expression
			parser.expect ")"
			return expression
		end
	end

	class PrefixOperatorParslet
		def parse(parser, token)
			operand = parser.parse_expression PRECEDENCES["PREFIX"]
			throw "Whoa, haven't implemented prefix operators yet"
		end
	end

	class BinaryOperatorParselet
		attr_reader :precedence

		def initialize(precedence)
			@precedence = precedence
		end

		def parse(parser, left, token)
			right = parser.parse_expression @precedence
			return Expressions::OperatorCall.new token.type, left, right
		end
	end

	class CallParselet
		def precedence
			PRECEDENCES["CALL"]
		end

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

	class Parser		
		def initialize
			@prefix_parselets	= {}
			@infix_parselets	= {}
		end

		def register_prefix(token_type, prefix_parselet)
			@prefix_parselets[token_type] = prefix_parselet
		end

		def register_infix(token_type, infix_parselet)
			@infix_parselets[token_type] = infix_parselet
		end

		def prefix(token_type)
			register_prefix token_type, PrefixOperatorParslet.new
		end

		def prefixes(*token_types)
			token_types.each {|token_type| prefix token_type}
		end

		def next_token
			@tokens[0]
		end

		def next_precedence
			parselet = @infix_parselets[next_token.type]

			if parselet
				parselet.precedence
			else
				0
			end
		end

		def parse_expression(min_precedence=0)
			token	= @tokens.shift
			prefix	= @prefix_parselets[token.type]
			throw "Could not parse #{token.type}:#{token.text}" unless prefix

			left = prefix.parse self, token
			while min_precedence < next_precedence
				token	= @tokens.shift
				infix	= @infix_parselets[token.type]
				left	= infix.parse self, left, token
			end

			return left
		end

		def parse_statement
			parse_expression
		end

		def parse_program
			statements = []
			while true
				while next_token.type == :terminator
					@tokens.shift
				end

				if @tokens.empty? or next_token.type == :end
					break
				end

				statement = parse_statement
				statements << statement
			end
			return Statements::Block.new statements
		end

		def parse(tokens)
			@tokens = tokens
			parse_program
		end

		def expect(token_type)
			token = @tokens.shift
			throw "Expected #{token_type} but got #{token.type}" unless token.type == token_type
		end	
	end

	PARSER = Parser.new
	PARSER.register_prefix :name, NameParslet.new
	PARSER.register_prefix :string, StringParslet.new
	PARSER.register_prefix :number, NumberParslet.new
	PARSER.register_prefix "(", ParensParslet.new
	PARSER.prefixes "+", "-"
	["+", "-", "*", "\\"].each do |operator|
		PARSER.register_infix operator, BinaryOperatorParselet.new(PRECEDENCES[operator])
	end
	PARSER.register_infix "(", CallParselet.new

	def Parsing.parse(tokens)
		PARSER.parse tokens
	end
end
