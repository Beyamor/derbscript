module Tokenizing
	SPECIAL_SYMBOLS	= ["=", ";", "(", ")", "{", "}", "\"", ","]
	WHITESPACE	= [" ", "\n", "\r", "\t"]

	def Tokenizing.tokenize(text)
		tokens	= []
		token	= nil

		push_token = lambda do
			if token
				tokens << token
				token = nil
			end
		end

		text.chars.each do |char|
			if SPECIAL_SYMBOLS.member? char
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
