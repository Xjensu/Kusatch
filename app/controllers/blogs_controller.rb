class BlogsController < ApplicationController
  skip_before_action :authorized, only: [:index, :show]
  
  before_action :set_blog, only: [:show, :update, :destroy]
  before_action :authorize_blog, only: [:update, :destroy]

  # GET /blogs
  def index
    page = [params[:page].to_i, 1].max
    @blogs = Blog.order(created_at: :desc).page(page).per(25)
    cache_key = "blogs/page:#{page}"

    cached_data = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      serialized_data = BlogSerializer.new(@blogs).serializable_hash
      meta = pagination_meta(@blogs)

      { data: serialized_data, meta: meta }
    end
    render200 data: cached_data[:data], meta: cached_data[:meta]
  end

  # GET /blogs/:id
  def show
    cache_key = "blog/#{@blog.id}/with_associations/v1/#{@blog.updated_at.to_i}"
    cached_data = Rails.cache.fetch(cache_key) do
      BlogShowSerializer.new(@blog, include: [:user, :comments]).serializable_hash
    end

    render200 data: cached_data
  rescue ActiveRecord::RecordNotFound
    render404 data: { error: "Blog not found" }
  end

  # POST /blog
  def create
    CreateBlogJob.perform_later(create_params.merge(user_id: current_user.id))
    Rails.cache.delete_matched("blogs/page:*")
    render202 data: { message: "Blog creation started" }
  end

  # DELETE /blogs/:id
  def destroy
    @blog.clear_cache
    @blog.destroy!
    render202 data: { message: "Blog deleted successfully" }
  end

  # PATCH/PUT /blogs/:id
  def update
    if @blog.update(update_params)
      @blog.clear_cache
      render200 message: "Blog updated successfully"
    else
      render422 errors: @blog.errors.full_messages
    end
  end

  private

  def create_params
    params.require(:blog).permit(:title, :description, :content)
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      total_pages: object.total_pages,
      total_count: object.total_count,
      per_page: object.limit_value,
      next_page: object.next_page,
      prev_page: object.prev_page
    }
  end

  def set_blog
    @blog = Blog.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render404 data: { error: "Blog not found" }
  end

  def update_params
    params.require(:blog).permit(:title, :description, :content)
  end

  def authorize_blog
    unless @blog.user == current_user
      render403 data: { error: "Not authorized" }
    end
  end
end
