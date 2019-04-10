class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :set_current_user
  before_action :authenticate_user_token!

  rescue_from CanCan::AccessDenied, with: :forbidden_access
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
  def set_current_user
    @current_user ||= User.from_api_key(request.headers["x-api-key"], true)
  end

  def authenticate_user_token!
    render_error_state('User not authenticated', :unauthorized) if @current_user.nil?
  end

  def forbidden_access
    render_error_state 'Access forbidden', :forbidden
  end

  def record_not_found
    render_error_state 'Not found', :not_found
  end

  def render_error_state(err_msg, status)
    render json: { error: err_msg }, status: status
  end

  def render_success_json(status = :ok)
    render json: { success: true }, status: status
  end
end
