require_relative "evaling"

module Expressions
	class Identifier
		attr_reader :name

		def initialize(name)
			@name = name
		end

		def eval(scope)
			scope[@name]
		end
	end

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
