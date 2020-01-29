module PostgresqlWrapperCookbook
  module Helpers
    def psql_command_string(config, query, grep_for: nil, value_only: false)
      cmd = "echo #{config[:password]} | "
      cmd << "/usr/bin/psql -c \"#{query}\""
      cmd << " -d #{config[:database]}" if config[:database]
      cmd << " -U #{config[:user]}"
      cmd << " -h #{config[:host]}"
      cmd << " -p #{config[:port]}" if config[:port]
      cmd << ' --tuples-only' if value_only
      cmd << " | grep #{grep_for}" if grep_for
      cmd
    end

    def createdb_command_string(config, database)
      createdb = "echo #{config[:password]} | "
      createdb << 'createdb'
      createdb << " -U #{config[:user]}" if config[:user]
      createdb << " -h #{config[:host]}" if config[:host]
      createdb << " -p #{config[:port]}" if config[:port]
      createdb << " #{database}"
    end

    def create_user_command_string(config, username, password, replication: nil)
      query = "CREATE USER \"#{username}\""
      query << " WITH PASSWORD '#{password}'"
      query << " #{replication ? 'REPLICATION' : 'NOREPLICATION'}" unless replication.nil?
      psql_command_string(config, query)
    end
  end
end
