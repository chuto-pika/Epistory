class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  before_action :set_sidebar_messages

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "ログインしてください"
  end

  def set_sidebar_messages
    return unless logged_in?

    @sidebar_messages = current_user.messages
                                    .includes(:recipient)
                                    .order(created_at: :desc)
                                    .page(params[:sidebar_page])
                                    .per(10)
  end
end
