property :app,                        String, name_property: true, required: true
property :version,                    String, equal_to: ['9.4', '9.5', '10', '11', '12'], required: true
property :master_search_query,        String
property :database_databag_name,      String, default: "postgresql"
property :database_username_variable, String, default: "username"
property :master_ip,                  String

default_action :setup

action :setup do
  if new_resource.master_ip
    master_ip = new_resource.master_ip
  elsif  node["postgresql"]["master_search_query"]
    master_ip = search(:node, node["postgresql"]["master_search_query"]).first.ipaddress
  else
    master_ip = search(:node, master_search_query).first.ipaddress
  end
  laundry_state_file = "/etc/postgresql/#{new_resource.version}/main/.laundry-done"

  postgresql_solo_pghba_config app do
    ip_address master_ip
    database_databag_name new_resource.database_databag_name
  end

  postgresql_solo_server app do
    version new_resource.version
    database_databag_name new_resource.database_databag_name
  end

  postgresql_solo_setup_user app do
    database_databag_name new_resource.database_databag_name
    database_username_variable new_resource.database_username_variable
  end

  if not ::File.exist?(laundry_state_file)
    postgresql_solo__laundry app do
      database_databag_name new_resource.database_databag_name
    end

    file laundry_state_file do
      content "#{app} - #{new_resource.version} - laundry recipe done once"
      mode '0644'
    end
  end

  case new_resource.database_databag_name
  when new_resource.app
    db_detail     = data_bag_item(new_resource.app, node.chef_environment)["environment_variables"]
  else
    db_detail     = data_bag_item(new_resource.database_databag_name, app)[node.chef_environment]
  end

  if node['postgresql']['extension']['install_uuid_ossp'].to_s == "true"
    postgresql_solo_install_uuid_ossp new_resource.app do
      action :setup
      database_databag_name new_resource.database_databag_name
    end
  end

  bash 'initial db buildup for replication' do
    code <<-EOH
      sudo service postgresql stop
      sudo -u postgres rm -rf /var/lib/postgresql/#{new_resource.version}/main
      sudo -u postgres pg_basebackup -h #{master_ip} -D /var/lib/postgresql/#{new_resource.version}/main -U #{db_detail["replication_user"]} -v -P
      touch /var/log/fake.txt
    EOH
    timeout 18000
    not_if { ::File.exists?('/var/log/fake.txt') }
  end

  template "/var/lib/postgresql/#{new_resource.version}/main/recovery.conf" do
    source "recovery.conf.erb"
    cookbook "postgresql_solo"
    variables(
      standby_mode:      'on',
      primary_conninfo:  "host=#{master_ip} port=5432 user=#{db_detail["replication_user"]} password=#{db_detail["replication_password"]}",
      trigger_file:      '/tmp/postgresql.trigger.5432'
    )
    owner 'postgres'
    group 'postgres'
    notifies :start, 'service[postgresql]', :immediately
  end

  service "postgresql" do
    action :nothing
  end
end
