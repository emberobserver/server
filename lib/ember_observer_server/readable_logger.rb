# frozen_string_literal: true

module EmberObserverServer
  class ReadableLogger < Logger
    def create_formatter
      Ougai::Formatters::Readable.new
    end
  end
end
