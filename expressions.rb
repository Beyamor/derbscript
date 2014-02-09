require_relative "evaling"
require_relative "util"

module Expressions
	class Literal < Util::LanguageLeafNode
		attr_reader :value

		def initialize(value)
			@value = value
			super()
		end

		def eval(scope)
			@value
		end

		def to_s
			"#{@value.class.to_s}:#{@value}"
		end
	end

	class Identifier < Util::LanguageLeafNode
		attr_reader :name

		def initialize(name)
			*@scopes, @name = name.split ":"
			super()
		end

		def eval(scope)
			@scopes.each {|sub_scope| scope = scope[sub_scope]}
			scope[@name]
		end

		def to_s
			if @scopes.empty?
				@name
			else
				@scopes.join(":") + ":" + @name
			end
		end
	end

	class Call < Util::LanguageNode
		def initialize(name, params)
			@name	= name
			@params	= params
			super @name, *@params
		end

		def eval(scope)
			params = @params.map {|p| Evaling.eval p, scope}
			@name.eval(scope).call(params)
		end

		def to_s
			Util.sexpr "call", @name, *@params
		end
	end

	class StringExpression < Util::LanguageLeafNode
		def initialize(expressions)
			@expressions = expressions
			super()
		end

		def eval(scope)
			result = @expressions.map{|e| Evaling.eval e, scope}.join
		end

		def to_s
			Util.sexpr "str", *@expressions
		end
	end

	class OperatorCall < Util::LanguageLeafNode
		def initialize(operator, lhs, rhs)
			@operator	= operator
			@lhs		= lhs
			@rhs		= rhs
			super()
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

	class Assignment < Util::LanguageLeafNode
		def initialize(var, value)
			@var	= var
			@value	= value
			super()
		end

		def eval(scope)
			value = Evaling.eval @value, scope
			scope[@var] = value
			return value
		end

		def to_s
			Util.sexpr "set-number", @var, @value
		end
	end
end
