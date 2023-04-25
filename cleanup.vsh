dir_path := dir(@FILE)
rmdir_all(dir_path + '/actors')!
cp_all(dir_path + '/src/actors', dir_path + '/actors', true)!
