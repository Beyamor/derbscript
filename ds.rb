require_relative "grammar"
require_relative "parsing"
require_relative "statements"

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
		},

		:statements => {
			"if"	=> lambda do |parser|
				parser.expect "("
				condition = parser.parse_expression
				parser.expect ")"
				parser.devour_terminators
				if_true = parser.parse_block_or_statement
				parser.devour_terminators
				parser.expect_text "else"
				parser.devour_terminators
				if_false = parser.parse_block_or_statement
				return Statements::If.new condition, if_true, if_false
			end,

			"set"	=> lambda do |parser|
				name	= parser.parse_name
				value	= parser.parse_expression
				return Statements::SetVar.new name, value
			end,

			"while"	=> lambda do |parser|
				parser.expect "("
				condition = parser.parse_expression
				parser.expect ")"
				body = parser.parse_block_or_statement
				return Statements::While.new condition, body
			end,

			"proc"	=> lambda do |parser|
				name	= parser.parse_name
				params	= parser.parse_params_definition
				body	= parser.parse_block
				return Statements::ProcDefinition.new name, params, body
			end
		}
	})

	@@parser = Parsing::Parser.new @@grammar

	def DS.parse(tokens)
		@@parser.parse tokens
	end
end
