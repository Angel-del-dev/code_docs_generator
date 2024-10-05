module lib

import os
import regex

pub struct FileParser {
	mut:
		dir_path			string
		file_path			string
		file_name			string
		file_extension		string
		file_body			string
		file_body_length	int
		file_vdoc_groups 	[][]string
}

fn (fp FileParser) go_to_delimiter(i int, body string, delimiter string) (int, string) {
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
	return j, content.trim('')
}

fn (mut fp FileParser) parse_vdoc_group(vdoc_group string) {
	mut k, _ := fp.go_to_delimiter(0, vdoc_group, '@')
	k++
	vdoc_group_format := vdoc_group.substr(k, vdoc_group.len)
	k = 0

	for {
		if k >= vdoc_group_format.len {
			break
		}

		mut content := ''
		k, content = fp.go_to_delimiter(k, vdoc_group_format, '@')
		mut re_sanitize := regex.regex_opt(r'[\s]{2,}') or {
			print('Could not replace regex')
			exit(1)
		}

		mut format_content := re_sanitize.replace(content, ' ').split('\n')
		for block in format_content{
			block_array := block.trim(' ').split(' ')
			if block_array.len == 1 && block_array[0].trim(' ') == '' {
				continue
			}
			fp.file_vdoc_groups << block_array
		}
		k++
	}
}

fn (mut fp FileParser) extract_vdoc_groups() {
	mut i := 0
	mut word := ''
	for {
		if i >= fp.file_body_length {
			break
		}

		ch := fp.file_body[i].ascii_str()
		if ch == ' ' || ch == '\n' {
			word = ''
		}else {
			word = '$word$ch'
		}

		if word.to_lower() == '#vdocs' {
			mut vdoc_group := ''
			i, vdoc_group = fp.go_to_delimiter(i + 1, fp.file_body, '#')
			fp.parse_vdoc_group(vdoc_group)
		}

		i++
	}
}

pub fn (mut fp FileParser) parse(base_path string, path string) {
	fp.dir_path = os.dir(path).split(base_path)[1]
	fp.file_path = path
	fp.file_body = os.read_file(path) or {
		print('Could not open "$path"\n')
		exit(1)
	}
	mut file_path_array := path.split('/')
	fp.file_name = file_path_array.pop()
	mut file_name_array := fp.file_name.split('.')
	if file_name_array.len > 1 {
		fp.file_extension = file_name_array.pop()
	}
	fp.file_body_length = fp.file_body.len
	fp.extract_vdoc_groups()
}