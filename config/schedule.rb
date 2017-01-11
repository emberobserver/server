# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :command_in_dir, "cd :path && source .env && :task :output"

set :output, "log/cron_log.log"

every 1.day, at: '0900' do
  rake "search:prepare"
end

every 1.hour, at: 20 do
  rake "addons:update:all"
end

every 1.day, at: '0400' do
 rake "tests:queue_canary_tests"
end

every 1.day, at: '0545' do
  rake "npm:import_downloads"
end

every 1.day, at: '0800' do
  command_in_dir "cd vendor/backup && bundle exec backup perform --config-file=./config.rb -t ember_observer && curl ${BACKUP_SNITCH_URL}"
end
