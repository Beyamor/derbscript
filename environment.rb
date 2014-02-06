module Environment
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

		def set_existing_var(name, value)
			if @vars.member? name
				@vars[name] = value
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
