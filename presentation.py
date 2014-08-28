from string import Template

def generate_template(data, names, output_file_path):
	tmpl_file = open('assets/template.html', 'r')
	output_file = open(output_file_path, 'w')

	tmpl = Template(tmpl_file.read())
	vals = { 
		'table': template_table_data(append_names(convert(names), data)), 
		'head': template_table_data([ append_x(convert(names)) ])
	}
	output_file.write(tmpl.substitute(vals))

	tmpl_file.close()
	output_file.close()


def template_table_data(data):
	result = ''
	for r in data:
		result += '<tr>'
		for d in r:
			result += '<td>'
			result += str(d)
			result += '</td>'
			pass
		result += '</tr>'
	pass
	return result


def convert(names):
	result = []
	for name in names:
		result.append(name)
	return result


def append_names(names, data):
	for i in xrange(len(data)):
		data[i].insert(0, names[i])
	return data


def append_x(names):
	names.insert(0, '')
	return names
