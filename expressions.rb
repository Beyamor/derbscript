require_relative "evaling"
require_relative "util"

module Expressions
	class ResolveVar
		attr_accessor :identifier

		def initialize(identifier)
			@identifier = identifier
		end
		
		def eval(scope)
			@identifier.resolve(scope).value
		end

		def to_s
			Util.sexpr "resolve", @identifier
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
			if String === @value
				"\"#{@value}\":#{@value.class.to_s}"
			else
				"#{@value}:#{@value.class.to_s}"
			end
		end
	end

	class Call
		def initialize(name, params)
			@name	= name.identifier # Ugh. HACK: need to grab the identifier from previously parsed resolution
			@params	= params
		end

		def eval(scope)
			params = @params.map {|p| Evaling.eval p, scope}
			@name.resolve(scope).call(params)
		end

		def to_s
			Util.sexpr "call", @name, *@params
		end
	end

	class StringExpression
		def initialize(expressions)
			@expressions = expressions
		end

		def eval(scope)
			result = @expressions.map{|e| Evaling.eval e, scope}.join
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

		def eval(scope)
			lhs = Evaling.eval @lhs, scope
			rhs = Evaling.eval @rhs, scope
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

		def eval(scope)
			scope.declare_var_if_missing @var, Float
			value = Evaling.eval @value, scope
			scope[@var].value = value
			return value
		end

		def to_s
			Util.sexpr "set-number", @var, @value
		end
	end
end
