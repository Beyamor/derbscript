require_relative "statements"
require_relative "expressions"

module Parsing
	PRECEDENCES = {
		"ADDITION"		=> 3,
		"SUBTRACTION"		=> 3,
		"MULTIPLICATION"	=> 4,
		"PREFIX"		=> 7
	}

	class Expression
		def initialize(name, *children)
			@name		= name
			@children	= children
		end

		def to_s
			s = "(#{@name}"
			@children.each {|child| s += " " + child.to_s}
			s += ")"
			return s
		end
	end

	class IdentifierExpression
		def initialize(name)
			@name = name
		end

		def to_s
			@name
		end
	end

	class IdentifierParslet
		def parse(parser, token)
			IdentifierExpression.new token.text
		end
	end

	class PrefixOperatorParslet
		def parse(parser, token)
			operand = parser.parse_expression PRECEDENCES["PREFIX"]
			return Expression.new token.type, operand
		end
	end

	class BinaryOperatorParselet
		attr_reader :precedence

		def initialize(precedence)
			@precedence = precedence
		end

		def parse(parser, left, token)
			right = parser.parse_expression @precedence
			return Expression.new token.type, left, right
		end
	end

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

		def at_end?
			@position >= @tokens.length
		end

		def token
			@tokens[@position]
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

		def current_precedence
			parselet = @infix_parselets[@cursor.token.type]

			if parselet
				parselet.precedence
			else
				0
			end
		end

		def parse_expression(min_precedence)
			token	= @cursor.shift
			prefix	= @prefix_parselets[token.type]
			throw "Could not parse #{token.text}" unless prefix

			left = prefix.parse self, token
			while min_precedence < current_precedence
				token	= @cursor.shift
				infix	= @infix_parselets[token.type]
				left	= infix.parse self, left, token
			end

			return left
		end

		def parse(tokens)
			@cursor = Cursor.new tokens
			parse_expression 0
		end
	end

	PARSER = Parser.new
	PARSER.register_prefix :identifier, IdentifierParslet.new
	PARSER.prefixes :+, :-
		[
			[:+, "ADDITION"],
			[:-, "SUBTRACTION"],
			[:*, "MULTIPLICATION"]
	].each do |symbol, precedence|
		PARSER.register_infix symbol, BinaryOperatorParselet.new(PRECEDENCES[precedence])
	end

	def Parsing.parse(tokens)
		PARSER.parse tokens
	end
end
