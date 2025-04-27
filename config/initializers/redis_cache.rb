if ENV['REDIS_URL'].present?
  redis_config = {
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    timeout: 5,
    reconnect_attempts: 3
  }
else
  redis_config = {
    host: ENV.fetch('REDIS_HOST', 'localhost'),
    port: ENV.fetch('REDIS_PORT', 6379),
    db: ENV.fetch('REDIS_DB', 0),
    timeout: 5,
    reconnect_attempts: 3
  }
end

# Для кэширования
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    **redis_config,
    namespace: "blog_app:cache:#{Rails.env}",
    compress: true,
    expires_in: 1.day,
    compress_threshold: 1.kilobyte
  }
end

# Глобальное подключение Redis
RedisCache = Redis.new(redis_config)
