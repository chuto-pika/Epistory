class MessageGenerator # rubocop:disable Metrics/ClassLength
  REGENERABLE_PARTS = %w[opening impression episode closing].freeze

  HONORIFICS = {
    "親" => "お父さん・お母さん",
    "パートナー" => "あなた",
    "友人" => "いつもありがとう",
    "兄弟・姉妹" => "お兄ちゃん・お姉ちゃん",
    "祖父母" => "おじいちゃん・おばあちゃん",
    "職場の人" => "いつもお世話になっています"
  }.freeze

  OCCASION_TEMPLATES = {
    "誕生日・記念日" => [
      "特別な日に、普段なかなか言えない気持ちを伝えたくて書いています。",
      "お祝いの気持ちとともに、日頃の感謝を伝えたくて書いています。",
      "記念日を迎えて、改めて気持ちを届けたくなりました。"
    ],
    "日頃の感謝" => [
      "いつも当たり前のように過ごしているけれど、改めて気持ちを伝えたくなりました。",
      "毎日の中でふと立ち止まって、感謝の気持ちを伝えたくなりました。",
      "普段は照れくさくて言えないけれど、改めて気持ちを伝えさせてください。"
    ],
    "最近助けてもらった" => [
      "最近、助けてもらったことがあって、ちゃんとお礼を伝えたいと思いました。",
      "この前助けてもらったこと、ずっとお礼を言いたくて書いています。",
      "最近のこと、きちんと感謝を伝えたくて手紙にしました。"
    ],
    "しばらく会えていない" => [
      "しばらく会えていないけれど、ふと気持ちを伝えたくなりました。",
      "なかなか会えない日が続いているけれど、元気にしていますか。",
      "離れていても、いつも気にかけています。ふと気持ちを伝えたくなりました。"
    ],
    "特別な理由はない" => [
      "特別な理由はないけれど、ふと気持ちを伝えたくなりました。",
      "何でもない日だけど、急に気持ちを伝えたくなりました。",
      "特別なきっかけはないけれど、ふとあなたのことを思って書いています。"
    ]
  }.freeze

  FEELING_TEMPLATES = {
    "ありがとう" => [
      "本当にありがとう。この気持ちが届くといいな。",
      "心からありがとう。いつも感謝しています。",
      "ありがとうの気持ちでいっぱいです。"
    ],
    "これからもよろしく" => [
      "これからもよろしくね。一緒に過ごせる時間を大切にしたいです。",
      "これからも一緒に、たくさんの思い出をつくっていこうね。",
      "これからもずっと、よろしくお願いします。"
    ],
    "いつも助かっている" => [
      "いつも本当に助かっています。あなたがいてくれることが、私の支えです。",
      "あなたがいてくれるおかげで、いつも頑張れています。本当にありがとう。",
      "いつも助けてくれて、本当に感謝しています。"
    ],
    "大切に思っている" => [
      "あなたのことを大切に思っています。これからもずっと。",
      "かけがえのない存在です。いつも大切に思っています。",
      "あなたの存在が、私にとってどれほど大きいか伝えたくて。"
    ],
    "ごめんね、そしてありがとう" => [
      "素直になれないこともあるけれど、ごめんね。そして、いつもありがとう。",
      "うまく伝えられないこともあるけれど、ごめんね。感謝の気持ちは本物です。",
      "不器用でごめんね。でも、いつもありがとう。"
    ]
  }.freeze

  IMPRESSION_TEMPLATES = {
    "いつも支えてくれる" => [
      "いつもそばで静かに支えてくれるあなたの存在に、何度助けられたかわかりません。",
      "つらいときもそっと寄り添ってくれる、その優しさにいつも救われています。"
    ],
    "一緒にいると安心する" => [
      "あなたと一緒にいると、不思議と肩の力が抜けて安心できます。",
      "そばにいてくれるだけで安心できる、そんな存在です。"
    ],
    "自分を理解してくれる" => [
      "言葉にしなくても気持ちをわかってくれる、そんなあなたの存在がとても心強いです。",
      "自分のことを理解してくれる人がいるということが、どれだけ心の支えになっているか。"
    ],
    "困ったときに頼れる" => [
      "困ったときにいつも頼りにできるあなたがいてくれて、本当に心強いです。",
      "どんなときも力になってくれるあなたの存在が、私の大きな支えです。"
    ],
    "笑顔にしてくれる" => [
      "あなたといると自然と笑顔になれる、そんな時間がとても幸せです。",
      "いつも笑わせてくれるあなたのおかげで、毎日が明るくなります。"
    ],
    "尊敬している" => [
      "あなたの姿をいつも尊敬しています。その生き方に、いつも刺激をもらっています。",
      "まっすぐなあなたのことを、心から尊敬しています。"
    ],
    "刺激をもらえる" => [
      "あなたと話すたびに新しい気づきがあって、いつも刺激をもらっています。",
      "あなたの存在が、自分ももっと頑張ろうという気持ちにさせてくれます。"
    ]
  }.freeze

  EPISODE_INTROS = [
    "思い出すのは、",
    "ふと思い出すのは、",
    "忘れられないのは、"
  ].freeze

  EPISODE_OUTROS = [
    "あのときのことは、今でも忘れません。",
    "そのことを思い出すたびに、温かい気持ちになります。",
    "あの日のことは、ずっと心に残っています。"
  ].freeze

  def initialize(message)
    @message = message
    @recipient = message.recipient
    @occasion = message.occasion
    @impressions = message.impressions
    @feeling = message.feeling
    @episode = message.episode
    @additional_message = message.additional_message
  end

  def generate
    self.class.join_parts(generate_parts)
  end

  def generate_parts
    parts = {}
    parts["opening"] = generate_opening
    parts["impression"] = generate_impression
    parts["episode"] = generate_episode
    parts["closing"] = generate_closing
    parts["ps"] = generate_ps
    parts.compact
  end

  def generate_part(part_name)
    unless REGENERABLE_PARTS.include?(part_name)
      raise ArgumentError, "Invalid part name: #{part_name}. Must be one of #{REGENERABLE_PARTS.join(", ")}"
    end

    send(:"generate_#{part_name}")
  end

  def self.join_parts(parts)
    ordered = %w[opening impression episode closing ps]
    ordered.filter_map { |key| parts[key] }.join("\n\n")
  end

  def generate_opening
    prefix = if @message.recipient_name.present?
               "#{@message.recipient_name}へ\n\n"
             else
               hon = HONORIFICS[@recipient.name]
               hon ? "#{hon}へ\n\n" : ""
             end
    templates = OCCASION_TEMPLATES[@occasion.name]
    body = if templates
             templates.sample
           else
             "伝えたい気持ちがあって、書いています。"
           end
    "#{prefix}#{body}"
  end

  def generate_impression
    return nil if @impressions.empty?

    @impressions.map { |imp| IMPRESSION_TEMPLATES.fetch(imp.name, ["#{imp.name}。"]).sample }.join
  end

  def generate_episode
    return nil if @episode.blank?

    intro = EPISODE_INTROS.sample
    outro = EPISODE_OUTROS.sample
    "#{intro}#{@episode}\n#{outro}"
  end

  def generate_closing
    templates = FEELING_TEMPLATES[@feeling.name]
    if templates
      templates.sample
    else
      "ありがとう。"
    end
  end

  def generate_ps
    return nil if @additional_message.blank?

    "P.S. #{@additional_message}"
  end
end
