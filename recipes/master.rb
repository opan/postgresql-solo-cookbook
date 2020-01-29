app_name = node.app_name

postgresql_wrapper_setup_master app_name do
  version node[app_name]["postgresql"]["version"]
  database_databag_name app_name
  database_username_variable "db_user"
end

postgresql_wrapper_setup_user app_name do
  replication true
  database_databag_name app_name
  database_username_variable "db_user"
end

include_recipe 'postgresql_wrapper::_apt'

