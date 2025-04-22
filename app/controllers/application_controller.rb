class ApplicationController < ActionController::API
  include RenderMethods
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
  
  def decoded_token
    header = request.headers['Authorization']
    return unless header
  
    token = header.split(" ")[1]
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
  rescue JWT::DecodeError
    nil
  end

  def current_user
    @current_user ||= begin
      if decoded_token
        user_id = decoded_token[0]['user_id']
        begin
          User.find(user_id)
        rescue ActiveRecord::RecordNotFound
          nil
        end
      end
    end
  end

  def authorized
    unless !!current_user
      render401 data: { message: "Please Log in" }
    end
  end
end