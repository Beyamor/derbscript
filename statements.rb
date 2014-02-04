require_relative "primitives"
require_relative "evaling"
require_relative "environment"

module Statements
	class ProcDefinition
		def initialize(name, parameter_names, body)
			@name			= name
			@parameter_names	= parameter_names
			@body			= body
		end

		def eval(scope)
			scope[@name] = Primitives::Proc.new @parameter_names, @body, scope
		end
	end

	class ScopeDefinition
		def initialize(name, body)
			@name	= name
			@body	= body
		end

		def eval(parent_scope)
			scope = Environment::Scope.new parent_scope
			Evaling.eval @body, scope
			parent_scope[@name] = scope
		end
	end

	class SetVar
		def initialize(name, value)
			@name	= name
			@value	= value
		end

		def eval(scope)
			scope[@name] = Evaling.eval @value, scope
		end
	end

	class Block
		def initialize(statements)
			@statements = statements
		end

		def eval(scope)
			@statements.each {|s| Evaling.eval s, scope}
		end
	end
end
