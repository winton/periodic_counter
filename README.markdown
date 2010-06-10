PeriodicCounter
===============

Maintains period fields on any counter column in your database

Requirements
------------

<pre>
sudo gem install periodic_template
</pre>

Create columns
--------------

For every counter column (X), you should also have a <code>X\_computed\_at</code> datetime column.

To define period columns, use this format: <code>X\_last\_1\_week</code> or <code>X\_last\_6\_hours</code>.

The name the period column should follow the format of ActiveSupport's time extensions:

http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Numeric/Time.html

If you are adding this to a counter that already has a count, you will also need a <code>X\_starting\_value</code> integer column.

Create configuration
--------------------

Create a file, <code>config/counters.yml</code>:

<pre>
my_table_name:
  - my_counter
</pre>

The plugin assumes that the <code>config</code> directory also houses your <code>database.yml</code> file.

Create cron entry
-----------------

Add the following command to your crontab at a period of your choosing:

<pre>
cd /path/to/your/app && RAILS_ENV=production periodic_counter
</pre>