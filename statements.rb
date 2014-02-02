module Statements
	class Proc
		def initialize(name, parameters, body)
			@name		= name
			@parameters	= body
			@body		= body
		end

		def to_s
			"Proc #{@name}"
		end
	end
end
