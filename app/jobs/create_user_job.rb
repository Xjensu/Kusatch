class CreateUserJob < ApplicationJob
  queue_as :default

  def perform(user_params)
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do
        user = User.new(user_params)
        
        if user.save
          Rails.cache.write("user_#{user.username}", user, expires_in: 1.hour)
          Rails.cache.delete('all_users')
          Rails.logger.info "User succesfully create"
        else
          raise ActiveRecord::Rollback, "Invalid user data"
        end
      end
    end
  rescue => e
    Rails.logger.error "User creation failed: #{e.message}"
    raise
  end
end