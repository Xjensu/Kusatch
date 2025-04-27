require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Kursatch
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_paths << Rails.root.join('app/lib')

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.refresh_token_lifetime = 1.minute

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::ContentSecurityPolicy::Middleware
    config.middleware.use ActionDispatch::Session::CookieStore,
      key: '_kursatch_session',
      same_site: :lax,
      secure: Rails.env.production?

    config.active_job.queue_adapter = :sidekiq

    config.middleware.delete Rack::ETag
    config.middleware.delete Rack::ConditionalGet

    # Для ассинхронного логгирвания
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new
    config.lograge.ignore_actions = ['HealthCheckController#index']
    config.log_level = :info

    config.lograge.queue_size = 10_000
    config.lograge.worker_timeout = 5

    config.lograge.custom_options = lambda do |event|
      mem_before = event.payload[:memory_before] || 0
      mem_after = GetProcessMem.new.mb
    
      {
        time: event.time,
        duration: event.duration.round(2), # Время выполнения запроса
        memory_used_mb: (mem_after - mem_before).round(2), # Использованная память в МБ
        params: event.payload[:params].except(*%w[controller action]),
        request_id: event.payload[:headers]['action_dispatch.request_id'],
        user_id: event.payload[:headers]['HTTP_X_USER_ID']
      }
    end
  end
end