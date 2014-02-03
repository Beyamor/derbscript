require_relative "environment"

module Evaling
	def Evaling.eval(thing, scope)
		thing.eval scope
	end

	def Evaling.run(parse_tree)
		open_files = {}

		global_scope			= Environment::Scope.new nil
		global_scope["printFoo"]	= Primitives::BlockFunction.new {puts "foo"}
		global_scope["println"]		= Primitives::BlockFunction.new {|x| puts x}
		global_scope["open"]		= Primitives::BlockFunction.new {|which| open_files[which] = File.open which, "w"}
		global_scope["write"]		= Primitives::BlockFunction.new {|which, text| open_files[which].write text}
		global_scope["close"]		= Primitives::BlockFunction.new {|which| open_files[which].close}
		global_scope["readln"]		= Primitives::BlockFunction.new { $stdin.gets.chomp }

		Evaling.eval parse_tree, global_scope

		global_scope["main"].call []
	end
end
