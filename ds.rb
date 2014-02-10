require_relative "grammar"
require_relative "parsing"
require_relative "statements"
require_relative "environment"
require_relative "tokenizing"
require_relative "evaling"

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
			:name	=> Parsing::ResolveVarParslet.new
		},

		:binary_operators => {
			"+"	=> PRECEDENCES[:addsub],
			"-"	=> PRECEDENCES[:addsub],
			"*"	=> PRECEDENCES[:muldiv],
			"\\"	=> PRECEDENCES[:muldiv],
			">"	=> PRECEDENCES[:compare],
			">="	=> PRECEDENCES[:compare],
			"<"	=> PRECEDENCES[:compare],
			"<="	=> PRECEDENCES[:compare],
			"=="	=> PRECEDENCES[:compare]
		},

		:infixes => {
			"("	=> Parsing::CallParselet.new(PRECEDENCES[:call]),
			"="	=> Parsing::NumericAssignmentParselet.new(PRECEDENCES[:assignment])
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
				loop_body = Statements::If.new condition, body, Statements::Break.new

				return Statements::Loop.new loop_body
			end,

			"proc"	=> lambda do |parser|
				name	= parser.parse_name
				params	= parser.parse_params_definition
				body	= parser.parse_block
				return Statements::ProcDefinition.new name, params, body
			end,

			"func" => lambda do |parser|
				name		= parser.parse_name
				params		= parser.parse_params_definition
				parser.expect "->"
				return_type	= parser.parse_type
				body		= parser.parse_block
				return Statements::FuncDefinition.new name, params, return_type, body
			end,

			"scope" => lambda do |parser|
				name	= parser.parse_name
				body	= parser.parse_block
				return Statements::ScopeDefinition.new name, body
			end,

			"break" => lambda do |parser|
				return Statements::Break.new
			end,

			"return" => lambda do |parser|
				if parser.next_token.type != :terminator
					expression = parser.parse_expression
					return Statements::Return.new expression
				else
					return Statements::Return.new
				end
			end
		}
	})

	@@parser = Parsing::Parser.new @@grammar
	@@parser.type_map = {
		"String"	=> String,
		"Number"	=> Float
	}

	def DS.core_library
		open_files = {}
		return {
			"printFoo"	=> Primitives::BlockFunction.new {puts "foo"},
			"println"	=> Primitives::BlockFunction.new {|x| puts x},
			"open"		=> Primitives::BlockFunction.new {|which| open_files[which] = File.open which, "w"},
			"write"		=> Primitives::BlockFunction.new {|which, text| open_files[which].write text},
			"close"		=> Primitives::BlockFunction.new {|which| open_files[which].close},
			"readln"	=> Primitives::BlockFunction.new { $stdin.gets.chomp },
			"str"		=> Primitives::BlockFunction.new {|x| x.to_s }

		}
	end

	@@evaluator = Evaling::Evaluator.new
	@@evaluator.truthiness = Proc.new do |thing|
		case thing
		when TrueClass
			true
		when FalseClass
			false
		when Float
			thing == 0
		when String
			thing.empty?
		else
			false
		end
	end

	def DS.tokenize(stuff)
		return Tokenizing.tokenize stuff
	end

	def DS.parse(stuff)
		tokens =
			case stuff
			when String
				DS.tokenize stuff
			else
				stuff
			end

		@@parser.parse tokens
	end

	def DS.eval(stuff, scope=nil)
		unless scope
			scope = Environment::Scope.new
			scope.define core_library
		end

		parse_tree =
			case stuff
			when String
				DS.parse stuff
			else
				stuff
			end
		return @@evaluator.eval parse_tree, scope
	end

	def DS.run(stuff)
		global_scope = Environment::Scope.new
		global_scope.define core_library
		DS.eval stuff, global_scope
		global_scope["main"].call @@evaluator, []
	end
end
