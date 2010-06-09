require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.lib!

class PeriodicCounter
  
  def initialize(environment, root)
    @db, @log, @mail = ActiveWrapper.setup(
      :base => root,
      :env => environment
    )
    @db.establish_connection
    
    @tables = ActiveRecord::Base.connection.tables.inject({}) do |hash, table|
      hash[table] = ActiveRecord::Base.connection.columns(table).collect(&:name)
    end
    
    if File.exists?(counters_yml = "#{root}/config/counters.yml")
      @counters = YAML::load(File.open(counters_yml))
    else
      raise "#{counters_yml} not found"
    end
    
    @counters.each do |table, counters|
      columns = @tables[table]
      if columns
        columns.each do |column|
          if counters.include?(column)
            period_columns = columns.collect do |col|
              col =~ /^#{column}/ && !col.include?('computed_at')
            end
          end
        end
      end
    end
  end
end
