include PostgresqlSoloCookbook::Constants

property :app, String, name_property: true, required: true
property :version, String, equal_to: VERSIONS, required: true
property :password, [String, nil], default: 'generate' # Set to nil if we do not want to set a password

default_action :setup

action :setup do
  postgresql_solo_client new_resource.app do
    version new_resource.version
  end

  postgresql_server_install 'Setup PostgreSQL Server' do
    hba_file node['postgresql']['config']['hba_file']
    ident_file node['postgresql']['config']['ident_file']
    external_pid_file node['postgresql']['config']['external_pid_file']
    password new_resource.password
    port node['postgresql']['config']['port']
    version new_resource.version
  end

  # Setup pg_hba.conf
  node['postgresql']['pg_hba'].each do |item|
    postgresql_access 'default pg_hba access' do
      access_type item['type']
      access_db item['db']
      access_user item['user']
      access_addr item['addr']
      access_method item['method']
    end
  end

  service 'postgresql' do
    service_name 'postgresql'
    supports restart: true, status: true, reload: true
    action %i[enable start]
  end

  # Calculate work memory
  available_postgresql_memory = 0.95 * node['memory']['total'].to_i
  max_work_mem = 0.25 * available_postgresql_memory.floor
  node.override['postgresql']['additional_config']['shared_buffers'] = "#{(0.25 * available_postgresql_memory).floor}kB"
  node.override['postgresql']['additional_config']['effective_cache_size'] = "#{(0.75 * available_postgresql_memory).floor}kB"
  node.override['postgresql']['additional_config']['work_mem'] = "#{(max_work_mem / node["postgresql"]["additional_config"]["max_connections"]).floor}kB"

  postgresql_server_conf 'Configure Postgresql Server' do
    hba_file node['postgresql']['config']['hba_file']
    ident_file node['postgresql']['config']['ident_file']
    external_pid_file node['postgresql']['config']['external_pid_file']
    data_directory node['postgresql']['config']['data_directory']

    version new_resource.version
    port node['postgresql']['config']['port']

    additional_config node['postgresql']['additional_config']

    notifies :reload, 'service[postgresql]'
  end

  # Add the contrib package in Ubuntu/Debian
  package "postgresql-contrib-#{node['postgresql']['version']}"

  # Install adminpack extension
  postgresql_extension 'postgres adminpack' do
    database 'postgres'
    extension 'adminpack'
  end

end
