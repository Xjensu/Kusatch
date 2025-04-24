class CommetnController < ApplicationController
  def create
    # @comment = Comment.new(create_params)
  end

  private 

  def create_params
    params.require[:comment].permit(:blog_id, :text)
  end
end