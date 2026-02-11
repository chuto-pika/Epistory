require "application_system_test_case"

class MessageCreationFlowTest < ApplicationSystemTestCase
  test "全ステップを通してメッセージが作成される" do
    visit root_path
    click_link "メッセージを作る", match: :first

    # Step1: 相手を選択
    assert_text "誰に届けますか？"
    find("label", text: "親").click
    click_button "次へ進む"

    # Step2: きっかけを選択
    assert_text "どんなきっかけですか？"
    find("label", text: "日頃の感謝").click
    click_button "次へ進む"

    # Step3: 印象を選択（複数）
    assert_text "相手の印象は？"
    find("label", text: "いつも支えてくれる").click
    find("label", text: "一緒にいると安心する").click
    click_button "次へ進む"

    # Step4: エピソード入力
    assert_text "エピソードを教えてください"
    fill_in "episode", with: "先月、仕事で落ち込んでいた時にそっと話を聞いてくれた"
    click_button "次へ進む"

    # Step5: 気持ちを選択
    assert_text "どんな気持ちを届けますか？"
    find("label", text: "ありがとう").click
    click_button "次へ進む"

    # Step6: 追加メッセージ入力
    assert_text "追加メッセージはありますか？"
    fill_in "additional_message", with: "今度一緒にごはん行こうね"
    click_button "メッセージを作成する"

    # showページの確認
    assert_text "メッセージが完成しました"
    assert_text "お父さん・お母さんへ"
    assert_text "先月、仕事で落ち込んでいた時にそっと話を聞いてくれた"
    assert_text "今度一緒にごはん行こうね"
  end

  test "任意項目を空にしてもメッセージが作成される" do
    visit new_message_path

    # Step1
    find("label", text: "友人").click
    click_button "次へ進む"

    # Step2
    find("label", text: "誕生日・記念日").click
    click_button "次へ進む"

    # Step3
    find("label", text: "自分を理解してくれる").click
    click_button "次へ進む"

    # Step4: エピソードを空のまま
    assert_text "エピソードを教えてください"
    click_button "次へ進む"

    # Step5
    find("label", text: "これからもよろしく").click
    click_button "次へ進む"

    # Step6: 追加メッセージを空のまま
    assert_text "追加メッセージはありますか？"
    click_button "メッセージを作成する"

    # showページの確認
    assert_text "メッセージが完成しました"
    assert_text "いつもありがとうへ"
  end

  test "戻るボタンで前のステップに戻っても選択が保持される" do
    visit new_message_path

    # Step1: 選択して進む
    find("label", text: "パートナー").click
    click_button "次へ進む"

    # Step2: 選択して進む
    find("label", text: "最近助けてもらった").click
    click_button "次へ進む"

    # Step3: 戻るボタンで Step2 に戻る
    click_link "戻る"

    assert_text "どんなきっかけですか？"

    # Step2 の選択が保持されていることを確認
    radio = find("input[name='occasion_id'][value='#{occasions(:helped).id}']", visible: false)

    assert_predicate radio, :checked?

    # さらに Step1 に戻る
    click_link "戻る"

    assert_text "誰に届けますか？"

    radio = find("input[name='recipient_id'][value='#{recipients(:partner).id}']", visible: false)

    assert_predicate radio, :checked?
  end
end
