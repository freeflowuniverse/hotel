dir_path := dir(@FILE)
rmdir_all(dir_path + '/kitchen') or {}
mkdir(dir_path + '/kitchen')!
cp(dir_path + '/src/methods.v', dir_path + '/kitchen/methods.v')!
cp(dir_path + '/src/flows.v', dir_path + '/kitchen/flows.v')!
cp_all(dir_path + '/src/model', dir_path + '/kitchen/model', true)!