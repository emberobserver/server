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

every 1.hour do
  rake "npm:fetch_addon_info"
  rake "addons:update_downloads_flag"
end

every 1.hour, at: 25 do
  rake "github:update_data"
  rake "addons:update_stars_flag"
end

every 1.day, at: '0800' do
  command_in_dir "cd vendor/backup && bundle exec backup perform --config-file=./config.rb -t ember_observer && curl ${BACKUP_SNITCH_URL}"
end
