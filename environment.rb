module Environment
	class Scope
		def initialize(parent)
			@parent	= parent
			@vars	= {}
		end

		def []=(name, value)
			@vars[name] = value
		end

		def [](name)
			if @vars.has_key? name
				@vars[name]
			elsif @parent
				@parent[name]
			else
				throw "Couldn't resolve #{name}"
			end
		end
	end
end
