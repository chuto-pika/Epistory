class MessagesController < ApplicationController
  include MessageDraft

  def show
    @message = Message.find(params[:id])
  end

  def new
    session[:message_draft] = {}
    redirect_to step1_message_path
  end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])
    @message.update(edited_content: params[:message][:edited_content])
    redirect_to message_path(@message)
  end

  def restore
    @message = Message.find(params[:id])
    @message.update(edited_content: nil)
    redirect_to edit_message_path(@message)
  end

  def step1
    @recipients = Recipient.all
    @selected_id = session.dig(:message_draft, "recipient_id")
  end

  def save_step1
    if params[:recipient_id].blank?
      redirect_to step1_message_path, alert: "相手を選んでください"
      return
    end

    save_draft("recipient_id", params[:recipient_id].to_i)
    redirect_to step2_message_path
  end

  def step2
    return redirect_to step1_message_path unless session.dig(:message_draft, "recipient_id")

    @occasions = Occasion.all
    @selected_id = session.dig(:message_draft, "occasion_id")
  end

  def save_step2
    if params[:occasion_id].blank?
      redirect_to step2_message_path, alert: "きっかけを選んでください"
      return
    end

    save_draft("occasion_id", params[:occasion_id].to_i)
    redirect_to step3_message_path
  end

  def step3
    unless session.dig(:message_draft, "recipient_id") && session.dig(:message_draft, "occasion_id")
      redirect_to step1_message_path
      return
    end

    @impressions = Impression.all
    @selected_ids = session.dig(:message_draft, "impression_ids") || []
  end

  def save_step3
    if params[:impression_ids].blank?
      redirect_to step3_message_path, alert: "印象を1つ以上選んでください"
      return
    end

    save_draft("impression_ids", Array(params[:impression_ids]).map(&:to_i))
    redirect_to step4_message_path
  end

  def step4
    return redirect_to step1_message_path unless draft_steps_complete?(3)

    @episode = session.dig(:message_draft, "episode")
  end

  def save_step4
    episode = params[:episode].to_s.strip
    return if text_too_long?(:step4, :episode, episode, Message::EPISODE_MAX_LENGTH)

    save_draft("episode", episode)
    redirect_to step5_message_path
  end

  def step5
    return redirect_to step1_message_path unless draft_steps_complete?(3)

    @feelings = Feeling.all
    @selected_id = session.dig(:message_draft, "feeling_id")
  end

  def save_step5
    if params[:feeling_id].blank?
      redirect_to step5_message_path, alert: "気持ちを選んでください"
      return
    end

    save_draft("feeling_id", params[:feeling_id].to_i)
    redirect_to step6_message_path
  end

  def step6
    return redirect_to step1_message_path unless draft_steps_complete?(5)

    @additional_message = session.dig(:message_draft, "additional_message")
  end

  def save_step6
    additional_message = params[:additional_message].to_s.strip
    if text_too_long?(:step6, :additional_message, additional_message,
                      Message::ADDITIONAL_MESSAGE_MAX_LENGTH)
      return
    end

    save_draft("additional_message", additional_message)
    create_message_from_draft
  end
end
