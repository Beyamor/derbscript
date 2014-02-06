require_relative "statements"
require_relative "expressions"

module Parsing
	PRECEDENCES = {
		:+		=> 3,
		:-		=> 3,
		:*		=> 4,
		"\\".to_sym	=> 4,
		"PREFIX"	=> 7,
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

	class NameExpression
		def initialize(name)
			@name = name
		end

		def to_s
			@name
		end
	end

	class NameParslet
		def parse(parser, token)
			NameExpression.new token.text
		end
	end

	class ParensParslet
		def parse(parser, token)
			expression = parser.parse_expression
			parser.expect :close_paren
			return expression
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
			puts "parsing binary operator #{token.type}"
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
		attr_reader :cursor

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

		def parse_expression(min_precedence=0)
			token	= @cursor.shift
			puts "#{token}"
			prefix	= @prefix_parselets[token.type]
			throw "Could not parse #{token.type}:#{token.text}" unless prefix

			left = prefix.parse self, token
			while min_precedence < current_precedence
				token	= @cursor.shift
				puts "	#{token}"
				infix	= @infix_parselets[token.type]
				left	= infix.parse self, left, token
			end

			return left
		end

		def parse(tokens)
			@cursor = Cursor.new tokens
			parse_expression
		end

		def expect(token_type)
			token = @cursor.shift
			throw "Expected #{token_type} but got #{token.type}" unless token.type == token_type
		end	
	end

	PARSER = Parser.new
	PARSER.register_prefix :name, NameParslet.new
	PARSER.register_prefix :open_paren, ParensParslet.new
	PARSER.prefixes :+, :-
	[:+, :-, :*, "\\".to_sym].each do |operator|
		PARSER.register_infix operator, BinaryOperatorParselet.new(PRECEDENCES[operator])
	end

	def Parsing.parse(tokens)
		PARSER.parse tokens
	end
end
