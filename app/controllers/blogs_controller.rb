class BlogsController < ApplicationController
  # TODO: Добавить систему классов на топик (Например банальный комментарий оп типу "gem" бует являться классом, а "call" будет являться дизлайком)
  include Pundit::Authorization

  skip_before_action :authorized, only: [:index, :show, :popular]
  before_action :set_blog, only: [:show, :update, :destroy]

  def index
    cache_key = [
      "blogs/index",
      params[:page],
      Blog.maximum(:updated_at),
      I18n.locale,
      current_user&.role
    ].join(':')
    
    result = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      blogs = policy_scope(Blog)
        .includes(:user)
        .order(created_at: :desc)
        .page(params[:page]).per(25)

      {
        data: blogs.map { |b| BlogSerializer.new(b).as_json },
        meta: pagination_meta(blogs)
      }
    end
    
    render200 data: result[:data], meta: result[:meta]
  end

  def show
    authorize @blog
    
    cache_key = [
      "blog",
      @blog.cache_key,
      I18n.locale,
      current_user&.admin
    ].join(':')
    
    blog_data = Rails.cache.fetch(cache_key) do
      {
        permissions: {
          can_edit: policy(@blog).update?,
          can_destroy: policy(@blog).destroy?
        },
        blog: BlogSerializer.new(@blog).as_json
      }
    end
    
    render200 data: blog_data
  end

  # curl -X POST -H "Content-Type: application/json" -d '{ "blog": {"title": "Первый заголовок", "description": "Описание", "content": "Что-то умное пишу тип да"} }' -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0fQ.g3eG3BuQPv8AVFFkHixJ9HBdg1VHod71fcllpk9kZg8" http://localhost/blog
  def create
    @blog = current_user.blogs.new(create_params)
    authorize @blog

    if @blog.save
      render202 data: { message: "Blog created succesfully" }
    else 
      render422 data: { message: "Failed to create blog: #{@blog.errors.full_messages}" }
    end
  end

  # curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozfQ.xWvI7pANHIjOPDgF5dgeCYN-r2mp_6DisNMvIhxDmmE" http://localhost/blog/4
  def update
    authorize @blog
    if @blog.update(update_params)
      render200 message: "Blog updated successfully"
    else
      render422 errors: @blog.errors.full_messages
    end
  end

  def destroy
    authorize @blog
    if @blog.destroy
      render200 message: "Blog deleted successfully"
    else
      render422 errors: @blog.errors.full_messages
    end
  end

  # Получить 3 популярных блога недели
  def popular
    cache_key = [
      "blogs/popular/weekly",
      Comment.maximum(:updated_at),
      I18n.locale
    ].join(':')
    
    popular_blogs = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      blogs = Blog.top_weekly_by_likes
      
      if blogs.empty?
        # Если нет блогов с лайками, можно вернуть самые новые блоги
        Blog.where(created_at: 1.week.ago..Time.current)
            .order(created_at: :desc)
            .limit(3)
            .map { |blog| blog_attributes(blog, 0) }
      else
        blogs.map { |blog| blog_attributes(blog, blog.net_likes) }
      end
    end
    
    render200 data: popular_blogs
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

  def blog_attributes(blog, net_likes)
    {
      id: blog.id,
      title: blog.title,
      description: blog.description,
      net_likes: net_likes,
      created_at: blog.created_at.strftime("%Y-%m-%d")
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

  def cache_fragment(record)
    Rails.cache.fetch(record.cache_key_with_version) do
      BlogStaticSerializer.new(record).serializable_hash
    end
  end

end
