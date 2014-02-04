require_relative "evaling"

module Expressions
	class Identifier
		attr_reader :name

		def initialize(name)
			*@scopes, @name = name.split ":"
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

	class Call
		def initialize(name, params)
			@name	= name
			@params	= params
		end

		def eval(scope)
			@params.map! {|p| Evaling.eval p, scope}
			@name.eval(scope).call(@params)
		end
	end

	class StringExpression
		def initialize(expressions)
			@expressions = expressions
		end

		def eval(scope)
			result = @expressions.map{|e| Evaling.eval e, scope}.join
		end
	end
end
