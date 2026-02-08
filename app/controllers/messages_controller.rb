class MessagesController < ApplicationController
  def new
    session[:message_draft] = {}
    redirect_to step1_message_path
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

    session[:message_draft] ||= {}
    session[:message_draft]["recipient_id"] = params[:recipient_id].to_i
    redirect_to step2_message_path
  end

  def step2
    unless session.dig(:message_draft, "recipient_id")
      redirect_to step1_message_path
      return
    end

    @occasions = Occasion.all
    @selected_id = session.dig(:message_draft, "occasion_id")
  end

  def save_step2
    if params[:occasion_id].blank?
      redirect_to step2_message_path, alert: "きっかけを選んでください"
      return
    end

    session[:message_draft] ||= {}
    session[:message_draft]["occasion_id"] = params[:occasion_id].to_i
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

    session[:message_draft] ||= {}
    session[:message_draft]["impression_ids"] = Array(params[:impression_ids]).map(&:to_i)
    redirect_to step4_message_path
  end

  def step4
    unless draft_complete_up_to?(3)
      redirect_to step1_message_path
      return
    end

    @episode = session.dig(:message_draft, "episode")
  end

  def save_step4
    session[:message_draft] ||= {}
    session[:message_draft]["episode"] = params[:episode].to_s.strip
    redirect_to step5_message_path
  end

  def step5
    unless draft_complete_up_to?(3)
      redirect_to step1_message_path
      return
    end

    @feelings = Feeling.all
    @selected_id = session.dig(:message_draft, "feeling_id")
  end

  def save_step5
    if params[:feeling_id].blank?
      redirect_to step5_message_path, alert: "気持ちを選んでください"
      return
    end

    session[:message_draft] ||= {}
    session[:message_draft]["feeling_id"] = params[:feeling_id].to_i
    redirect_to step6_message_path
  end

  def step6
    unless draft_complete_up_to?(5)
      redirect_to step1_message_path
      return
    end

    @additional_message = session.dig(:message_draft, "additional_message")
  end

  def save_step6
    session[:message_draft] ||= {}
    session[:message_draft]["additional_message"] = params[:additional_message].to_s.strip

    draft = session[:message_draft]
    unless draft["recipient_id"] && draft["occasion_id"] && draft["impression_ids"] && draft["feeling_id"]
      redirect_to step1_message_path
      return
    end

    @message = Message.new(
      recipient_id: draft["recipient_id"],
      occasion_id: draft["occasion_id"],
      feeling_id: draft["feeling_id"],
      episode: draft["episode"].presence,
      additional_message: draft["additional_message"].presence
    )
    @message.impression_ids = draft["impression_ids"]

    if @message.save
      @message.update(generated_content: MessageGenerator.new(@message).generate)
      session.delete(:message_draft)
      redirect_to message_path(@message)
    else
      redirect_to step1_message_path, alert: "メッセージの作成に失敗しました"
    end
  end

  def show
    @message = Message.find(params[:id])
  end

  private

  def draft_complete_up_to?(step)
    draft = session[:message_draft]
    return false unless draft

    case step
    when 1
      draft["recipient_id"].present?
    when 2
      draft["recipient_id"].present? && draft["occasion_id"].present?
    when 3
      draft["recipient_id"].present? && draft["occasion_id"].present? && draft["impression_ids"].present?
    when 4
      draft_complete_up_to?(3)
    when 5
      draft_complete_up_to?(3) && draft["feeling_id"].present?
    else
      false
    end
  end
end
