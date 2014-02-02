require_relative "tokenizing.rb"
require_relative "parsing"

contents	= File.read "scripts/main.derp"
tokens		= Tokenizing.tokenize contents
parse_result	= Parsing.parse tokens
puts parse_result
