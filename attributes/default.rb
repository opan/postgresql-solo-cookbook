
default['postgresql']['version']                              = '9.6'

default['postgresql']['config']['dir']                        = "/etc/postgresql/#{node['postgresql']['version']}/main"
default['postgresql']['config']['hba_file']                   = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
default['postgresql']['config']['ident_file']                 = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
default['postgresql']['config']['external_pid_file']          = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
default['postgresql']['config']['unix_socket_directories']    = '/var/run/postgresql'
default['postgresql']['config']['data_directory']             = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
default['postgresql']['config']['host']                       = nil
default['postgresql']['config']['port']                       = 5432
default['postgresql']['config']['dbname']                     = 'default-db'
default['postgresql']['config']['dbpass']                     = 'securepassword'
default['postgresql']['config']['dbuser']                     = 'default-user'
default['postgresql']['config']['dbuser_pass']                = 'securepassword'

default['postgresql']['network_config']['allowed_subnet']    = '127.0.0.1/32'

default['postgresql']['additional_config']['listen_addresses']          = '*'
default['postgresql']['additional_config']['timezone']                   = 'Asia/Jakarta'
default['postgresql']['additional_config']['log_timezone']               = 'Asia/Jakarta'
default['postgresql']['additional_config']['dynamic_shared_memory_type'] = 'posix'
default['postgresql']['additional_config']['log_line_prefix']            = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h  '
default['postgresql']['additional_config']['autovacuum']                 = true
default['postgresql']['additional_config']['track_counts']               = 'on'
default["postgresql"]["additional_config"]['max_connections']            = 1000

#
# Replication related config
#
default['postgresql']['replication'] = false
default['postgresql']['config']['repuser'] = 'rep'
default['postgresql']['config']['repuser_pass'] = 'securepassword'

# This must be set when setting up slave server
default['postgresql']['config']['master_ip'] = nil

default['postgresql']['additional_config']['archive_mode']                  = 'on'
default['postgresql']['additional_config']['archive_command']               = "cp %p #{node['postgresql']['config']['data_directory']}/archive/%f"

# `hot_standby` should be enabled only for slave server
# Values: `on`, `off`
default['postgresql']['additional_config']['hot_standby']                   = nil


# `wal_level` determines how much information is written to the WAL
# Values: `minimal`, `replica`, `logical`
# In releases prior to 9.6, this parameter also allowed the values archive and hot_standby.
# These are still accepted but mapped to replica.
default['postgresql']['additional_config']['wal_level']                 = 'hot_standby'
default['postgresql']['additional_config']['max_wal_senders']           = 8
default['postgresql']['additional_config']['wal_keep_segments']         = 50
default['postgresql']['additional_config']['log_connections']           = 'on'
default['postgresql']['additional_config']['log_disconnections']        = 'on'
default['postgresql']['additional_config']['log_checkpoints']           = 'on'
default['postgresql']['additional_config']['log_lock_waits']            = 'on'
default['postgresql']['additional_config']['log_temp_files']            = 0

# In milliseconds
default['postgresql']['additional_config']['log_min_duration_statement']     = 70


# Default pg_hba.conf
default['postgresql']['pg_hba'] = [
  {type: 'local', db: 'all', user: 'all', addr: nil, method: 'trust'},
  {type: 'host', db: 'all', user: 'all', addr: '127.0.0.1/32', method: 'trust'},
  {type: 'host', db: 'all', user: 'all', addr: '::1/128', method: 'md5'},
  {type: 'host', db: 'all', user: 'all', addr: "#{node['postgresql']['network_config']["allowed_subnet"]}", method: 'md5'},
  {type: 'host', db: 'all', user: 'all', addr: "#{node['ipaddress'].split(".")[0]}.#{node["ipaddress"].split(".")[1]}.0.0/16", method: 'md5'},
]

# `pg_hba` for replication
default['postgresql']['pg_hba_replica'] = []
