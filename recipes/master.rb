# data_directory = node['postgresql']['config']['data_directory']

postgresql_solo_setup_master 'Setup Master Server' do
  version node['postgresql']['version']
  host node['postgresql']['config']['host']
  port node['postgresql']['config']['port']
  dbname node['postgresql']['config']['dbname']
  dbpass node['postgresql']['config']['dbpass']
  dbuser node['postgresql']['config']['dbuser']
  dbuser_pass node['postgresql']['config']['dbuser_pass']

  replication node['postgresql']['replication']
  repuser node['postgresql']['config']['repuser']
  repuser_pass node['postgresql']['config']['repuser_pass']

  hba_file node['postgresql']['config']['hba_file']
  ident_file node['postgresql']['config']['ident_file']
  external_pid_file node['postgresql']['config']['external_pid_file']
  additional_config node['postgresql']['additional_config']
  data_directory node['postgresql']['config']['data_directory']

  pg_hba node['postgresql']['pg_hba']
  pg_hba_replica node['postgresql']['pg_hba_replica']
end

# postgresql_server_install 'postgresql' do
#   hba_file node['postgresql']['config']['hba_file']
#   ident_file node['postgresql']['config']['ident_file']
#   external_pid_file node['postgresql']['config']['external_pid_file']
#   password node['postgresql']['config']['dbpass']
#   port node['postgresql']['config']['port']
#   version node['postgresql']['version']
#   setup_repo true
# 
#   action [:install, :create]
# end
# 
# node['postgresql']['pg_hba'].each do |item|
#   postgresql_access 'default pg_hba access' do
#     access_type item['type']
#     access_db item['db']
#     access_user item['user']
#     access_addr item['addr']
#     access_method item['method']
# 
#     notifies :reload, 'service[postgresql]'
#   end
# end
# 
# postgresql_user node['postgresql']['config']['dbuser'] do
#   superuser true
#   password node['postgresql']['config']['dbuser_pass']
#   sensitive true
# end
# 
# # Replication
# if node['postgresql']['replication'] == true
#   repuser = node['postgresql']['config']['repuser']
# 
#   postgresql_user repuser do
#     replication true
#     login true
#     password node['postgresql']['config']['repuser_pass']
#     sensitive true
#   end
# 
#   directory "#{data_directory}/archive/" do
#     owner 'postgres'
#     group 'postgres'
#     recursive true
#     mode '0700'
# 
#     action :create
#   end
# 
#   node['postgresql']['pg_hba_replica'].each do |item|
#     postgresql_access "Access for #{repuser} on #{item['addr']}" do
#       access_type item['type']
#       access_db item['db']
#       access_user repuser
#       access_addr item['addr']
#       access_method item['method']
# 
#       notifies :reload, 'service[postgresql]'
#     end
#   end
# end
# 
# postgresql_server_conf 'Configure Postgresql Server' do
#   hba_file node['postgresql']['config']['hba_file']
#   ident_file node['postgresql']['config']['ident_file']
#   external_pid_file node['postgresql']['config']['external_pid_file']
#   data_directory data_directory
# 
#   version node['postgresql']['version']
#   port node['postgresql']['config']['port']
# 
#   additional_config node['postgresql']['additional_config']
# 
#   notifies :reload, 'service[postgresql]'
# end
# 
# find_resource(:service, 'postgresql') do
#   extend PostgresqlCookbook::Helpers
#   service_name lazy { platform_service_name }
#   supports restart: true, status: true, reload: true
#   action [:enable, :start]
# end
# 
# service 'postgresql' do
#   extend PostgresqlCookbook::Helpers
#   service_name lazy { platform_service_name }
#   supports restart: true, status: true, reload: true
#   action :restart
# end
# 
# postgresql_database node['postgresql']['config']['dbname'] do
#   owner node['postgresql']['config']['dbuser']
#   host node['postgresql']['config']['host']
#   port node['postgresql']['config']['port']
# end

include_recipe 'postgresql_solo::_apt'
