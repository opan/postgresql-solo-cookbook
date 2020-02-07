data_directory = node['postgresql']['config']['data_directory']

postgresql_server_install 'postgresql' do
  hba_file node['postgresql']['config']['hba_file']
  ident_file node['postgresql']['config']['ident_file']
  external_pid_file node['postgresql']['config']['external_pid_file']
  password node['postgresql']['config']['dbpass']
  port node['postgresql']['config']['port']
  version node['postgresql']['version']
  setup_repo true

  action [:install, :create]
end

postgresql_server_conf 'Configure Postgresql Server' do
  hba_file node['postgresql']['config']['hba_file']
  ident_file node['postgresql']['config']['ident_file']
  external_pid_file node['postgresql']['config']['external_pid_file']
  data_directory data_directory

  version node['postgresql']['version']
  port node['postgresql']['config']['port']

  additional_config node['postgresql']['additional_config']

  notifies :reload, 'service[postgresql]'
end

node['postgresql']['pg_hba'].each do |item|
  postgresql_access 'default pg_hba access' do
    access_type item['type']
    access_db item['db']
    access_user item['user']
    access_addr item['addr']
    access_method item['method']

    notifies :reload, 'service[postgresql]'
  end
end

postgresql_user node['postgresql']['config']['dbuser'] do
  superuser true
  password node['postgresql']['config']['dbuser_pass']
  sensitive true
end

# Replication
if node['postgresql']['replication'] == true
  repuser = node['postgresql']['config']['repuser']

  postgresql_user repuser do
    replication true
    login true
    password node['postgresql']['config']['repuser_pass']
    sensitive true
  end

  directory "#{data_directory}/archive/" do
    owner 'postgres'
    group 'postgres'
    recursive true
    mode '0700'

    action :create
  end

  node['postgresql']['pg_hba_replica'].each do |item|
    postgresql_access "Access for #{repuser} on #{item['addr']}" do
      access_type item['type']
      access_db item['db']
      access_user repuser
      access_addr item['addr']
      access_method item['method']

      notifies :reload, 'service[postgresql]'
    end
  end
end

service 'postgresql' do
  extend PostgresqlCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end

postgresql_database node['postgresql']['config']['dbname'] do
  owner node['postgresql']['config']['dbuser']
  port node['postgresql']['config']['port']
end

include_recipe 'postgresql_solo::_apt'
