class MessagesController < ApplicationController
  include MessageDraft

  before_action :set_message, only: %i[show edit update restore]
  before_action :authorize_message!, only: %i[edit update restore]

  def show
    restore_draft_from_message(@message)
  end

  def new
    session[:message_draft] = {}
    redirect_to step1_message_path
  end

  def edit; end

  def update
    @message.update(edited_content: params[:message][:edited_content])
    redirect_to message_path(@message)
  end

  def restore
    @message.update(edited_content: nil)
    redirect_to edit_message_path(@message)
  end

  private

  def authorize_message!
    if logged_in?
      return if @message.user_id == current_user.id

      redirect_to root_path, alert: "このメッセージを編集する権限がありません"
    else
      return if session[:created_message_id] == @message.id

      redirect_to root_path, alert: "このメッセージを編集する権限がありません"
    end
  end
end
