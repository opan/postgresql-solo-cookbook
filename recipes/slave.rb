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

# Enable `hot_standby` on slave server
node.override['postgresql']['additional_config']['hot_standby'] = 'on'
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

bash "Backup #{data_directory}" do
  code <<-EOH
    cd #{data_directory}
    cd .. && mv main main-backup

    mkdir main/
    chmod 700 main/
  EOH
  user 'postgres'
  group 'postgres'
  not_if { ::File.directory?("#{data_directory}-backup") }
end

master_ip = node['postgresql']['config']['master_ip']
repuser = node['postgresql']['config']['repuser']
repuser_pass = node['postgresql']['config']['repuser_pass']

Passwords = Struct.new(:username, :password, :port, :database, :hostname)
hostname = node['postgresql']['config']['master_ip']

template "#{data_directory}/../../.pgpass" do
  source 'pgpass.erb'
  cookbook 'postgresql_solo'
  variables passwords: [
    Passwords.new(repuser, repuser_pass, node['postgresql']['config']['port'], 'replication', master_ip),
  ]
  owner 'postgres'
  group 'postgres'
  mode '0600'
end

execute 'Copy directory from master with pg_basebackup' do
  command "pg_basebackup -h #{master_ip} -U #{repuser} -D #{data_directory} -P"
  user 'postgres'
  group 'postgres'
  only_if { ::Dir.empty?(data_directory) }
end

template "#{data_directory}/recovery.conf" do
  source 'recovery.conf.erb'
  cookbook 'postgresql_solo'
  variables(
    standby_mode: 'on',
    primary_conninfo: "host=#{master_ip} port=5432 user=#{repuser} password=#{repuser_pass}",
    restore_command: "cp #{data_directory}/archive/%f %p",
    trigger_file: '/tmp/postgresql.trigger.5432'
  )
  owner 'postgres'
  group 'postgres'
  mode '0600'
  notifies :start, 'service[postgresql]', :immediately
end

service 'postgresql' do
  extend PostgresqlCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action :restart
end

include_recipe 'postgresql_solo::_apt'
