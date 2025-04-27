class CacheCleanupJob < ApplicationJob
  def perform(pattern)
    RedisCache.pipelined do
      RedisCache.scan_each(match: pattern) do |key|
        RedisCache.del(key)
      end
    end
  end
end