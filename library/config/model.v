module config

pub struct ActorConfig {
pub mut:
	name string
	methods []ActorMethod
}

pub struct ActorMethod {
pub mut:
	name string
	inputs []Data 
	outputs []Data
}

pub struct Data {
pub mut:
	data_value string
	data_type string
}