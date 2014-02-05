module Tokenizing
	SPECIAL_SYMBOLS		= ["=", ";", "(", ")", "{", "}", "\"", ",", "[", "]"]
	OPERATORS		= ["+", "-", "*", "\\"]
	WHITESPACE		= [" ", "\n", "\r", "\t"]

	class Token
		attr_reader :type, :text

		def initialize(type, text)
			@type	= type
			@text	= text
		end
	end

	def Tokenizing.tokenize(text)
		tokens	= []
		token	= nil

		push_token = lambda do |type|
			if token
				token_text = token
				token = Token.new type, token_text
				tokens << token
				token = nil
			end
		end

		text = text.chars.to_a
		until text.empty?
			char = text.shift

			if char == "\""
				push_token.call :identifier
				token = "\""
				while true
					throw :missing_string_terminator if text.empty?
					char = text.shift
					break if char == "\""
					token << char
				end
				token << "\""
				push_token.call :string

			elsif char == "@"
				while char != "\n"
					char = text.shift
				end

			elsif SPECIAL_SYMBOLS.member? char or OPERATORS.member? char
				push_token.call :identifier
				token = char
				push_token.call char.to_sym

			elsif WHITESPACE.member? char
				push_token.call :identifier

			else
				token ||= ""
				token << char
			end
		end

		push_token.call :identifier
		final_token = Token.new :end, nil
		tokens << final_token

		return tokens
	end
end
