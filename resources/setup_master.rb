include PostgresqlSoloCookbook::Constants

property :app, String, name_property: true, required: true
property :version, String, equal_to: VERSIONS, required: true
property :root_password, [String, nil], default: 'generate' # Set to nil if we do not want to set a password
property :host, String, default: node['postgresql']['config']['host']
property :port, Integer, default: node['postgresql']['config']['port']
property :dbname, String, required: true
property :dbpass, String, required: true
property :username, String, required: true
property :password, String, required: true

# Replication
property :replication, kind_of: [TrueClass, FalseClass], default: false
property :repuser, String, default: node['postgresql']['config']['repuser']
property :repuser_pass, String, default: node['postgresql']['config']['repuser_pass']

property :hba_file, Array[Hash], required: true
property :hba_file_replica, [Array], default: []
property :ident_file, String, default: node['postgresql']['config']['ident_file']
property :external_pid_file, String, default: node['postgresql']['config']['external_pid_file']
property :additional_config, Hash, required: true

default_action :setup

action :setup do
  postgresql_server_install 'postgresql' do
    hba_file node['postgresql']['config']['hba_file']
    ident_file node['postgresql']['config']['ident_file']
    external_pid_file node['postgresql']['config']['external_pid_file']
    password node['postgresql']['config']['dbpass']
    port new_resource.port
    version new_resource.version
    setup_repo true

    action [:install, :create]
  end

  new_resource.hba_file.each do |hba|
    postgresql_access 'default pg_hba access' do
      access_type hba['type']
      access_db hba['db']
      access_user hba['user']
      access_addr hba['addr']
      access_method hba['method']

      notifies :reload, 'service[postgresql]'
    end
  end

  postgresql_user new_resource.username do
    superuser true
    password new_resource.password
    sensitive true
  end

  if new_resource.replication == true
    repuser = new_resource.repuser

    postgresql_user repuser do
      replication true
      login true
      password new_resource.repuser_pass
      sensitive true
    end

    directory "#{data_directory}/archive/" do
      owner 'postgres'
      group 'postgres'
      recursive true
      mode '0700'

      action :create
    end

    new_resource.pg_hba_replica.each do |item|
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

  postgresql_server_conf 'Configure Postgresql Server' do
    hba_file new_resource.hba_file
    ident_file new_resource.ident_file
    external_pid_file new_resource.external_pid_file
    data_directory data_directory

    version new_resource.version
    port new_resource.port

    additional_config new_resource.additional_config

    notifies :reload, 'service[postgresql]'
  end

  find_resource(:service, 'postgresql') do
    extend PostgresqlCookbook::Helpers
    service_name lazy { platform_service_name }
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end

  service 'postgresql' do
    extend PostgresqlCookbook::Helpers
    service_name lazy { platform_service_name }
    supports restart: true, status: true, reload: true
    action :restart
  end

  postgresql_database new_resource.dbname do
    owner new_resource.dbuser
    port new_resource.port
  end
end
