require_relative "environment"
require_relative "statements"
require_relative "util"

module Evaling
	def Evaling.eval(thing, scope)
		stack	= Util::Stack.new thing
		loops	= Util::Stack.new

		until stack.empty?
			thing = stack.pop
			case thing
			when Statements::Block
				thing.statements.reverse.each do |statement|
					stack.push statement
				end
			when Statements::Loop
				if loops.peek != thing
					loops.push thing
				end

				stack.push thing
				stack.push thing.body
			when Statements::If
				if Evaling.eval thing.condition, scope
					stack.push thing.if_true
				else
					stack.push thing.if_false
				end
			when Statements::Break
				throw "No loop to break out of" if loops.empty?
				until thing == loops.peek
					thing = stack.pop
				end
				loops.pop
			else
				result = thing.eval scope
			end
		end
		return result
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
