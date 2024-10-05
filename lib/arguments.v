module lib

import os

pub struct ImprovedArguments {
mut:
	default_args 				[]string
	default_args_string 		string
	default_args_character_len	int
	formatted_args_map			map[string]string
}

fn(args ImprovedArguments) go_to_delimiter(i int, delimiter string, body string)(int, string){
	mut j := i
	mut content := ''
	for {
		if j >= body.len {
			break
		}

		ch := body[j].ascii_str()
		if ch == delimiter {
			break
		}
		content = '$content$ch'
		j++
	}
	return j, content.trim(' ')
}

pub fn (mut args ImprovedArguments) parse() {
	args.default_args = os.args
	args.default_args.delete(0)
	args.default_args_string = args.default_args.join(' ')
	args.default_args_character_len = args.default_args_string.len

	value_followed_argument_array:= ['-d', '-f', '-t']
	mut i := 0
	mut word := ''
	for {
		if i >= args.default_args_character_len { break }
		ch := args.default_args_string[i].ascii_str()
		if ch == ' ' {
			if word[0].ascii_str() != '-' {
				i++
				word = ''
				continue
			}
			if value_followed_argument_array.contains(word) {
				mut content := ''
				i, content = args.go_to_delimiter(i, '-', args.default_args_string)
				args.formatted_args_map[word.substr(1, word.len)] = content
				i--
			}else {
				args.formatted_args_map[word.substr(1, word.len)] = ''
			}
			word = ''
			i++
			continue
		}
		word = '$word$ch'
		i++
	}
}

pub fn (args ImprovedArguments) get_map() map[string]string { return args.formatted_args_map }

pub fn (args ImprovedArguments) get_help() {
	arguments := {
		'h': 'Get list of all available arguments with its description',
		'd': 'Specify the folder to scan',
		'f': 'Specify the file to scan',
		't': 'Target folder to create the documentation files'
	}
	print('Argument\t\tDescription\n')
	print('-------------------------------------------------------------\n')
	for k, v in arguments {
		print('-$k\t\t$v\n')
	}
}