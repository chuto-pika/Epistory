class AiMessageRefiner
  class RefinementError < StandardError; end

  SYSTEM_PROMPT = <<~PROMPT.freeze
    あなたは感謝メッセージの添削アシスタントです。以下のルールに従って、メッセージをブラッシュアップしてください。

    ## ルール
    - 元のメッセージのトーン（敬語/カジュアル）を維持する
    - 「P.S.」で始まる追伸部分はそのまま残す
    - 大幅な内容変更はせず、表現をより自然に・より心に響くように調整する
    - 冗長な表現を簡潔にする
    - 本文のみを出力する（説明や注釈は不要）
  PROMPT

  def initialize(message)
    @message = message
  end

  def refine
    client = Anthropic::Client.new
    response = client.messages.create(
      model: "claude-haiku-4-5-20241022",
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [
        { role: "user", content: @message.generated_content }
      ]
    )

    extract_text(response)
  rescue Anthropic::Errors::Error => e
    raise RefinementError, "AI添削に失敗しました: #{e.message}"
  end

  private

  def extract_text(response)
    text = response.content&.first&.text
    raise RefinementError, "AI添削の応答が空でした" if text.blank?

    text.strip
  end
end
