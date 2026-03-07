class MessagesController < ApplicationController # rubocop:disable Metrics/ClassLength
  include MessageDraft

  before_action :set_message, only: %i[show edit update restore regenerate regenerate_part destroy survey ai_refine]
  before_action :authorize_message!, only: %i[edit update restore regenerate regenerate_part destroy survey ai_refine]
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

  def ai_refine
    unless logged_in?
      redirect_to login_path, alert: "AIブラッシュアップにはログインが必要です"
      return
    end

    if current_user.ai_refine_limit_reached?
      redirect_to message_path(@message), alert: "本日のAIブラッシュアップ回数（#{User::AI_REFINE_DAILY_LIMIT}回）に達しました"
      return
    end

    refined_text = AiMessageRefiner.new(@message).refine
    @message.update!(edited_content: refined_text, ai_refined_at: Time.current)
    redirect_to message_path(@message), notice: "AIでメッセージをブラッシュアップしました"
  rescue AiMessageRefiner::RefinementError
    redirect_to message_path(@message), alert: "AI添削に失敗しました。しばらく経ってから再度お試しください"
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
