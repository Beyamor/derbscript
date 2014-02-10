require_relative "util"

module Expressions
	class ::Environment::Identifier
		def eval(evaluator, scope)
			resolve scope
		end
	end

	class Literal
		attr_reader :value

		def initialize(value)
			@value = value
		end

		def eval(evaluator, scope)
			@value
		end

		def to_s
			if String === @value
				"\"#{@value}\":#{@value.class.to_s}"
			else
				"#{@value}:#{@value.class.to_s}"
			end
		end
	end

	class Call
		def initialize(name, params)
			@name	= name
			@params	= params
		end

		def eval(evaluator, scope)
			params = @params.map {|p| evaluator.eval p, scope}
			@name.resolve(scope).call(evaluator, params)
		end

		def to_s
			Util.sexpr "call", @name, *@params
		end
	end

	class StringExpression
		def initialize(expressions)
			@expressions = expressions
		end

		def eval(evaluator, scope)
			result = @expressions.map{|e| evaluator.eval e, scope}.join
		end

		def to_s
			Util.sexpr "str", *@expressions
		end
	end

	class OperatorCall
		def initialize(operator, lhs, rhs)
			@operator	= operator
			@lhs		= lhs
			@rhs		= rhs
		end

		def eval(evaluator, scope)
			lhs = evaluator.eval @lhs, scope
			rhs = evaluator.eval @rhs, scope
			@operator.to_sym.to_proc.call lhs, rhs
		end

		def to_s
			Util.sexpr @operator, @lhs, @rhs
		end
	end

	class NumericAssignment
		def initialize(var, value)
			@var	= var
			@value	= value
		end

		def eval(evaluator, scope)
			scope.declare_var_if_missing @var, Float
			value = evaluator.eval @value, scope
			scope[@var] = value
			return value
		end

		def to_s
			Util.sexpr "set-number", @var, @value
		end
	end
end
