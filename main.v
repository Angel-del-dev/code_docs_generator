module main

import os
import lib

fn create_parser() lib.FileParser {
	return lib.FileParser{}
}

fn scan_path(path string, mut fp_array []lib.FileParser, dir string)[]lib.FileParser {
	objects := os.ls(path) or {
		print('"$path" is not a valid directory\n')
		exit(0)
	}

	for obj in objects {
		if os.is_dir('$path/$obj') {
			if !os.is_dir_empty('$path/$obj') {
				fp_array = scan_path('$path/$obj', mut fp_array, dir)
			}
			continue
		}
		if obj[0].ascii_str() == '.' {
			continue
		}
		mut file := create_parser()
		file.parse(dir, '$path/$obj')
		fp_array << file
	}
	return fp_array
}

fn main() {
	mut app_args := lib.ImprovedArguments{}
	app_args.parse()
	f_args := app_args.get_map()
	keys_f_args := f_args.keys()
	mut fp_array := []lib.FileParser{}

	if keys_f_args.contains('h') {
		app_args.get_help()
		exit(1)
	}

	if !keys_f_args.contains('t') {
		print('The target argument (-t) must be specified\n')
		exit(1)
	}

	print('Parsing files...\n')

	if keys_f_args.contains('d'){
		path := os.abs_path(f_args['d'])
		fp_array = scan_path(path, mut fp_array, f_args['d'])
	} else if keys_f_args.contains('f') {
		path := os.abs_path(f_args['f'])
		if !os.is_file(path) {
			print('"$path" is not a file\n')
			exit(1)
		}
		mut file := create_parser()
		file.parse(f_args['f'], path)
		fp_array << file
	} else {
		print('Scan mode must be specified\n')
		exit(1)
	}

	if !os.exists(f_args['t']) {

		os.mkdir(f_args['t']) or {
			print('Could not create folder '+f_args['t'])
			exit(1)
		}
	}

	print(fp_array.len.str()+' files parsed...\n')
	print('Generating markup...\n')

	for mut f in fp_array {
		if !os.exists(f_args['t']+'/'+f.dir_path) {
			os.mkdir(f_args['t']+'/'+f.dir_path) or {
				print('Could not create folder '+f_args['t']+'/'+f.dir_path)
				exit(1)
			}
		}

		generator := lib.Generator{}
		contents := generator.generate(mut f)
		f_name_no_extension := f.file_name.split('.')[0]
		os.write_file(f_args['t']+'/'+f.dir_path+'/'+f_name_no_extension+'.md', contents) or {
			print('Could not create file '+f_args['t']+'/'+f.dir_path+'/'+f_name_no_extension+'.md')
			exit(1)
		}
	}

	print('Markup generated...\n')
	print('\nEnjoy\n')
}