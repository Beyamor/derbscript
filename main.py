from optparse import OptionParser

opt_parser = OptionParser()
(options, file_names) = opt_parser.parse_args()

def read_contents(file_name):
	with open(file_name, "r") as some_file:
		contents = some_file.read()
	return contents

for file_name in file_names:
	print(read_contents(file_name))
