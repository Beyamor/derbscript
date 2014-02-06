require_relative "tokenizing"
require_relative "parsing"
require_relative "primitives"
require_relative "evaling"

contents	= File.read ARGV[0]
tokens		= Tokenizing.tokenize contents
parse_result	= Parsing.parse tokens
puts parse_result.to_s
Evaling.run parse_result
