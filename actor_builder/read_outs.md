pub struct UserClient {
pub mut:
        user_address string
        baobab          baobab_client.Client
}

pub fn new(user_id string) !UserClient {
        mut supervisor := supervisor_client.new() or {
                return error('Failed to create a new supervisor client with error: \n$err')
        }
        address := supervisor.get_address('user', user_id) or {return error('Failed to get address of user with given id with error: \n$err')}
        return UserClient{
                user_address: address
                baobab: baobab_client.new('0') or {return error('Failed to create new baobab client with error: \n$err')}
        }
}