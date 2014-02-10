require_relative "environment"

module Primitives
	class BlockFunction
		def initialize(&block)
			@block = block
		end

		def call(evaluator, params)
			@block.call *params
		end
	end

	class ParamDefinition
		attr_accessor :name, :type

		def initialize(name, type)
			@name	= name
			@type	= type
		end

		def to_s
			"#{@name}:#{@type}"
		end
	end

	class Func
		def initialize(param_defs, return_type, body, parent_scope)
			@parent_scope	= parent_scope
			@param_defs	= param_defs
			@body		= body
			@return_type	= return_type
		end

		def call(evaluator, params)
			scope = Environment::Scope.new @parent_scope
			@param_defs.zip(params).each do |param_def, param|
				scope.declare_var param_def.name, param_def.type
				scope[param_def.name] = param
			end

			result = evaluator.eval @body, scope
			throw "Returned value #{result}:#{result.class} is not a #{@return_type}" unless result.is_a? @return_type
			return result
		end
	end

	class Proc
		def initialize(param_defs, body, parent_scope)
			@parent_scope	= parent_scope
			@param_defs	= param_defs
			@body		= body
		end

		def call(evaluator, params)
			scope = Environment::Scope.new @parent_scope
			@param_defs.zip(params).each do |param_def, param|
				scope.declare_var param_def.name, param_def.type
				scope[name].value = param
			end

			evaluator.eval @body, scope
		end
	end
end
