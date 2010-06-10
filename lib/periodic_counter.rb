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
      hash
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
            # Find period columns
            period = columns.select do |col|
              col =~ /^#{column}/ &&
              col != column &&
              !col.include?('_data')
            end
            # Grab all records
            select_columns = [ 'id', column, "#{column}_data" ]
            select_columns += period
            records = ActiveRecord::Base.connection.select_all <<-SQL
              SELECT #{select_columns.join(', ')}
              FROM #{table}
            SQL
            records.each do |record|
              id = record.delete('id')
              data = YAML::load(record["#{column}_data"] || '') || {}
              count = record.delete(column).to_i
              # Set period counters
              period.each do |col|
                computed_at = data["#{col}_at"] || Time.now.utc
                duration = column_to_period_integer(col)
                time_since_compute = Time.now.utc - computed_at
                starting_value = data[col].to_i
                if (time_since_compute - duration) >= 0
                  record[col] = count - starting_value
                  data[col] = count
                  data["#{col}_at"] = Time.now.utc
                else
                  data[col] ||= count
                  data["#{col}_at"] ||= Time.now.utc
                end
              end
              # Update record
              record["#{column}_data"] = "'#{YAML::dump(data)}'"
              set = record.collect { |col, value| "#{col} = #{value || 0}" }
              ActiveRecord::Base.connection.update <<-SQL
                UPDATE #{table}
                SET #{set.join(', ')}
                WHERE id = #{id}
              SQL
            end
          end
        end
      end
    end
  end
  
  def column_to_period_integer(column)
    column = column.split('_')[-2..-1]
    column[0] = column[0].to_i
    if column[0] == 0
      column[0] = 1
    end
    eval(column.join('.'))
  end
end
