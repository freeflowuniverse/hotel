module maintenance


struct Maintenance {
	id string
	storage_id   string
	assistance_requests map[string]AssistanceRequest // string is id
}


// TO USER
fn (maintenance Maintenance) expose_work_request (assistance_request AssistanceRequest) ! {}

// FROM USER
fn (maintenance Maintenance) log_completed_work () ! {}

// FROM USER
fn (maintenance Maintenance) report_damage () ! {}


fn (maintenance Maintenance)  () ! {}
