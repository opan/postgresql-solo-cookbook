app_name = node.app_name

postgresql_wrapper_setup_slave app_name do
  version node[app_name]["postgresql"]["version"]
  database_databag_name app_name
  database_username_variable "db_user"
  master_ip node[app_name]["postgresql"]["master_ip"]
end

include_recipe 'postgresql_wrapper::_apt'

