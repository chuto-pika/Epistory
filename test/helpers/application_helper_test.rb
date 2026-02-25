require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "meta_title returns default when content_for is not set" do
    assert_equal "Epistory - 言葉にできなかった想いを、かたちに", meta_title
  end

  test "meta_description returns default when content_for is not set" do
    assert_equal "質問に答えるだけで、大切な人への感謝のメッセージが完成。伝えたかった気持ちを、Epistoryが言葉にするお手伝いをします。", meta_description
  end

  test "meta_image returns default ogp.png url when content_for is not set" do
    assert_match(/ogp.*\.png/, meta_image)
  end

  test "meta_title returns content_for value when set" do
    content_for(:og_title, "カスタムタイトル")
    assert_equal "カスタムタイトル", meta_title
  end

  test "meta_description returns content_for value when set" do
    content_for(:og_description, "カスタム説明文")
    assert_equal "カスタム説明文", meta_description
  end

  test "meta_image returns content_for value when set" do
    content_for(:og_image, "https://example.com/custom.png")
    assert_equal "https://example.com/custom.png", meta_image
  end
end
