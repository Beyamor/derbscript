require_relative "evaling"

module Expressions
	class Call
		def initialize(name, params)
			@name	= name
			@params	= params
		end

		def eval(scope)
			@params.map! {|p| Evaling.eval p, scope}
			scope[@name].call(@params)
		end
	end
end
