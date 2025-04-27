class UsersController < ApplicationController
  # TODO: Написать логику подтверждения создания пользователя через email
  skip_before_action :authorized, only: [:create, :show]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  before_action :set_user, only: [:update, :destroy]

  #❯ curl -X POST -H "Content-Type: application/json" -d '{ "user": { "email": "testmail@gmail.com", "password": "1234567", "password_confirmation":"1234567", "username": "xjensu", "first_name": "Первое имя", "last_name": "Последнее имя"} }' http://localhost/register
  def create
    user = User.new(create_params)
    
    if user.save
      render201 data: { message: 'Registration successful. Please login.' }
    else
      errors = user.errors.messages.transform_values { |msgs| msgs.join(', ') }
      render422 data: { message: "Could not create user.", errors: errors }
    end
  end

  # curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.x7TFgYQMgujNSz7xhoc0QfEXHVW8en2NUBwEwUT8wyI" http://localhost/me 
  def me
    user_data = UserPrivateSerializer.new(current_user, include: [:blogs]).serializable_hash
    render200 data: user_data
  end

  # curl -X GET -H "Content-Type: application/json" http://localhost/user/1 
  def show
    cache_key = "user/#{params[:id]}/#{User.find(params[:id]).updated_at.to_i}"
    
    user_data = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      @user = User.includes(:blogs).find(params[:id])
      serialized = UserSerializer.new(@user, include: [:blogs]).serializable_hash
      { data: serialized[:data], included: serialized[:included] }
    end
    
    render200 data: user_data
  end

  # curl -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.x7TFgYQMgujNSz7xhoc0QfEXHVW8en2NUBwEwUT8wyI" -d '{ "user": { "first_name": "Алексей", "last_name": "Бусько", "password":"123456", "password_confirmation": "123456", "current_password": "1234567" } }' http://localhost/user/update
  def update
    if @user.update_with_password(update_params)
      render200 data: { user: UserPrivateSerializer.new(@user), message: 'Profile updated successfully' }
    else
      render422 data: { errors: @user.errors.full_messages }
    end
  end

  # curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.x7TFgYQMgujNSz7xhoc0QfEXHVW8en2NUBwEwUT8wyI" http://localhost/user/delete
  def destroy
    if @user.destroy
      # Удаляем кэш пользователя, его блогов и комментариев
      Rails.cache.delete_matched("user/#{@user.id}/*")
      Rails.cache.delete_matched("blogs/*") # На случай, если у пользователя были блоги
      render200 data: { message: 'User deleted successfully' }
    else
      render422 data: { errors: @user.errors.full_messages }
    end
  end

  private

  def set_user
    @user = current_user
  end

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

  def update_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :username,
      :email,
      :password,
      :password_confirmation,
      :current_password
    )
  end
  
end