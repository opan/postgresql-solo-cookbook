property :app, String, name_property: true, required: true
property :version, String, equal_to: ['9.4', '9.5', '9.6', '10', '11', '12'], required: true
property :replicated,
property :slave_search_query, String
property :database_databag_name, String, default: "postgresql"
property :database_username_variable, String, default: "username"

default_action :setup

action :setup do
  unless slave_search_query.nil?
    slave_node = search(:node, slave_search_query).first
    unless slave_node.nil?
      postgresql_solo_pghba_config app do
        ip_address slave_node.ipaddress
        database_databag_name new_resource.database_databag_name
      end
    end
  end

  postgresql_solo_server app do
    version new_resource.version
    database_databag_name new_resource.database_databag_name
  end

  postgresql_solo_setup_user app do
    replication !new_resource.slave_search_query.nil?
    database_databag_name new_resource.database_databag_name
    database_username_variable new_resource.database_username_variable
  end

  postgresql_solo__laundry app do
    database_databag_name new_resource.database_databag_name
  end
end
