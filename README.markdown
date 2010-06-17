PeriodicCounter
===============

Maintains period fields on any counter column in your database

Requirements
------------

<pre>
sudo gem install periodic_counter
</pre>

Create columns
--------------

You should already have a counter column (let's call it X) that is being incremented by some external process.

Add an <code>X_data</code> varchar column with a length of 2048.

Add your periodic counters (all integers):

* <code>X\_last\_week</code>
* <code>X\_last\_6\_hours</code>
* <code>X\_last_sunday</code>

Currently only days of the week and [ActiveSupport's time extensions](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Numeric/Time.html) are supported for text after <code>X_last</code>. If no digit is present, "1" is assumed.

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