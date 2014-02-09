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
			@scopes.each {|sub_scope| scope = scope[sub_scope]}
			return scope[@name]
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
		def initialize(type, initial_value=nil)
			@type	= type
			value	= initial_value
		end

		def value
			@value
		end

		def value=(new_value)
			throw "Can't assign #{new_value}; #{new_value.class} is not a #{@type}" unless new_value.is_a? @type
			@value = new_value
		end
	end

	class Scope
		def initialize(parent)
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

		def redefine_value(name, value)
			if @vars.member? name
				@vars[name] = value
			elsif @parent
				@parent.redefine_value name, value
			else
				throw "Variable #{name} doesn't exist"
			end
		end

		def []=(name, value)
			name = name.name if name.respond_to? :name
			if existing_var? name
				redefine_value name, value
			else
				@vars[name] = value
			end
		end

		def [](name)
			name = name.name if name.respond_to? :name
			if @vars.has_key? name
				@vars[name]
			elsif @parent
				@parent[name]
			else
				throw "Couldn't resolve #{name}"
			end
		end

		def define(vars)
			vars.each {|name, value| self[name] = value}
		end

		def to_tree
			tree =
				if @parent
					@parent.to_tree
				else
					[]
				end
			tree << @vars.keys.to_a
			return tree
		end

		def to_s
			tree	= to_tree
			depth	= 0
			s = ""
			tree.each do |level|
				prefix =
					if depth == 0
						"-"
					else
						"\n|" + "-" * depth
					end
				s += prefix + level.to_s
				depth += 1
			end
			return s
		end
	end
end
