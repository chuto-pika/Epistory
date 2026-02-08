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
    redirect_to root_path
  end
end
