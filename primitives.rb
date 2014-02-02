module Primitives
	class Function
		def initialize(&block)
			@block = block
		end

		def call(args)
			@block.call *args
		end
	end
end
