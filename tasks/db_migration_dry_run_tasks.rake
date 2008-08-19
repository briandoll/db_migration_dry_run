namespace :briandoll do
task :setup_migrate_dry do
  # Override execute
  ActiveRecord::Base.connection.class.class_eval <<-CODE
    alias_method :real_execute, :execute
    def execute(sql, name=nil)      
      case sql
      when /(SELECT|CREATE|INSERT).* schema_migrations/
        real_execute sql, name || []
      when /(SELECT|select|PRAGMA)/        
        real_execute sql, name || []
      else        
        puts "  SQL: " + sql                
      end
    end
  CODE
  # Don't set the schema version
  class ActiveRecord::Migrator
    def set_schema_version(version)
      # do nothing
    end
  end
  # Don't dump the schema
  class ActiveRecord::SchemaDumper
    def self.dump(connection=ActiveRecord::Base.connection, stream=STDOUT)
      # do nothing
    end
  end
  
  puts "** DRY RUN (Non-destructive) **"
end
end
namespace :db do
  namespace :migrate do
    desc "Run migrations without actually changing the database."
    task :dry_run => [:environment, 'briandoll:setup_migrate_dry', 'db:migrate']
  end
end

