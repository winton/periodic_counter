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
            period = columns.select do |col|
              col =~ /^#{column}/ &&
              col != column &&
              !col.include?('computed_at') &&
              !col.include?('starting_value')
            end
            select_columns = [ 'id', column, "#{column}_computed_at", "#{column}_starting_value" ] + period
            select_columns &= columns
            records = ActiveRecord::Base.connection.select_all <<-SQL
              SELECT #{select_columns.join(', ')}
              FROM #{table}
            SQL
            records.each do |record|
              id = record.delete('id')
              computed_at = ActiveRecord::ConnectionAdapters::Column.string_to_time(
                record.delete("#{column}_computed_at")
              )
              count = record.delete(column).to_i
              time_since_compute = Time.now.utc - computed_at.utc
              if record.keys.include?("#{column}_starting_value")
                unless record["#{column}_starting_value"]
                  record["#{column}_starting_value"] = count
                end
                starting_value = record["#{column}_starting_value"].to_i
              end
              starting_value ||= 0
              period.each do |col|
                period_count = record[col].to_i
                duration = column_to_period_integer(col)
                if (time_since_compute - duration) >= 0
                  record[col] = count - period_count - starting_value
                end
              end
              set = record.collect { |col, value| "#{col} = #{value}" }
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
