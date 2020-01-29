property :version, String, equal_to: ['9.4', '9.5', '10', '11', '12'], required: true

default_action :install

action :install do
  postgresql_client_install 'PostgreSQL Client install' do
    version new_resource.version
  end
end

