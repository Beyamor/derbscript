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

	class Func
		def initialize(param_names, body, parent_scope)
			@parent_scope	= parent_scope
			@param_names	= param_names
			@body		= body
		end

		def call(params)
			scope = Environment::Scope.new @parent_scope
			@param_names.zip(params).each do |name, param|
				scope[name] = param
			end

			Evaling.eval @body, scope
		end
	end

	class Proc
		def initialize(param_names, body, parent_scope)
			@parent_scope	= parent_scope
			@param_names	= param_names
			@body		= body
		end

		def call(params)
			scope = Environment::Scope.new @parent_scope
			@param_names.zip(params).each do |name, param|
				scope[name] = param
			end

			Evaling.eval @body, scope
		end
	end
end
