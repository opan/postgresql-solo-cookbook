postgresql_solo_setup_master 'postgresql' do
  version node['postgresql']['version']
  database 'test'
  host node['postgresql']['config']['host']
  username 'user_test'
  password 'aezakmi'
end

include_recipe 'postgresql_solo::_apt'

