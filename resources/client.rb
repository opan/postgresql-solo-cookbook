include PostgresqlSoloCookbook::Constants

property :version, String, equal_to: VERSIONS, required: true

default_action :install

action :install do
  postgresql_client_install 'PostgreSQL Client install' do
    version new_resource.version
  end
end

