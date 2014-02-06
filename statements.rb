require_relative "primitives"
require_relative "evaling"
require_relative "environment"
require_relative "util"

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

		def to_s
			Util.sexpr "def-proc", @name, @parameter_names, *@body
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

		def to_s
			Util.sexpr "set-string", @name, @value
		end
	end

	class Block
		def initialize(statements)
			@statements = statements
		end

		def eval(scope)
			@statements.each {|s| Evaling.eval s, scope}
		end

		def to_s
			Util.nsexpr "block", *@statements
		end
	end

	class If
		def initialize(condition, if_true, if_false)
			@condition	= condition
			@if_true	= if_true
			@if_false	= if_false
		end

		def eval(scope)
			if Evaling.eval(@condition, scope)
				Evaling.eval @if_true, scope
			else
				Evaling.eval @if_false, scope
			end
		end
	end

	class While
		def initialize(condition, body)
			@condition	= condition
			@body		= body
		end

		def eval(scope)
			while Evaling.eval @condition, scope
				Evaling.eval @body, scope
			end
		end

		def to_s
			Util.sexpr "while", @condition, @body
		end
	end
end
