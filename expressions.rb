module Expressions
	class Call
		def initialize(name, parameters)
			@name	= name
		end

		def eval(context)
			context[@name].call([]) #TODO pass params
		end
	end
end
