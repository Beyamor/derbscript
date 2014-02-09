require_relative "environment"
require_relative "statements"

module Evaling
	def Evaling.eval(thing, scope)
		stack = [thing]
		until stack.empty?
			thing = stack.pop
			puts "\n"
			puts thing
			case thing
			when Statements::Block
				thing.children.reverse.each {|child| stack.push child}
			else
				thing.eval scope
			end
		end
	end

	def Evaling.run(parse_tree)
		open_files = {}

		global_scope = Environment::Scope.new nil
		global_scope.define({
			"printFoo"	=> Primitives::BlockFunction.new {puts "foo"},
			"println"	=> Primitives::BlockFunction.new {|x| puts x},
			"open"		=> Primitives::BlockFunction.new {|which| open_files[which] = File.open which, "w"},
			"write"		=> Primitives::BlockFunction.new {|which, text| open_files[which].write text},
			"close"		=> Primitives::BlockFunction.new {|which| open_files[which].close},
			"readln"	=> Primitives::BlockFunction.new { $stdin.gets.chomp },
			"str"		=> Primitives::BlockFunction.new {|x| x.to_s }

		})

		Evaling.eval parse_tree, global_scope

		global_scope["main"].call []
	end
end
