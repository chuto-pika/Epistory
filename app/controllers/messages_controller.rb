class MessagesController < ApplicationController
  include MessageDraft

  before_action :set_message, only: %i[show edit update restore regenerate regenerate_part destroy survey]
  before_action :authorize_message!, only: %i[edit update restore regenerate regenerate_part destroy survey]
  before_action :validate_regenerate_part!, only: :regenerate_part

  helper_method :message_owner?

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

  def regenerate
    generator = MessageGenerator.new(@message)
    parts = generator.generate_parts
    @message.update(
      generated_parts: parts,
      generated_content: MessageGenerator.join_parts(parts),
      edited_content: nil
    )
    redirect_to message_path(@message)
  end

  def regenerate_part
    part = params[:part]
    rebuild_part(part)

    respond_to do |format|
      format.turbo_stream { render partial: "messages/regenerate_part", locals: { part: part, message: @message } }
      format.html { redirect_to edit_message_path(@message) }
    end
  end

  def destroy
    @message.destroy
    redirect_back_or_to root_path
  end

  def survey
    if @message.survey_answered?
      redirect_to message_path(@message)
      return
    end

    @message.update(survey_params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("survey_#{@message.id}", partial: "messages/survey_thanks")
      end
      format.html { redirect_to message_path(@message) }
    end
  end

  private

  def authorize_message!
    return if message_owner?

    redirect_to root_path, alert: "このメッセージを操作する権限がありません"
  end

  def message_owner?
    if logged_in?
      @message.user_id == current_user.id
    else
      session[:created_message_id] == @message.id
    end
  end

  def survey_params
    params.require(:message).permit(:satisfaction_rating, :usage_purpose)
  end

  def validate_regenerate_part!
    if !valid_part?(params[:part])
      redirect_to message_path(@message), alert: "無効なパートです"
    elsif !@message.parts_available?
      redirect_to message_path(@message), alert: "パート別再生成に対応していないメッセージです"
    end
  end

  def valid_part?(part)
    MessageGenerator::REGENERABLE_PARTS.include?(part)
  end

  def rebuild_part(part)
    new_content = MessageGenerator.new(@message).generate_part(part)
    updated_parts = @message.generated_parts.merge(part => new_content)
    @message.update(
      generated_parts: updated_parts,
      generated_content: MessageGenerator.join_parts(updated_parts),
      edited_content: nil
    )
    updated_parts
  end
end
