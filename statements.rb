require_relative "primitives"
require_relative "evaling"
require_relative "environment"
require_relative "util"

module Statements
	attr_reader :name, :parameter_names, :body

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

	class FuncDefinition
		def initialize(name, parameter_names, body)
			@name			= name
			@parameter_names	= parameter_names
			@body			= body
		end

		def eval(scope)
			scope[@name] = Primitives::Func.new @parameter_names, @body, scope
		end

		def to_s
			Util.sexpr "def-func", @name, @parameter_names, *@body
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
		attr_accessor :statements

		def initialize(statements)
			@statements = statements
		end

		def to_s
			Util.nsexpr "block", *@statements
		end
	end

	class If
		attr_accessor :condition, :if_true, :if_false
		def initialize(condition, if_true, if_false=nil)
			@condition	= condition
			@if_true	= if_true
			@if_false	= if_false
		end

		def to_s
			Util.sexpr "if", @condition, @if_true, @if_false
		end
	end

	class Loop
		attr_accessor :body

		def initialize(body)
			@body = body
		end

		def to_s
			Util.sexpr "loop", @body
		end
	end

	class Break
		def to_s
			Util.sexpr "break"
		end
	end

	class Return
		attr_accessor :expression

		def initialize(expression=nil)
			@expression = expression
		end

		def to_s
			if @expression
				Util.sexpr "return", @expression
			else
				Util.sexpr "return"
			end
		end
	end
end
