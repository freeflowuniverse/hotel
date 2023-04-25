execute_or_panic('v run cleanup.vsh')
execute_or_panic('v run build.v')
execute_or_panic('v fmt -w ./actors')
// execute_or_panic('v run import_test.v')