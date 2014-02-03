require_relative "primitives"
require_relative "evaling"

module Statements
	class ProcDefinition
		def initialize(name, parameter_names, body)
			@name			= name
			@parameter_names	= parameter_names
			@body			= body
		end

		def eval(scope)
			scope[@name] = Primitives::Proc.new @parameter_names, @body, scope
		end
	end

	class SetVar
		def initialize(name, value)
			@name	= name
			@value	= value
		end

		def eval(scope)
			scope[@name] = Evaling.eval @value, scope
		end
	end
end
