include PostgresqlSoloCookbook::Constants

property :app, String, name_property: true, required: true
property :version, String, equal_to: VERSIONS, required: true
property :host, [String, nil], default: nil
property :port, Integer
property :dbname, String, required: true
property :dbpass, String, required: true
property :dbuser, String, required: true
property :dbuser_pass, String, required: true

# Replication
property :replication, kind_of: [TrueClass, FalseClass], default: false
property :repuser, String, default: REPUSER
property :repuser_pass, String, default: REPUSER_PASS

property :hba_file, String
property :ident_file, String
property :external_pid_file, String
property :additional_config, Hash
property :data_directory, String

property :pg_hba, Array, required: true
property :pg_hba_replica, Array, default: []

default_action :setup

action :setup do
  postgresql_server_install 'postgresql' do
    hba_file new_resource.hba_file
    ident_file new_resource.ident_file
    external_pid_file new_resource.external_pid_file
    password new_resource.dbuser_pass
    port new_resource.port
    version new_resource.version
    setup_repo true

    action [:install, :create]
  end

  new_resource.pg_hba.each do |hba|
    postgresql_access 'default pg_hba access' do
      access_type hba['type']
      access_db hba['db']
      access_user hba['user']
      access_addr hba['addr']
      access_method hba['method']

      notifies :reload, 'service[postgresql]'
    end
  end

  postgresql_user new_resource.dbuser do
    superuser true
    password new_resource.dbuser_pass
    sensitive true
  end

  # Replication
  if new_resource.replication == true
    repuser = new_resource.repuser

    postgresql_user repuser do
      replication true
      login true
      password new_resource.repuser_pass
      sensitive true
    end

    directory "#{new_resource.data_directory}/archive/" do
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
    data_directory new_resource.data_directory

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
    host new_resource.host
    port new_resource.port
  end
end
