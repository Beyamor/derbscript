require_relative "evaling"

module Primitives
	class Function
		def initialize(&block)
			@block = block
		end

		def call(context, args)
			@block.call *args
		end
	end

	class Proc
		def initialize(param_names, body)
			@param_names	= param_names
			@body		= body
		end

		def call(context, params)
			# TODO create an actual scope rather than clobbering the context
			@param_names.zip(params).each {|name, param| context[name] = param}
			@body.each {|statement| Evaling.eval statement, context}
		end
	end
end
