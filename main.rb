require_relative "tokenizing"
require_relative "parsing"
require_relative "primitives"

context = {
	"printFoo"	=> Primitives::Function.new {puts "foo"},
	"println"	=> Primitives::Function.new {|x| puts x.to_s}
}

contents	= File.read "scripts/helloworld.derp"
tokens		= Tokenizing.tokenize contents
parse_result	= Parsing.parse tokens
parse_result.eval(context)
