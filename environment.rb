module Environment
	class Identifier
		attr_accessor :name, :scopes

		def initialize(name)
			*@scopes, @name = name.split ":"
		end

		def is_qualified?
			@scopes.length > 0
		end

		def resolve(scope)
			if is_qualified?
				scope = scope.root
				@scopes.each {|sub_scope| scope = scope[sub_scope]}
				return scope[@name]
			else
				return scope[@name]
			end
		end

		def to_s
			if @scopes.empty?
				@name
			else
				@scopes.join(":") + ":" + @name
			end
		end
	end

	class Var
		def initialize(type=nil, initial_value=nil)
			@type = type
			if initial_value != nil
				self.value = initial_value
			end
		end

		def value
			@value
		end

		def value=(new_value)
			if is_typed? and not new_value.is_a? @type
				throw "Can't assign #{new_value}; #{new_value.class} is not a #{@type}"
			end
			@value = new_value
		end

		def is_typed?
			@type != nil
		end
	end

	class Scope
		def initialize(parent=nil)
			@parent	= parent
			@vars	= {}
		end

		def existing_var?(name)
			if @vars.member? name
				return true
			elsif @parent
				return @parent.existing_var? name
			else
				return false
			end
		end

		def declare_var(name, type)
			name = name.name if name.respond_to? :name
			@vars[name] = Var.new type
		end

		def declare_var_if_missing(name, type)
			name = name.name if name.respond_to? :name
			unless existing_var? name
				@vars[name] = Var.new type
			end
		end

		def set_existing_var(name, value)
			if @vars.member? name
				@vars[name].value = value
			elsif @parent
				@parent.set_existing_var name, value
			else
				throw "Variable #{name} doesn't exist"
			end
		end

		def []=(name, value)
			name = name.name if name.respond_to? :name
			if existing_var? name
				set_existing_var name, value
			else
				@vars[name] = Var.new nil, value
			end
		end

		def [](name)
			name = name.name if name.respond_to? :name
			if @vars.has_key? name
				@vars[name].value
			elsif @parent
				@parent[name]
			else
				throw "Couldn't resolve #{name}"
			end
		end

		def define(vars)
			vars.each {|name, value| self[name] = value}
		end

		def root
			if @parent
				@parent.root
			else
				self
			end
		end
	end
end
