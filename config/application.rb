require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EmberObserverServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.action_mailer.smtp_settings = {
      address: 'smtp.mailgun.org',
      port: 587,
      user_name: Rails.application.secrets.smtp_username,
      password: Rails.application.secrets.smtp_password
    }

    unless Rails.env.test?
      require 'ember_observer_server/logger'
      require 'ember_observer_server/readable_logger'
      file_logger = EmberObserverServer::Logger.new(config.paths['log'].first)
      console_logger  = EmberObserverServer::ReadableLogger.new(STDOUT)
      console_logger.extend(Ougai::Logger.broadcast(file_logger))
      config.logger = console_logger
    end
  end
end
