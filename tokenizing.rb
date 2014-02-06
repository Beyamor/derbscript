module Tokenizing
	SPECIAL_SYMBOLS		= /\A(\(|\)|\[|\]|=|\{|\}|,)/
	OPERATORS		= /\A(\+|-|\*|\/)/
	WHITESPACE		= /\A(( |\t)+)/
	IDENTIFIER		= /\A([a-zA-Z_][a-zA-Z_0-9]*)/
	TERMINATOR		= /\A(\n|\r\n|\n\r)/
	NUMBER			= /\A([0-9]+(\.[0-9]+)?)/
	STRING			= /\A(".*?")/

	class Token
		attr_reader :type, :text

		def initialize(type, text)
			@type	= type
			@text	= text
		end

		def to_s
			if @text
				"#{@type}(#{@text})"
			else
				@type
			end
		end
	end

	def Tokenizing.tokenize(text)
		tokens	= []

		until text.empty?
			case text
			when WHITESPACE
				# Do nothing
				"do nothing"
			when SPECIAL_SYMBOLS
				symbol = $1
				token = Token.new symbol, nil
				tokens << token
			when OPERATORS
				operator = $1
				token = Token.new operator, nil
				tokens << token
			when IDENTIFIER
				name = $1
				token = Token.new :name, name
				tokens << token
			when TERMINATOR
				token = Token.new :terminator, nil
				tokens << token
			when NUMBER
				number = $1
				token = Token.new :number, number
				tokens << token
			when STRING
				string = $1
				contents = string[1...-1]
				token = Token.new :string, contents
				tokens << token

			else
				throw "Couldn't tokenize #{text}"
			end

			# Remove whatever was matched
			text.slice! 0...$1.length
		end

		final_token = Token.new :end, nil
		tokens << final_token
		return tokens
	end
end
