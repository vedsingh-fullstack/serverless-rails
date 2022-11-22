# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'http://127.0.0.1:9000/'

  # Required to capture raven_context which is no longer capture by default
  # https://docs.sentry.io/platforms/ruby/migration/#exceptionraven_context
  config.before_send = lambda do |event, hint|
    exception = hint[:exception]
    if exception && exception.respond_to?(:raven_context)
      exception.raven_context.each do |key, value|
        event.send("#{key}=", value)
      end
    end

    filter.filter(event.to_hash)
  end
end
