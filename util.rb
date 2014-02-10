module Util
	def Util.sexpr(head, *tail)
		s = "(#{head.to_s}"
		tail.each {|arg| s += " " + arg.to_s}
		s += ")"
		return s
	end

	class Stack
		def initialize(*children)
			@children = children
		end

		def push(child)
			@children.push child
		end

		def pop
			@children.pop
		end

		def peek
			@children[@children.length-1]
		end

		def empty?
			@children.empty?
		end

		def empty!
			@children = []
		end
	end
end
