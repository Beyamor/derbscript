module Statements
	class ProcDefinition
		def initialize(name, parameters, body)
			@name		= name
			@parameters	= body
			@body		= body
		end

		def eval(context)
			@body.each do |statement|
				statement.eval context
			end
		end
	end
end
