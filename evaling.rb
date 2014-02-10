require_relative "environment"
require_relative "statements"
require_relative "util"

module Evaling
	class Evaluator
		attr_accessor :truthiness

		def is_truthy?(thing)
			@truthiness.call thing
		end

		def eval(thing, scope)
			stack	= Util::Stack.new thing
			loops	= Util::Stack.new

			until stack.empty?
				thing = stack.pop
				case thing
				when Statements::Block
					thing.statements.reverse.each do |statement|
						stack.push statement
					end
				when Statements::Loop
					if loops.peek != thing
						loops.push thing
					end

					stack.push thing
					stack.push thing.body
				when Statements::If
					if is_truthy? self.eval thing.condition, scope
						stack.push thing.if_true
					else
						stack.push thing.if_false
					end
				when Statements::Break
					throw "No loop to break out of" if loops.empty?
					until thing == loops.peek
						thing = stack.pop
					end
					loops.pop
				when Statements::Return
					if thing.expression
						return Evaling.eval thing.expression, scope
					else
						return nil
					end
				else
					result = thing.eval self, scope
				end
			end
			return result
		end
	end
end
