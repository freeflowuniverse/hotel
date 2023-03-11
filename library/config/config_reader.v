module config

pub struct ConfigParser {
pub mut:
	actor_configs []ActorConfig
}

pub fn new() ConfigParser {
	return ConfigParser{}
}

pub fn (mut cp ConfigParser) parse_text (content string) {
	mut lines := content.split('\n').filter(it!='')
	mut config := ActorConfig{}
	mut current_method := ActorMethod{}
	for line in lines {
		mut parts := line.split(' ')
		match line[0].ascii_str() {
			'N' {config.name == parts[1]}
			'M' {
				if current_method.name != '' {
					config.methods << current_method
				}
				current_method = ActorMethod{
					name: parts[1]
				}
			}
			'I' {
				current_method.inputs << Data{
					data_value: parts[1]
					data_type: parts[2]
				}
			}
			'O' {
				current_method.outputs << Data{
					data_value: parts[1]
					data_type: parts[2]
				}
			}
			else {}
		}
	}
	config.methods << current_method
	cp.actor_configs << config
}

// pub fn (mut cp ConfigParser) parse_file (file_path string) ! {

// }