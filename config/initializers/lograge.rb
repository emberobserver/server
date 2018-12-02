require 'lograge/sql/extension'

Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.formatter = Class.new do |fmt|
    def fmt.call(data)
      data.merge(log_type: 'request')
    end
  end

  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params].reject { |k| %w(controller action).include?(k) }
    {
      params: params,
    }
  end

  # Lograge SQL:
  config.lograge_sql.extract_event = Proc.new do |event|
    { name: event.payload[:name], duration: event.duration.to_f.round(2), sql: event.payload[:sql] }
  end
  config.lograge_sql.formatter = Proc.new do |sql_queries|
    sql_queries
  end
end
