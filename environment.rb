module Environment
	class Scope
		def initialize(parent)
			@parent	= parent
			@vars	= {}
		end

		def []=(name, value)
			name = name.name if name.respond_to? :name
			@vars[name] = value
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

		def to_s()
			s = @vars.keys.to_s
			if @parent
				s += "\n\t" + @parent.to_s
			end
			return s
		end
	end
end
