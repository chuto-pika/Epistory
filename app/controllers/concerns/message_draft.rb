module MessageDraft
  extend ActiveSupport::Concern

  private

  def save_draft(key, value)
    session[:message_draft] ||= {}
    session[:message_draft][key] = value
  end

  def draft
    session[:message_draft] || {}
  end

  def draft_steps_complete?(up_to)
    required = %w[recipient_id occasion_id impression_ids]
    required << "feeling_id" if up_to >= 5
    required.all? { |key| draft[key].present? }
  end

  def create_message_from_draft
    unless draft_steps_complete?(5)
      redirect_to step1_message_path
      return
    end

    message = build_message_from_draft
    if message.save
      message.update(generated_content: MessageGenerator.new(message).generate)
      session.delete(:message_draft)
      redirect_to message_path(message)
    else
      redirect_to step1_message_path, alert: "メッセージの作成に失敗しました"
    end
  end

  def text_too_long?(step, field, value, max_length)
    return false unless value.length > max_length

    instance_variable_set(:"@#{field}", value)
    @error_message = "#{Message.human_attribute_name(field)}は#{max_length}文字以内で入力してください"
    render step, status: :unprocessable_entity
    true
  end

  def build_message_from_draft
    message = Message.new(
      recipient_id: draft["recipient_id"],
      occasion_id: draft["occasion_id"],
      feeling_id: draft["feeling_id"],
      episode: draft["episode"].presence,
      additional_message: draft["additional_message"].presence
    )
    message.impression_ids = draft["impression_ids"]
    message
  end
end
