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

job_type :command_in_dir, "cd :path && source .env && :task"

set :output, "log/cron_log.log"

every 1.hour, at: 5 do
  rake "addons:update_all"
end

every 1.hour, at: 25 do
  rake "addons:update_repos"
end

every 1.hour, at: 35 do
  rake "data:backfill_package_addon_ids"
end

every 1.hour, at: 45 do
  rake "addons:update_meta"
end

every 1.hour, at: 55 do
  rake "reviews:autoreview"
end

every 1.day, at: '0400' do
  rake "tests:queue_canary_tests"
  rake "tests:queue_tests"
end

every 1.day, at: '0530' do
  rake "ember_versions:update"
end

every 1.day, at: '0545' do
  rake "npm:import_downloads"
end

every 1.day, at: '0800' do
  command_in_dir "cd vendor/backup && bundle exec backup perform --config-file=./config.rb -t ember_observer && curl ${BACKUP_SNITCH_URL}"
end

every 1.day, at: '0900' do
  rake "search:prepare"
end
