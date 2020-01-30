property :app, String, name_property: true, required: true

default_action :setup

action :setup do
  library_logrotate app do
    log_path "/var/log/postgresql/*.log"
    frequency "hourly"
    size "500M"
  end
end
