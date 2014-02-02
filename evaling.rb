module Evaling
	def Evaling.eval(thing, context)
		if thing.respond_to? :eval
			thing.eval context
		else
			thing
		end
	end

	def Evaling.run(parse_tree)
		context = {
			"printFoo"	=> Primitives::Function.new {puts "foo"},
			"println"	=> Primitives::Function.new {|x| puts x.to_s}
		}

		Evaling.eval parse_tree, context

		context["main"].call context, []
	end
end
