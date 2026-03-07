require "test_helper"

class AiMessageRefinerTest < ActiveSupport::TestCase
  setup do
    @message = Message.create!(
      recipient: recipients(:parent),
      occasion: occasions(:birthday),
      feeling: feelings(:thanks),
      generated_content: "テスト用の感謝メッセージです。"
    )
  end

  test "refine returns refined text from API" do
    mock_response = mock_api_response("ブラッシュアップされたメッセージ")

    stub_anthropic_create(mock_response) do
      result = AiMessageRefiner.new(@message).refine

      assert_equal "ブラッシュアップされたメッセージ", result
    end
  end

  test "refine sends generated_content to API" do
    captured_messages = nil
    mock_response = mock_api_response("結果")

    mock_messages_resource = Object.new
    mock_messages_resource.define_singleton_method(:create) do |**kwargs|
      captured_messages = kwargs[:messages]
      mock_response
    end

    mock_client = Object.new
    mock_client.define_singleton_method(:messages) { mock_messages_resource }

    Anthropic::Client.stub(:new, mock_client) do
      AiMessageRefiner.new(@message).refine
    end

    assert_equal @message.generated_content, captured_messages.first[:content]
  end

  test "refine raises RefinementError on empty response" do
    mock_response = mock_api_response("")

    stub_anthropic_create(mock_response) do
      assert_raises(AiMessageRefiner::RefinementError) do
        AiMessageRefiner.new(@message).refine
      end
    end
  end

  test "refine raises RefinementError on API error" do
    mock_messages_resource = Object.new
    mock_messages_resource.define_singleton_method(:create) do |**|
      raise Anthropic::Errors::APIConnectionError.new(url: "https://api.anthropic.com", message: "connection failed")
    end

    mock_client = Object.new
    mock_client.define_singleton_method(:messages) { mock_messages_resource }

    Anthropic::Client.stub(:new, mock_client) do
      error = assert_raises(AiMessageRefiner::RefinementError) do
        AiMessageRefiner.new(@message).refine
      end

      assert_includes error.message, "AI添削に失敗しました"
    end
  end

  MockContent = Struct.new(:text)
  MockResponse = Struct.new(:content)

  private

  def mock_api_response(text)
    MockResponse.new([MockContent.new(text)])
  end

  def stub_anthropic_create(response, &)
    mock_messages_resource = Object.new
    mock_messages_resource.define_singleton_method(:create) { |**| response }

    mock_client = Object.new
    mock_client.define_singleton_method(:messages) { mock_messages_resource }

    Anthropic::Client.stub(:new, mock_client, &)
  end
end
