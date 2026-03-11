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
    mock_response = mock_openai_response("ブラッシュアップされたメッセージ")

    stub_openai_chat(mock_response) do
      result = AiMessageRefiner.new(@message).refine

      assert_equal "ブラッシュアップされたメッセージ", result
    end
  end

  test "refine sends generated_content to API" do
    captured_params = nil
    mock_response = mock_openai_response("結果")

    mock_client = Object.new
    mock_client.define_singleton_method(:chat) do |parameters:|
      captured_params = parameters
      mock_response
    end

    OpenAI::Client.stub(:new, mock_client) do
      AiMessageRefiner.new(@message).refine
    end

    user_message = captured_params[:messages].find { |m| m[:role] == "user" }

    assert_equal @message.generated_content, user_message[:content]
  end

  test "refine raises RefinementError on empty response" do
    mock_response = mock_openai_response("")

    stub_openai_chat(mock_response) do
      assert_raises(AiMessageRefiner::RefinementError) do
        AiMessageRefiner.new(@message).refine
      end
    end
  end

  test "refine raises RefinementError on API error" do
    mock_client = Object.new
    mock_client.define_singleton_method(:chat) do |**|
      raise Faraday::ConnectionFailed, "connection failed"
    end

    OpenAI::Client.stub(:new, mock_client) do
      error = assert_raises(AiMessageRefiner::RefinementError) do
        AiMessageRefiner.new(@message).refine
      end

      assert_includes error.message, "AI添削に失敗しました"
    end
  end

  test "refine with style includes style instruction in system prompt" do
    captured_params = nil
    mock_response = mock_openai_response("カジュアルなメッセージ")

    mock_client = Object.new
    mock_client.define_singleton_method(:chat) do |parameters:|
      captured_params = parameters
      mock_response
    end

    OpenAI::Client.stub(:new, mock_client) do
      AiMessageRefiner.new(@message, style: "casual").refine
    end

    system_message = captured_params[:messages].find { |m| m[:role] == "system" }

    assert_includes system_message[:content], "カジュアルで親しみやすい口調"
  end

  test "refine with invalid style ignores it" do
    captured_params = nil
    mock_response = mock_openai_response("通常のメッセージ")

    mock_client = Object.new
    mock_client.define_singleton_method(:chat) do |parameters:|
      captured_params = parameters
      mock_response
    end

    OpenAI::Client.stub(:new, mock_client) do
      AiMessageRefiner.new(@message, style: "invalid_style").refine
    end

    system_message = captured_params[:messages].find { |m| m[:role] == "system" }

    assert_equal AiMessageRefiner::SYSTEM_PROMPT, system_message[:content]
  end

  test "refine without style uses base system prompt only" do
    captured_params = nil
    mock_response = mock_openai_response("結果")

    mock_client = Object.new
    mock_client.define_singleton_method(:chat) do |parameters:|
      captured_params = parameters
      mock_response
    end

    OpenAI::Client.stub(:new, mock_client) do
      AiMessageRefiner.new(@message).refine
    end

    system_message = captured_params[:messages].find { |m| m[:role] == "system" }

    assert_equal AiMessageRefiner::SYSTEM_PROMPT, system_message[:content]
  end

  private

  def mock_openai_response(text)
    {
      "choices" => [
        { "message" => { "content" => text } }
      ]
    }
  end

  def stub_openai_chat(response, &)
    mock_client = Object.new
    mock_client.define_singleton_method(:chat) { |**| response }

    OpenAI::Client.stub(:new, mock_client, &)
  end
end
