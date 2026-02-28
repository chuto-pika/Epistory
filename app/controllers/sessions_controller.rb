class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_or_create_from_auth(request.env["omniauth.auth"])
    session[:user_id] = user.id

    if session[:created_message_id]
      message = Message.find_by(id: session[:created_message_id])
      message&.update(user: user) if message&.user_id.nil?
      session.delete(:created_message_id)
    end

    redirect_to root_path, notice: "ログインしました"
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "ログアウトしました"
  end

  def failure
    redirect_to root_path, alert: "ログインに失敗しました"
  end
end
