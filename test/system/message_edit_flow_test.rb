require "application_system_test_case"

class MessageEditFlowTest < ApplicationSystemTestCase
  setup do
    @message = Message.create!(
      recipient: recipients(:parent),
      occasion: occasions(:gratitude),
      feeling: feelings(:thanks),
      episode: "テスト用エピソード",
      generated_content: "生成されたテストメッセージです。",
      impression_ids: [impressions(:supportive).id]
    )
  end

  test "メッセージを編集して保存できる" do
    visit message_path(@message)

    assert_text "メッセージが完成しました"
    assert_text "生成されたテストメッセージです。"

    click_link "編集する"

    assert_text "メッセージを編集"

    fill_in "message[edited_content]", with: "編集後のメッセージです。"
    click_button "保存する"

    # showページに戻り編集内容が表示される
    assert_text "メッセージが完成しました"
    assert_text "編集後のメッセージです。"
    assert_no_text "生成されたテストメッセージです。"
  end

  test "編集済みメッセージを元に戻せる" do
    @message.update!(edited_content: "編集済みの内容")

    visit edit_message_path(@message)

    assert_text "メッセージを編集"

    accept_confirm "編集内容を破棄して、元のメッセージに戻しますか？" do
      click_button "元のメッセージに戻す"
    end

    # editページに戻りgenerated_contentが表示される
    assert_text "メッセージを編集"
    assert_selector "textarea", text: "生成されたテストメッセージです。"
  end

  test "編集ページから戻るでshowページに戻れる" do
    visit message_path(@message)
    click_link "編集する"

    assert_text "メッセージを編集"

    click_link "戻る"

    assert_text "メッセージが完成しました"
  end
end
