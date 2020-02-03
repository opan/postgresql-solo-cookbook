property :app, String, name_property: true, required: true
property :database, String, required: true
property :username, String, required: true
property :password, String, required: true
property :replication, kind_of: [TrueClass, FalseClass], default: false
property :replication_username, String, default: "rep"
property :replication_password, String

default_action :setup

action :setup do
  node_host = node['hostname']
  if node['postgresql']['cloud_provider'] == 'aws'
    node_host = node['ipaddress']
  end

  postgresql_user "#{new_resource.username}" do
    password new_resource.password
    createdb true
  end

  if node_host.empty? || node_host.nil?
    node_host = node['postgresql']['config']['host']
  end

  postgresql_database "#{new_resource.database}" do
    owner new_resource.username
    host node_host
    port node['postgresql']['config']['port']
  end

  postgresql_user new_resource.replication_username do
    password new_resource.replication_password
    replication true
    only_if { new_resource.replication == true }
  end
end

