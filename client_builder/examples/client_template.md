module @{client.name}_client

import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client

pub struct @{client.name.capitalize()}Client{}

pub fn new() @{client.name.capitalize()}Client {
	return @{client.name.capitalize()}Client{
		baobab: client.new()
	}
}

@for method in client.spv_methods
pub fn (client @{client.name.capitalize()}Client) @{method.name} (
	@for _, data in method.inputs
	@{data.name} @{data.data_type},
	@end
	) !
	@if method.outputs.len == 1 
	@{method.outputs[0].name} @{method.outputs[0].data_type}
 	@end
	@if method.outputs.len > 1
		(
		@for _, data in method.outputs
	@{data.name} @{data.data_type},
		@end
		)
	@end
	{

	j_args := params.Params{}
	@for _, data in method.inputs
	j_args.kwarf_add('@{data.name}', @{data.name})
	@end

	job := client.baobab.job_new(
		action:
		args: j_args
	)!

	response := client.baobab.job_schedule_wait(job, 100)!

	if response.state == .error {
		return error('Job returned with an error')
	}

	return
	@for _,data in method.outputs 
		response.result.get('@{data.name}')
	@end 
}
@end