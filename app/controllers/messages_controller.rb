class MessagesController < ApplicationController
  include MessageDraft

  before_action :set_message, only: %i[show edit update restore]

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
end
