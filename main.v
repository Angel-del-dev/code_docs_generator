module main

import os
import lib

fn create_parser() lib.FileParser {
	return lib.FileParser{}
}

fn main() {
	if os.args.len == 1 {
		print('A destination path must be given as the first parameter\n')
		exit(1)
	}

	path := os.abs_path(os.args[1])

	objects := os.ls(path) or {
		print('"$path" could not be accessed\n')
		exit(0)
	}
	for obj in objects {
		mut file := create_parser()
		file.parse('$path/$obj')
	}
}