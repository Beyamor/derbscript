require_relative "ds"

contents	= File.read ARGV[0]
parse_result	= DS.parse contents
puts parse_result.to_s
DS.run parse_result
