class AiMessageRefiner
  class RefinementError < StandardError; end

  SYSTEM_PROMPT = <<~PROMPT.freeze
    あなたは感謝メッセージの添削アシスタントです。以下のルールに従って、メッセージをブラッシュアップしてください。

    ## ルール
    - 元のメッセージのトーン（敬語/カジュアル）を維持する
    - 「P.S.」で始まる追伸部分はそのまま残す
    - 大幅な内容変更はせず、表現をより自然に・より心に響くように調整する
    - 冗長な表現を簡潔にする
    - 「こうして振り返ると、」「改めて思い返してみると、」「そして、」「それに、」のような定型的なつなぎ表現は、前後の文脈に合わせてより自然な表現に書き換える
    - 文と文のつながりが滑らかになるよう、全体の流れを意識して調整する
    - 本文のみを出力する（説明や注釈は不要）
  PROMPT

  STYLE_INSTRUCTIONS = {
    "casual" => "全体をカジュアルで親しみやすい口調に調整してください。敬語は使わず、友達に話しかけるような文体にしてください。",
    "formal" => "全体をフォーマルで丁寧な文体に調整してください。敬語を使い、礼儀正しい表現にしてください。",
    "humorous" => "ユーモアを交えた楽しい文体に調整してください。クスッと笑えるような表現を自然に織り込んでください。",
    "poetic" => "詩的で情緒のある文体に調整してください。比喩や美しい表現を使い、心に残る文章にしてください。",
    "warm" => "温かみのある優しい文体に調整してください。相手を包み込むような柔らかい表現にしてください。"
  }.freeze

  def initialize(message, style: nil)
    @message = message
    @style = style
  end

  def refine
    client = ::OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY", nil))
    response = client.chat(
      parameters: {
        model: "gpt-4.1-mini",
        messages: build_messages,
        max_tokens: 1024
      }
    )
    extract_text(response)
  rescue Faraday::Error => e
    raise RefinementError, "AI添削に失敗しました: #{e.message}"
  end

  private

  def build_messages
    [
      { role: "system", content: system_prompt_with_style },
      { role: "user", content: @message.generated_content }
    ]
  end

  def system_prompt_with_style
    return SYSTEM_PROMPT unless @style && STYLE_INSTRUCTIONS.key?(@style)

    "#{SYSTEM_PROMPT}\n\n## 追加指示\n#{STYLE_INSTRUCTIONS[@style]}"
  end

  def extract_text(response)
    text = response.dig("choices", 0, "message", "content")
    raise RefinementError, "AI添削の応答が空でした" if text.blank?

    text.strip
  end
end
