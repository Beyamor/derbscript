class String
	def remove_prefix!(prefix)
		slice! 0...prefix.length
		return self
	end
end

module Tokenizing
	SPECIAL_SYMBOLS		= /^(\(|\)|\[|\]|=|\{|\}|,)/
	OPERATORS		= /^(\+|-|\*|\/)/
	WHITESPACE		= /^(( |\t)+)/
	IDENTIFIER		= /^([a-zA-Z_][a-zA-Z_0-9]*)/
	TERMINATOR		= /^(\n|\r\n|\n\r)/

	class Token
		attr_reader :type, :text

		def initialize(type, text)
			@type	= type
			@text	= text
		end

		def to_s
			"#{type}(#{text})"
		end
	end

	def Tokenizing.tokenize(text)
		tokens	= []

		until text.empty?
			case text
			when WHITESPACE
				text.remove_prefix! $1
			when SPECIAL_SYMBOLS
				symbol = $1
				text.remove_prefix! symbol
				token = Token.new symbol, nil
				tokens << token
			when OPERATORS
				operator = $1
				text.remove_prefix! operator
				token = Token.new operator, nil
				tokens << token
			when IDENTIFIER
				name = $1
				text.remove_prefix! name
				token = Token.new :name, name
				tokens << token
			when TERMINATOR
				text.remove_prefix! $1
				token = Token.new :terminator, nil
				tokens << token
			else
				throw "Couldn't tokenize #{text}"
			end
		end

		final_token = Token.new :end, nil
		tokens << final_token
		return tokens
	end
end
