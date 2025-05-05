class CommentsController < ApplicationController
  include Pundit::Authorization

  before_action :set_blog, only: [:index]
  before_action :set_comment, only: [:update, :destroy]
  skip_before_action :authorized, only: [:index]

  def index
    cache_key = [
      "blog/#{@blog.id}/comments_tree",
      @blog.comments.maximum(:updated_at),
      I18n.locale,
      current_user&.role
    ].join(':')
    
    comments_tree = Rails.cache.fetch(cache_key) do
      root_comments = @blog.comments.where(parent_comment_id: nil)
                           .includes(:user, comments: [:user])
                           .order(created_at: :desc)
      
      root_comments.map { |comment| format_comment_with_children(comment) }
    end
    
    render200 data: comments_tree
  end

  def create
    @comment = Comment.new(create_params)
    @comment.user = current_user
    authorize @comment
  
    if @comment.save
      render201 message: 'Comment create successfully'
    else
      render422 errors: format_errors(@comment.errors)
    end
  end

  def update
    authorize @comment
    if @comment.update(update_params)
      render200 message: 'Comment update successfully'
    else
      render422 errors: format_errors(@comment.errors)
    end
  end

  def destroy
    authorize @comment
    @comment.destroy
    render200 message: 'Comment deleted successfully'
  end

  private

  def format_comment_with_children(comment)
    {
      id: comment.id,
      text: comment.text,
      created_at: comment.created_at,
      commentator: comment.user.username,
      can_edit: current_user ? policy(comment).edit? : false,
      can_destroy: current_user ? policy(comment).destroy? : false,
      comments: comment.comments.order(created_at: :desc).map { |c| format_comment_with_children(c) }
    }
  end

  def format_errors(errors)
    errors.messages.transform_values { |msgs| msgs.join(', ') }
  end

  def notify_about_comment(comment)
    return unless comment.parent_comment_id.present?
    
    recipient = comment.parent_comment.user
    NotificationService.new_comment_reply(recipient, comment).deliver_later
  end

  def set_blog
    @blog = Blog.find(params[:blog_id])
  rescue ActiveRecord::RecordNotFound
    render404 message: 'Blog not found'
  end

  def set_comment
    @comment = Comment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render404 message: 'Comment not found'
  end

  def create_params
    params.require(:comment).permit(:parent_comment_id, :text).merge(blog_id: params[:id])
  end

  def update_params
    params.require(:comment).permit(:text)
  end
end