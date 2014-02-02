require_relative "tokenizing"
require_relative "parsing"
require_relative "primitives"
require_relative "evaling"

contents	= File.read "scripts/helloworld.derp"
tokens		= Tokenizing.tokenize contents
parse_result	= Parsing.parse tokens
Evaling.run parse_result
