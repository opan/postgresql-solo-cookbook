property :app, String, name_property: true, required: true
property :replication, kind_of: [TrueClass, FalseClass], default: false
property :database, String, required: true
property :username, String, required: true
property :password, String, required: true

default_action :setup

action :setup do

  node_host = node.hostname
  if node['postgresql']['cloud_provider'] == "aws"
    node_host = node.ipaddress
  end

  postgresql_user "#{new_resource.username}" do
    password new_resource.password
    createdb true
  end

  postgresql_database "#{new_resource.database}" do
    owner new_resource.username
    host node_host
    port node['postgresql']['config']['port']
  end

  if replication == true
    postgresql_user "rep" do
      password new_resource.password
      replication true
    end
  end
end

