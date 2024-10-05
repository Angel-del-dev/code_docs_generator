module lib

pub struct Generator {

}

pub fn (g Generator) generate(mut f FileParser) string {
	mut content := ''

	for mut group in f.file_vdoc_groups {
		match group[0].to_upper() {
			'TITLE' {
				mut title := ''
				if group.len >= 2 {
					group.delete(0)
					title = group.join(' ')
				}
				content += '# '+title
			}
			'SUBTITLE' {
				mut subtitle := ''
				if group.len >= 2 {
					group.delete(0)
					subtitle = group.join(' ')
				}
				content += '## '+subtitle
			}
			'CODE' {
				mut lang := ''
				mut code := ''
				if group.len >= 3 {
					lang = group[1]
					group.delete(0)
					group.delete(0)
					code = group.join(' ')
				}else if group.len == 2  {
					code = group[1]
				}
				content += '```'+lang+' '+code+'```'
			}
			'DESCRIPTION' {
				group.delete(0)
				content += group.join(' ')
			}
			else {
				print('\nUnknown identifier "'+group[0]+'"\n')
				exit(1)
			}
		}
		content += '  \n'
	}
	//exit(1)
	return content
}