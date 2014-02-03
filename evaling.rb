require_relative "environment"

module Evaling
	def Evaling.eval(thing, scope)
		thing.eval scope
	end

	def Evaling.run(parse_tree)
		global_scope			= Environment::Scope.new nil
		global_scope["printFoo"]	= Primitives::BlockFunction.new {puts "foo"}
		global_scope["println"]		= Primitives::BlockFunction.new {|x| puts x.to_s}

		Evaling.eval parse_tree, global_scope

		global_scope["main"].call []
	end
end
