require "active_support/core_ext/integer/time"

Rails.application.configure do
  
  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.active_storage.service = :local

  config.assume_ssl = true

  config.force_ssl = true

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"

  config.active_support.report_deprecations = false

  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    password: ENV['REDIS_PASSWORD'],
    namespace: "cache",
    expires_in: 1.day,
    pool: {
      size: 10,
      timeout: 5
    }
  }
  
  config.action_mailer.default_url_options = { host: "example.com" }

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  config.require_master_key = true

  config.action_dispatch.show_exceptions = true

end
