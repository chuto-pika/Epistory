module ApplicationHelper
  def default_meta_tags
    {
      title: "Epistory - 言葉にできなかった想いを、かたちに",
      description: "質問に答えるだけで、大切な人への感謝のメッセージが完成。伝えたかった気持ちを、Epistoryが言葉にするお手伝いをします。",
      image: image_url("ogp.png"),
      url: request.original_url
    }
  end

  def meta_title
    content_for(:og_title).presence || default_meta_tags[:title]
  end

  def meta_description
    content_for(:og_description).presence || default_meta_tags[:description]
  end

  def meta_image
    content_for(:og_image).presence || default_meta_tags[:image]
  end

  def meta_url
    content_for(:og_url).presence || default_meta_tags[:url]
  end
end
