require_relative "primitives"

module Statements
	class ProcDefinition
		def initialize(name, parameter_names, body)
			@name	= name
			@proc	= Primitives::Proc.new parameter_names, body
		end

		def eval(context)
			context[@name] = @proc
		end
	end
end
