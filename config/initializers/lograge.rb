Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action]

    {
      params: event.payload[:params].except(*exceptions)
    }
  end
end