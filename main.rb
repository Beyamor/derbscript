require_relative "tokenizing.rb"

contents = File.read "scripts/foo.derp"

tokens = Tokenizing.tokenize contents
puts tokens.to_s
