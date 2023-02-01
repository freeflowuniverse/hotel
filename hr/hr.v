module hr

// TODO is this redundant? is this what the employee supervisor is supposed to do?

struct HumanResources {
	id string
	employee_ids []EmployeeOverview
}

struct EmployeeOverview {
	employee_id string
	actor_ids []string // list of ids where that employee works
	active bool
	employee_reports []EmployeeReport
}

struct EmployeeReport {
	// todo 
}

/*
- hiring and firing
- submit report on an employee
- ...
*/

// FROM USER
fn (mut hr HumanResources) hire_new_employee () ! {

}

// FROM USER
fn (mut hr HumanResources) make_employee_redundant () ! {

}

fn (mut hr HumanResources)  () ! {

}

 
