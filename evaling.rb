module Evaling
	def Evaling.eval(thing, context)
		if thing.respond_to? :eval
			thing.eval context
		else
			thing
		end
	end
end
