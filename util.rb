module Util
	def Util.sexpr(head, *tail)
		s = "(#{head.to_s}"
		tail.each {|arg| s += " " + arg.to_s}
		s += ")"
		return s
	end

	def Util.nsexpr(head, *tail)
		s = "(#{head.to_s}"
		tail.each {|arg| s += "\n " + arg.to_s}
		s += ")"
		return s
	end

	class LanguageNode
		attr_accessor :parent, :children, :node_index

		def initialize(*children)
			@children	= children
			@parent		= nil
			@children.each_with_index do |node, index|
				node.parent	= self
				node.node_index	= index
			end
		end

		def has_parent?
			parent != nil
		end

		def is_first?
			@node_index == 0
		end

		def is_last?
			@node_index == @parent.children.length - 1
		end

		def is_leaf?
			@is_leaf
		end
	end

	class LanguageLeafNode < LanguageNode
		def initialize
			super
			@is_leaf = true
		end
	end
end
