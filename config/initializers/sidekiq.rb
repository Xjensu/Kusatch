Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_URL'],
    password: ENV['REDIS_PASSWORD'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 10
  }

  # Явное подключение к PostgreSQL
  ActiveRecord::Base.establish_connection(
    adapter:  'postgresql',
    host:     ENV['POSTGRES_HOST'],
    database: ENV['POSTGRES_DB'],
    username: ENV['POSTGRES_USER'],
    password: ENV['POSTGRES_PASSWORD'],
    port:     ENV['POSTGRES_PORT'] || 5432
  )
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV['REDIS_URL'],
    password: ENV['REDIS_PASSWORD'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 10
  }
end


