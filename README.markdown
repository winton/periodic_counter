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

You should already have a counter column defined that is being incremented by something (let's call the column X).

Define period columns using this format: <code>X\_last\_week</code> or <code>X\_last\_6\_hours</code>.

The period name should follow the format of [ActiveSupport's time extensions](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Numeric/Time.html).

Also add an <code>X_data</code> varchar column with a length of 2048.

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