require_relative "tokenizing"
require_relative "parsing"
require_relative "primitives"

context = {
	"printFoo"	=> Primitives::Function.new {puts "foo"}
}

contents	= File.read "scripts/hellofoo.derp"
tokens		= Tokenizing.tokenize contents
parse_result	= Parsing.parse tokens
parse_result.eval(context)
