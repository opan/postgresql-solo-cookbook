property :app, String, name_property: true, required: true
property :version, String, equal_to: ['9.4', '9.5', '9.6', '10', '11', '12'], required: true
property :root_password, [String, nil], default: 'generate' # Set to nil if we do not want to set a password
property :database, String, required: true
property :username, String, required: true
property :password, String, required: true
property :replication, kind_of: [TrueClass, FalseClass], default: false
property :replication_username, String, default: "rep"
property :replication_password, String

default_action :setup

action :setup do

  postgresql_solo_server "#{new_resource.app}" do
    version new_resource.version
    password new_resoures.root_password
  end

  postgresql_solo_setup_user "#{new_resource.app}" do
    replication new_resource.replication
    replication_password new_resource.replication_password
    database new_resource.database
    username new_resource.username
    password new_resource.password
  end

  postgresql_solo__laundry "#{new_resource.app}" do
  end
end
