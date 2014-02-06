module Util
	def Util.sexpr(head, *tail)
		s = "(#{head.to_s}"
		tail.each {|arg| s += " " + arg.to_s}
		s += ")"
		return s
	end
end
