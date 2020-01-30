property :app, String, name_property: true, required: true
property :version, String, equal_to: ['9.4', '9.5', '9.6', '10', '11', '12'], required: true
property :root_password, [String, nil], default: 'generate' # Set to nil if we do not want to set a password
property :database, String, required: true
property :username, String, required: true
property :password, String, required: true
property :master_ip, String, required: true
property :replica_username, String, required: true
property :replica_password, String, required: true

default_action :setup

action :setup do

  postgresql_solo_server "#{new_resource.app}" do
    version new_resource.version
    password new_resoures.root_password
  end

  postgresql_solo_setup_user "#{new_resource.app}" do
    database new_resource.database
    username new_resource.username
    password new_resource.password
  end

  bash 'initial db buildup for replication' do
    code <<-EOH
      sudo service postgresql stop
      sudo -u postgres rm -rf /var/lib/postgresql/#{new_resource.version}/main
      sudo -u postgres pg_basebackup -h #{new_resource.master_ip} -D /var/lib/postgresql/#{new_resource.version}/main -U #{new_resource.replica_username} -v -P
      touch /var/log/fake.txt
    EOH
    timeout 18000
    not_if { ::File.exists?('/var/log/fake.txt') }
  end

  template "/var/lib/postgresql/#{new_resource.version}/main/recovery.conf" do
    source "recovery.conf.erb"
    cookbook "postgresql_solo"
    variables(
        standby_mode: 'on',
        primary_conninfo: "host=#{new_resource.master_ip} port=5432 user=#{new_resource.replica_username} password=#{new_resource.replica_password}",
        trigger_file: '/tmp/postgresql.trigger.5432'
    )
    owner 'postgres'
    group 'postgres'
    notifies :start, 'service[postgresql]', :immediately
  end

  service "postgresql" do
    action :nothing
  end

  postgresql_solo__laundry "#{new_resource.app}" do
  end

end
