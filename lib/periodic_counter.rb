require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.lib!

class PeriodicCounter
  
  WEEKDAYS = %w(sunday monday tuesday wednesday thursday friday saturday)
  
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
              col =~ /_last_/
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
                if WEEKDAYS.include?(weekday = col.split('_last_')[1])
                  data["#{col}_before_today"] ||= 0
                  if self.class.weekday(weekday)
                    record[col] = count - data["#{col}_before_today"]
                  else
                    data["#{col}_before_today"] = count
                  end
                else
                  computed_at = data["#{col}_at"] || Time.now.utc
                  duration = column_to_period_integer(col)
                  time_since_compute = Time.now.utc - computed_at
                  last_day =
                    if col.include?('day')
                      self.class.today
                    elsif col.include?('week')
                      self.class.last_monday
                    elsif col.include?('month')
                      self.class.first_of_the_month
                    end
                  if (time_since_compute - duration) >= 0
                    data[col] = count
                    data["#{col}_at"] = last_day
                  else
                    data[col] ||= count
                    data["#{col}_at"] ||= last_day
                  end
                  record[col] = count - data[col].to_i
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
  
  class <<self
  
    def first_of_the_month(now=Time.now.utc.to_date)
      Date.new(now.year, now.month, 1).to_time(:utc)
    end
  
    def last_monday(now=Time.now.utc.to_date)
      wday = now.wday
      if wday == 0
        -6
      else
        diff = 1 - wday
      end
      Date.new(now.year, now.month, now.day + diff).to_time(:utc)
    end
  
    def today(now=Time.now.utc.to_date)
      Date.new(now.year, now.month, now.day).to_time(:utc)
    end
    
    def weekday(day)
      Time.now.utc.to_date.wday == WEEKDAYS.index(day)
    end
  end
end
