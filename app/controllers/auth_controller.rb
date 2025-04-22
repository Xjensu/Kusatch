class AuthController < ApplicationController
  skip_before_action :authorized, only: [:login]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  def login

    auth_params = login_params

    user = User.find_by!(email: auth_params[:email])
    if user&.authenticate(auth_params[:password])
      token = encode_token(user_id: user.id)
      render202 data: { token: token }
    else
      render401 data: { error: 'Invalid credintails' }
    end
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def handle_record_not_found
    render401 data: { message: "User doesn't exist" }
  end

  def handle_parameter_missing
    render401 data: { message: 'Missing auth parameters' }
  end
end