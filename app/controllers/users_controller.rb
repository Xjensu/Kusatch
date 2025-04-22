class UsersController < ApplicationController
  skip_before_action :authorized, only: [:create, :show]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record

  def create
    user = User.new(create_params)
    
    if user.save
      render201 data: { user: UserSerializer.new(user), message: 'Registration successful. Please login.' }
    else
      render422 data: { message: "Could'nt create user" }
    end
  end

  def me
    render200 data: { user: UserPrivateSerializer.new(current_user, include: [:blogs]) }
  end

  def show
    user = User.includes(:blogs).find(params[:id])
    if user
      render200 data: { user: UserSerializer.new(user, include: [:blogs]) } 
    else
      render404 data: { message: "User not found" }
    end
  end

  private

  def create_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :password_confirmation
    )
  end
end