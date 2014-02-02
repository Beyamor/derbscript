module Tokenizing
	SPECIAL_SYMBOLS		= ["=", ";", "(", ")", "{", "}", "\"", ","]
	WHITESPACE		= [" ", "\n", "\r", "\t"]

	def Tokenizing.tokenize(text)
		tokens	= []
		token	= nil

		push_token = lambda do
			if token
				tokens << token
				token = nil
			end
		end

		text = text.chars.to_a
		until text.empty?
			char = text.shift

			if char == "\""
				push_token.call
				token = "\""
				while true
					throw :missing_string_terminator if text.empty?
					char = text.shift
					break if char == "\""
					token << char
				end
				token << "\""
				push_token.call

			elsif SPECIAL_SYMBOLS.member? char
				push_token.call
				token = char
				push_token.call

			elsif WHITESPACE.member? char
				push_token.call

			else
				token ||= ""
				token << char
			end
		end

		return tokens
	end
end
