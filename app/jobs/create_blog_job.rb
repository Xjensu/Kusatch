class CreateBlogJob < ApplicationJob
  queue_as :default

  def perform(blog_params)
    user_id = blog_params[:user_id]

    ActiveRecord::Base.connection_pool.with_connection do
      user = begin
               User.find(user_id)
             rescue ActiveRecord::RecordNotFound
               Rails.logger.error "User with ID #{user_id} not found"
               return
             end

      blog = user.blogs.new(
        title: blog_params[:title],
        description: blog_params[:description],
        content: blog_params[:content]
      )

      Pundit.authorize(user, blog, :create?)

      if blog.save
        Rails.logger.info "Blog created: #{blog.title} (ID: #{blog.id})"
      else
        Rails.logger.error "Failed to create blog: #{blog.errors.full_messages}"
      end
    end
  rescue Pundit::NotAuthorizedError => e
    Rails.logger.error "Authorization failed: #{e.message}"
  rescue => e
    Rails.logger.error "Error in CreateBlogJob: #{e.message}\n#{e.backtrace.join("\n")}"
  end
end