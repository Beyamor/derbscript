require_relative "primitives"
require_relative "evaling"
require_relative "environment"
require_relative "util"

module Statements
	attr_reader :name, :parameter_names, :body

	class ProcDefinition < Util::LanguageNode
		def initialize(name, parameter_names, body)
			@name			= name
			@parameter_names	= parameter_names
			@body			= body
			super()
		end

		def eval(scope)
			scope[@name] = Primitives::Proc.new @parameter_names, @body, scope
		end

		def to_s
			Util.sexpr "def-proc", @name, @parameter_names, *@body
		end
	end

	class ScopeDefinition < Util::LanguageNode
		def initialize(name, body)
			@name	= name
			@body	= body
			super @body
		end

		def eval(parent_scope)
			scope = Environment::Scope.new parent_scope
			Evaling.eval @body, scope
			parent_scope[@name] = scope
		end
	end

	class SetVar < Util::LanguageNode
		def initialize(name, value)
			@name	= name
			@value	= value
			super @value
		end

		def eval(scope)
			scope[@name] = Evaling.eval @value, scope
		end

		def to_s
			Util.sexpr "set-string", @name, @value
		end
	end

	class Block < Util::LanguageNode
		def initialize(statements)
			@statements = statements
			super *@statements
		end

		def eval(scope)
			@statements.each {|s| Evaling.eval s, scope}
		end

		def to_s
			Util.nsexpr "block", *@statements
		end
	end

	class If < Util::LanguageNode
		attr_accessor :condition, :if_true, :if_false
		def initialize(condition, if_true, if_false=nil)
			@condition	= condition
			@if_true	= if_true
			@if_false	= if_false
			super @condition, @if_true, @if_false
		end

		def eval(scope)
			if Evaling.eval(@condition, scope)
				Evaling.eval @if_true, scope
			elsif @if_false
				Evaling.eval @if_false, scope
			end
		end

		def to_s
			Util.sexpr "if", @condition, @if_true, @if_false
		end
	end

	class Loop < Util::LanguageNode
		attr_accessor :body

		def initialize(body)
			@body = body
		end

		def to_s
			Util.sexpr "loop", @body
		end
	end

	class Break < Util::LanguageNode
		def to_s
			Util.sexpr "break"
		end
	end
end
