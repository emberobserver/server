# frozen_string_literal: true

module EmberObserverServer
  class Logger < Ougai::Logger
    include ActiveSupport::LoggerThreadSafeLevel
    include LoggerSilence

    def initialize(*args)
      super
      after_initialize if respond_to? :after_initialize
    end

    def create_formatter
      Ougai::Formatters::Bunyan.new
    end
  end
end
