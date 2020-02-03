postgresql_solo_setup_master 'postgresql' do
  version node['postgresql']['version']
  database 'test'
  username 'user_test'
  password 'aezakmi'
end

include_recipe 'postgresql_solo::_apt'

