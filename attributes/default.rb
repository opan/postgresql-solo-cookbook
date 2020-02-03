
default['postgresql']['version']                              = '12'

default['postgresql']['config']['dir']                        = "/etc/postgresql/#{node['postgresql']['version']}/main"
default['postgresql']['config']['hba_file']                   = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
default['postgresql']['config']['ident_file']                 = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
default['postgresql']['config']['external_pid_file']          = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
default['postgresql']['config']['unix_socket_directories']    = '/var/run/postgresql'
default['postgresql']['config']['data_directory']             = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
default['postgresql']['config']['host'] = 'localhost'
default['postgresql']['config']['port']             = 5432

default['postgresql']['network_config']['allowed_subnet']    = "127.0.0.1/32"

default['postgresql']['additional_config']['listen_addresses']          = '*'
default['postgresql']['additional_config']["timezone"]                   = 'Asia/Jakarta'
default['postgresql']['additional_config']['log_timezone']               = 'Asia/Jakarta'
default['postgresql']['additional_config']['dynamic_shared_memory_type'] = "posix"
default['postgresql']['additional_config']['checkpoint_segments']        = 16
default['postgresql']['additional_config']['log_line_prefix']            = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h  '
default['postgresql']['additional_config']["autovacuum"]                 = "on"
default['postgresql']['additional_config']["track_counts"]               = "on"
default["postgresql"]["additional_config"]["max_connections"]            = 1000

# replication
default['postgresql']['additional_config']["wal_level"]                      = "hot_standby"
default['postgresql']['additional_config']["archive_mode"]                   = "on"
default['postgresql']['additional_config']["archive_command"]                = "cd ."
default['postgresql']['additional_config']["log_min_duration_statement"]     = 70    #in milliseconds
default['postgresql']['additional_config']["max_wal_senders"]                = "8"
default['postgresql']['additional_config']["hot_standby"]                    = "on"
default['postgresql']['additional_config']['wal_keep_segments']              = 50
default['postgresql']['additional_config']['log_connections']                = 'on'
default['postgresql']['additional_config']['log_disconnections']             = 'on'
default['postgresql']['additional_config']['log_checkpoints']                = 'on'
default['postgresql']['additional_config']['log_lock_waits']                 = 'on'
default['postgresql']['additional_config']['log_temp_files']                 = 0


default['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'trust'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'trust'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => "#{node["postgresql"]['network_config']["allowed_subnet"]}", :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => "#{node["ipaddress"].split(".")[0]}.#{node["ipaddress"].split(".")[1]}.0.0/16", :method => 'md5'},
  {:type => 'host', :db => 'replication', :user => 'rep', :addr => "#{node["ipaddress"].split(".")[0]}.#{node["ipaddress"].split(".")[1]}.0.0/16", :method => 'trust'}
]
