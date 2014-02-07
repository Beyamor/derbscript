require_relative "tokenizing"
require_relative "primitives"
require_relative "evaling"
require_relative "ds"

contents	= File.read ARGV[0]
tokens		= Tokenizing.tokenize contents
parse_result	= DS.parse tokens
puts parse_result.to_s
Evaling.run parse_result
