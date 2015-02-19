# encoding: utf-8

require 'dotenv'

app_path="/srv/app/ember-site/server"
Dotenv.load "#{app_path}/shared/.env"
db_config=YAML.load(ERB.new(File.read("#{app_path}/current/config/database.yml")).result)['production']
backup_config=YAML.load_file("#{app_path}/shared/backup.yml")
##
# Backup Generated: ember_observer
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t ember_observer [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:ember_observer, 'Description for ember_observer') do

  database PostgreSQL do |db|
    db.name     = db_config['database']
    db.username = db_config['username']
    db.password = db_config['password']
    db.host     = db_config['host']
  end

  store_with Local do |local|
    local.path = '~/backups'
    local.keep = 5
  end

  ##
  # Bzip2 [Compressor]
  #
  compress_with Bzip2

  notify_by Slack do |slack|
    slack.on_success = true
    slack.on_warning = true
    slack.on_failure = true

    slack.webhook_url = backup_config['slack_url']
  end

end
