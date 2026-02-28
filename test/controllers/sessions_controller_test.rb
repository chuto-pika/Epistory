require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new displays login page" do
    get login_path

    assert_response :success
  end

  test "create logs in user via Google OAuth" do
    user = users(:alice)

    sign_in_as(user)

    assert_redirected_to root_path
    assert_equal user.id, session[:user_id]
  end

  test "create creates new user if not exists" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new_uid_999",
      info: { name: "New User", email: "newuser@example.com", image: nil }
    )

    assert_difference "User.count", 1 do
      post "/auth/google_oauth2/callback"
    end

    assert_redirected_to root_path
  end

  test "create links existing message to user" do
    # 未ログインでメッセージ作成してセッションに保存
    message = create_message_via_steps
    assert_nil message.user_id

    # ログインすると紐付く
    user = users(:alice)
    sign_in_as(user)

    assert_equal user.id, message.reload.user_id
  end

  test "destroy logs out user" do
    sign_in_as(users(:alice))

    delete logout_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
  end

  test "failure redirects to root with alert" do
    get "/auth/failure"

    assert_redirected_to root_path
  end

  private

  def complete_all_steps
    post step1_message_path, params: { recipient_id: recipients(:parent).id }
    post step2_message_path, params: { occasion_id: occasions(:birthday).id }
    post step3_message_path, params: { impression_ids: [impressions(:supportive).id] }
    post step4_message_path, params: { episode: "テストエピソード" }
    post step5_message_path, params: { feeling_id: feelings(:thanks).id }
  end

  def create_message_via_steps
    complete_all_steps
    post step6_message_path, params: { additional_message: "" }
    Message.last
  end
end
