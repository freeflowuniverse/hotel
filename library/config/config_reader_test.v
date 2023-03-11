module config 

fn test_parse_text() {
	input := 'N guest

M add_guest
I person person.Person
O guest_code string

M order_product_flow
I chat_id string
I user_id string
'
	expected_output := config.ActorConfig{
        name: ''
        methods: [config.ActorMethod{
            name: 'add_guest'
            inputs: [config.Data{
                data_value: 'person'
                data_type: 'person.Person'
            }]
            outputs: [config.Data{
                data_value: 'guest_code'
                data_type: 'string'
            }]
        }, config.ActorMethod{
            name: 'order_product_flow'
            inputs: [config.Data{
                data_value: 'chat_id'
                data_type: 'string'
            }, config.Data{
                data_value: 'user_id'
                data_type: 'string'
            }]
            outputs: []
        }]
    }

	mut cp := new()
	cp.parse_text(input)
	assert cp.actor_configs[0] == expected_output
}