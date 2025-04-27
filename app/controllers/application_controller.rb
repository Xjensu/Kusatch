class ApplicationController < ActionController::API
  include RenderMethods
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authorized
  before_action do
    @request_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
  
  after_action do
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @request_start_time
    Rails.logger.info "[PERF] #{controller_name}##{action_name} took #{duration.round(2)}s"
  end
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

  def handle_record_not_found(exception)
    render404 message: "Record doesn't exist"
  end

  def user_not_authorized
    render403 data: { error: "You are not authorized to perform this action." }
  end
end