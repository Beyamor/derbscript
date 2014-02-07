require_relative "grammar"
require_relative "parsing"

module DS
	PRECEDENCES = {
		:assignment	=> 1,
		:compare	=> 2,
		:addsub		=> 3,
		:muldiv		=> 4,
		:call		=> 5
	}

	@@grammar = Grammar::Grammar.describe({
		:prefixes => {
			:string	=> Parsing::StringParslet.new,
			:number	=> Parsing::NumberParslet.new,
			"("	=> Parsing::ParensParslet.new,
			:name	=> Parsing::NameParslet.new
		},

		:binary_operators => {
			"+"	=> PRECEDENCES[:addsub],
			"-"	=> PRECEDENCES[:addsub],
			"*"	=> PRECEDENCES[:muldiv],
			"\\"	=> PRECEDENCES[:muldiv],
			">"	=> PRECEDENCES[:compare],
			">="	=> PRECEDENCES[:compare],
			"<"	=> PRECEDENCES[:compare],
			"<="	=> PRECEDENCES[:compare]
		},

		:infixes => {
			"("	=> Parsing::CallParselet.new(PRECEDENCES[:call]),
			"="	=> Parsing::AssignmentParselet.new(PRECEDENCES[:assignment])
		}
	})

	@@parser = Parsing::Parser.new @@grammar

	def DS.parse(tokens)
		@@parser.parse tokens
	end
end
