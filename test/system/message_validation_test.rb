require "application_system_test_case"

class MessageValidationTest < ApplicationSystemTestCase
  test "Step1: 未選択で送信するとエラーが表示される" do
    visit new_message_path

    assert_text "誰に届けますか？"

    click_button "次へ進む"

    assert_text "相手を選んでください"
  end

  test "Step2: 未選択で送信するとエラーが表示される" do
    visit new_message_path
    find("label", text: "親").click
    click_button "次へ進む"

    assert_text "どんなきっかけですか？"
    click_button "次へ進む"

    assert_text "きっかけを選んでください"
  end

  test "Step3: 未選択で送信するとエラーが表示される" do
    visit new_message_path
    find("label", text: "親").click
    click_button "次へ進む"

    find("label", text: "日頃の感謝").click
    click_button "次へ進む"

    assert_text "相手の印象は？"
    click_button "次へ進む"

    assert_text "印象を1つ以上選んでください"
  end

  test "Step4: 501文字で送信するとエラーが表示される" do
    visit new_message_path
    find("label", text: "親").click
    click_button "次へ進む"

    find("label", text: "日頃の感謝").click
    click_button "次へ進む"

    find("label", text: "いつも支えてくれる").click
    click_button "次へ進む"

    assert_text "エピソードを教えてください"
    fill_in "episode", with: "あ" * 501
    click_button "次へ進む"

    assert_text "エピソードは500文字以内で入力してください"
  end

  test "Step5: 未選択で送信するとエラーが表示される" do
    visit new_message_path
    find("label", text: "親").click
    click_button "次へ進む"

    find("label", text: "日頃の感謝").click
    click_button "次へ進む"

    find("label", text: "いつも支えてくれる").click
    click_button "次へ進む"

    click_button "次へ進む"

    assert_text "どんな気持ちを届けますか？"
    click_button "次へ進む"

    assert_text "気持ちを選んでください"
  end

  test "Step6: 201文字で送信するとエラーが表示される" do
    visit new_message_path
    find("label", text: "親").click
    click_button "次へ進む"

    find("label", text: "日頃の感謝").click
    click_button "次へ進む"

    find("label", text: "いつも支えてくれる").click
    click_button "次へ進む"

    click_button "次へ進む"

    find("label", text: "ありがとう").click
    click_button "次へ進む"

    assert_text "追加メッセージはありますか？"
    fill_in "additional_message", with: "あ" * 201
    click_button "メッセージを作成する"

    assert_text "追加メッセージは200文字以内で入力してください"
  end
end
