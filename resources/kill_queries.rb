property :app,    String,  name_property: true,	required: true
property :query_time, String, required: true
property :database_name, String, required: true

default_action :create

action :create do
	template "/opt/kill_queries.sh" do
	    cookbook "postgresql_solo"
	    source "kill_queries.sh.erb"
	    mode "777"
	    variables(database_name: database_name, query_timeout: query_time)
	end
end
