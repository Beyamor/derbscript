require_relative "evaling"

module Expressions
	class Call
		def initialize(name, params)
			@name	= name
			@params	= params
		end

		def eval(context)
			@params.map! {|p| Evaling.eval p, context}
			context[@name].call(context, @params)
		end
	end
end
