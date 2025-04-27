class AuthController < ApplicationController  
  
  skip_before_action :authorized, only: [:login]
  
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from JSON::ParserError, with: :handle_json_parse_error
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error
  rescue_from StandardError, with: :handle_generic_error

  # curl -X POST -H "Content-Type: application/json" -d '{ "user": { "password": "123456", "username": "xjnsu"} }' http://localhost/auth/login
  def login
    auth_params = login_params
    user = User.find_by(username: auth_params[:username])
    
    if user&.valid_password?(auth_params[:password])
      token = encode_token(user_id: user.id)
      render202 data: { token: token }
    else
      render401 data: { error: 'Invalid credentials' }
    end
  end

  private

  def login_params
    params.require(:user).permit(:username, :password)
  end

  def handle_record_not_found(exception)
    render401 message: "User doesn't exist"
  end

  def handle_parameter_missing(exception)
    render400 message: 'Missing auth parameters'
  end

  def handle_json_parse_error(exception)
    render400 message: 'Invalid request format'
  end

  def handle_parse_error(exception)
    render400 message: 'Invalid request parameters'
  end

  def handle_generic_error(exception)
    logger.error "Auth Error: #{exception.message}\n#{exception.backtrace.join("\n")}"
    render500 message: 'Authentication failed'
  end
end