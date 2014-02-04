require_relative "evaling"
require_relative "environment"

module Primitives
	class BlockFunction
		def initialize(&block)
			@block = block
		end

		def call(params)
			@block.call *params
		end
	end

	class Proc
		def initialize(param_names, body, parent_scope)
			@param_names	= param_names
			@body		= body
			@scope		= Environment::Scope.new parent_scope
		end

		def call(params)
			@param_names.zip(params).each do |name, param|
				@scope[name] = param
			end

			Evaling.eval @body, @scope
		end
	end

	class Literal
		attr_reader :value

		def initialize(value)
			@value = value
		end

		def eval(scope)
			@value
		end

		def to_s
			"#{@value.class.to_s}:#{@value}"
		end
	end
end
