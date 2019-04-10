# frozen_string_literal: true

class Api::V1::UserSessionsController < Devise::SessionsController
  skip_before_action :authenticate_user_token!, only: :create
  skip_before_action :verify_signed_out_user

  swagger_controller :user_sessions, "User login management"

  swagger_api :create do
    summary 'User authentication'
    notes 'Authenticate a user to the application and returns back authentication token'
    param :form, :'user[email]', :string, :required, 'Email'
    param :form, :'user[password]', :password, :required, 'Password'
    response :created
    response :unauthorized
  end
  def create
  end

  swagger_api :destroy do
    summary 'Signout a user'
    notes 'Removes the authentication token of an user'
    response :ok
    response :unauthorized
    response :bad_request
  end
  def destroy
    Rails.cache.delete User.cached_api_key(request.env['HTTP_X_API_KEY'])
    head :ok
  end
end
