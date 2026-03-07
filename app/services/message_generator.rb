class MessageGenerator # rubocop:disable Metrics/ClassLength
  REGENERABLE_PARTS = %w[opening impression episode future closing].freeze

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
      "記念日を迎えて、改めて気持ちを届けたくなりました。",
      "大切な日だからこそ、ちゃんと言葉にして届けたいと思いました。",
      "この特別な日に、いつもは伝えられない想いを手紙にしました。"
    ],
    "日頃の感謝" => [
      "いつも当たり前のように過ごしているけれど、改めて気持ちを伝えたくなりました。",
      "毎日の中でふと立ち止まって、感謝の気持ちを伝えたくなりました。",
      "普段は照れくさくて言えないけれど、改めて気持ちを伝えさせてください。",
      "日々の中で当たり前に思っていたけれど、それがどれだけありがたいことか気づきました。",
      "言葉にするのは少し恥ずかしいけれど、今日は素直に気持ちを伝えたいです。"
    ],
    "最近助けてもらった" => [
      "最近、助けてもらったことがあって、ちゃんとお礼を伝えたいと思いました。",
      "この前助けてもらったこと、ずっとお礼を言いたくて書いています。",
      "最近のこと、きちんと感謝を伝えたくて手紙にしました。",
      "この前のこと、一言お礼を伝えたくてずっと考えていました。",
      "助けてもらったあのとき、本当にうれしかったです。改めてお礼を伝えさせてください。"
    ],
    "しばらく会えていない" => [
      "しばらく会えていないけれど、ふと気持ちを伝えたくなりました。",
      "なかなか会えない日が続いているけれど、元気にしていますか。",
      "離れていても、いつも気にかけています。ふと気持ちを伝えたくなりました。",
      "会えない時間が続くと、余計に伝えたい気持ちが膨らんできました。",
      "直接は会えないけれど、手紙でなら届けられるかなと思って書いています。"
    ],
    "特別な理由はない" => [
      "特別な理由はないけれど、ふと気持ちを伝えたくなりました。",
      "何でもない日だけど、急に気持ちを伝えたくなりました。",
      "特別なきっかけはないけれど、ふと思い出して書いています。",
      "今日は何となく、ちゃんと気持ちを伝えたい日でした。",
      "特に理由はないけれど、思い立ったので素直に書いてみます。"
    ]
  }.freeze

  FEELING_TEMPLATES = {
    "ありがとう" => [
      "本当にありがとう。この気持ちが届くといいな。",
      "心からありがとう。いつも感謝しています。",
      "ありがとうの気持ちでいっぱいです。",
      "「ありがとう」じゃ足りないくらいだけど、精一杯の気持ちを込めて。",
      "何度でも伝えたいです。本当に、ありがとう。"
    ],
    "これからもよろしく" => [
      "これからもよろしくね。一緒に過ごせる時間を大切にしたいです。",
      "これからも一緒に、たくさんの思い出をつくっていこうね。",
      "これからもずっと、よろしくお願いします。",
      "これから先も、変わらずそばにいてくれたらうれしいです。",
      "これからも、いろんなことを一緒に乗り越えていけたらいいな。"
    ],
    "いつも助かっている" => [
      "いつも本当に助かっています。いてくれることが、私の支えです。",
      "いてくれるおかげで、いつも頑張れています。本当にありがとう。",
      "いつも助けてくれて、本当に感謝しています。",
      "頼りにしてばかりだけど、それだけ信頼しているということ、伝わっていたらうれしいです。",
      "いつも助けてもらってばかりで、感謝してもしきれません。"
    ],
    "大切に思っている" => [
      "大切に思っています。これからもずっと。",
      "かけがえのない存在です。いつも大切に思っています。",
      "私にとってどれほど大きな存在か、伝えたくて書きました。",
      "出会えたことに、心から感謝しています。ずっと大切に思っています。",
      "大切な人がいるということが、どれだけ幸せなことか気づかせてくれました。"
    ],
    "ごめんね、そしてありがとう" => [
      "素直になれないこともあるけれど、ごめんね。そして、いつもありがとう。",
      "うまく伝えられないこともあるけれど、ごめんね。感謝の気持ちは本物です。",
      "不器用でごめんね。でも、いつもありがとう。",
      "つい甘えてしまうことが多いけれど、ごめんね。そして、ありがとう。",
      "ちゃんと伝えられなくてごめんね。でも、感謝の気持ちはずっと持っています。"
    ]
  }.freeze

  IMPRESSION_TEMPLATES = {
    "いつも支えてくれる" => [
      "いつもそばで静かに支えてくれて、何度助けられたかわかりません。",
      "つらいときもそっと寄り添ってくれる優しさに、いつも救われています。",
      "落ち込んだときに「大丈夫だよ」と言ってくれる、その一言にどれだけ救われてきたか。",
      "何も言わなくても気づいて手を差し伸べてくれる、その温かさが本当にありがたいです。",
      "忙しいときも変わらず気にかけてくれて、その気遣いにいつも感謝しています。"
    ],
    "一緒にいると安心する" => [
      "一緒にいると、不思議と肩の力が抜けて安心できます。",
      "そばにいてくれるだけで安心できる、そんなかけがえのない存在です。",
      "何も話さなくても、隣にいるだけでほっとする時間が好きです。",
      "一緒にいると自然と力が抜けて、自分らしくいられる気がします。",
      "どんなに忙しい日でも、顔を見るとほっと安心できます。"
    ],
    "自分を理解してくれる" => [
      "言葉にしなくても気持ちをわかってくれる、その心強さに何度も救われてきました。",
      "自分のことを理解してくれる人がいるということが、どれだけ心の支えになっているか。",
      "ちょっとした変化にも気づいてくれる、その観察力と優しさにいつも驚かされます。",
      "うまく言葉にできないときも、黙って話を聞いてくれる姿にいつも助けられています。",
      "弱い部分もそのまま受け入れてくれる、その懐の深さに感謝しています。"
    ],
    "困ったときに頼れる" => [
      "困ったときにいつも頼りにできて、本当に心強いです。",
      "どんなときも力になってくれて、私にとって大きな支えです。",
      "相談するといつも真剣に考えてくれる、その誠実さに何度も救われてきました。",
      "「いつでも言ってね」の一言が、どれだけ心の支えになっているか計り知れません。",
      "困ったときに最初に顔が浮かぶのは、いつも決まって同じ人です。"
    ],
    "笑顔にしてくれる" => [
      "一緒にいると自然と笑顔になれる、そんな時間がとても幸せです。",
      "いつも笑わせてくれるおかげで、毎日が明るくなります。",
      "くだらない話で一緒に笑い合える時間が、何よりの宝物です。",
      "どんなに疲れていても、話しているうちに気持ちが軽くなるのが不思議です。",
      "ふとした冗談に思わず吹き出してしまう、あの瞬間がいつも楽しみです。"
    ],
    "尊敬している" => [
      "その生き方をいつも尊敬しています。いつも刺激をもらっています。",
      "まっすぐに物事に向き合う姿を、心から尊敬しています。",
      "努力を惜しまない姿勢に、いつも背筋が伸びる思いです。",
      "誰に対しても誠実に向き合う姿を見て、自分もそうありたいと思います。",
      "大変なときでも前を向き続ける強さに、いつも勇気をもらっています。"
    ],
    "刺激をもらえる" => [
      "話すたびに新しい気づきがあって、いつも刺激をもらっています。",
      "その行動力が、自分ももっと頑張ろうという気持ちにさせてくれます。",
      "一緒にいると視野が広がって、新しい世界を見せてもらえる気がします。",
      "いつも新しいことに挑戦する姿を見て、自分も負けていられないと思います。",
      "何気ない会話の中にもヒントがあって、いつも学ばせてもらっています。"
    ]
  }.freeze

  BRIDGE_TEMPLATES = {
    "誕生日・記念日" => [
      "こうして振り返ると、",
      "改めて思い返してみると、",
      "この節目に改めて感じるのは、"
    ],
    "日頃の感謝" => [
      "日頃から感じていることだけど、",
      "普段はなかなか言えないけれど、",
      "改めて思うのは、"
    ],
    "最近助けてもらった" => [
      "そのときに改めて感じたのは、",
      "あのとき思ったのは、",
      "そのことがきっかけで改めて気づいたのは、"
    ],
    "しばらく会えていない" => [
      "離れていて改めて感じるのは、",
      "会えない時間の中で気づいたのは、",
      "距離があるからこそ分かることがあって、"
    ],
    "特別な理由はない" => [
      "ふと思うのは、",
      "改めて感じるのは、",
      "何気ない日常の中で思うのは、"
    ]
  }.freeze

  FUTURE_TEMPLATES = {
    "ありがとう" => [
      "これからも、感謝の気持ちを忘れずにいたいです。",
      "この先もずっと、ありがとうを伝え続けたいです。"
    ],
    "これからもよろしく" => [
      "これから先も、一緒にたくさんの思い出をつくっていけたらうれしいです。",
      "これからの日々も、変わらずそばにいてくれたらうれしいです。"
    ],
    "いつも助かっている" => [
      "私もいつか、同じように誰かの力になれたらと思います。",
      "これからは、私も少しでも恩返しができたらと思っています。"
    ],
    "大切に思っている" => [
      "これから先も、この気持ちは変わりません。",
      "この先もずっと、大切に思い続けます。"
    ],
    "ごめんね、そしてありがとう" => [
      "少しずつでも、素直に気持ちを伝えられるようになりたいです。",
      "これからは、もっと気持ちを伝えていけたらと思います。"
    ]
  }.freeze

  IMPRESSION_CONNECTORS = [
    "そして、",
    "それに、",
    "それだけでなく、",
    "さらに、",
    "そしてなにより、"
  ].freeze

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
    parts["bridge"] = generate_bridge
    parts["impression"] = generate_impression
    parts["episode"] = generate_episode
    parts["future"] = generate_future
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
    ordered = %w[opening bridge impression episode future closing ps]
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

    sentences = @impressions.map do |imp|
      IMPRESSION_TEMPLATES.fetch(imp.name, ["#{imp.name}。"]).sample
    end

    join_impression_sentences(sentences)
  end

  def generate_episode
    return nil if @episode.blank?

    intro = EPISODE_INTROS.sample
    outro = EPISODE_OUTROS.sample
    "#{intro}#{@episode}\n#{outro}"
  end

  def generate_bridge
    return nil if @impressions.empty?

    templates = BRIDGE_TEMPLATES[@occasion.name]
    templates&.sample
  end

  def generate_future
    templates = FUTURE_TEMPLATES[@feeling.name]
    templates&.sample
  end

  def generate_closing
    templates = FEELING_TEMPLATES[@feeling.name]
    if templates
      templates.sample
    else
      "ありがとう。"
    end
  end

  def join_impression_sentences(sentences)
    return sentences.first if sentences.size == 1

    if sentences.size == 2
      connector = IMPRESSION_CONNECTORS.sample
      return "#{sentences[0]}\n#{connector}#{sentences[1]}"
    end

    lines = [sentences[0]]
    sentences[1..-2].each { |s| lines << "#{%w[そして、 それに、].sample}#{s}" }
    lines << "#{%w[そしてなにより、 さらに、].sample}#{sentences.last}"
    lines.join("\n")
  end

  def generate_ps
    return nil if @additional_message.blank?

    "P.S. #{@additional_message}"
  end
end
