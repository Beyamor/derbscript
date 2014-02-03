require_relative "primitives"

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
end
