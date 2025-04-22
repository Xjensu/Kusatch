require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Kursatch
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.refresh_token_lifetime = 1.minutes

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::ContentSecurityPolicy::Middleware
    config.middleware.use ActionDispatch::Session::CookieStore,
      key: '_kursatch_session',
      same_site: :lax,
      secure: Rails.env.production?
    config.active_job.queue_adapter = :sidekiq

  end
end
