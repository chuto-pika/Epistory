require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = users(:alice)

    assert_predicate user, :valid?
  end

  test "provider is required" do
    user = User.new(provider: "", uid: "123", name: "Test", email: "test@example.com")

    assert_not user.valid?
    assert_not_empty user.errors[:provider]
  end

  test "uid is required" do
    user = User.new(provider: "google_oauth2", uid: "", name: "Test", email: "test@example.com")

    assert_not user.valid?
    assert_not_empty user.errors[:uid]
  end

  test "uid must be unique within provider" do
    existing = users(:alice)
    user = User.new(provider: existing.provider, uid: existing.uid, name: "Dup", email: "dup@example.com")

    assert_not user.valid?
    assert_not_empty user.errors[:uid]
  end

  test "same uid with different provider is valid" do
    user = User.new(provider: "github", uid: users(:alice).uid, name: "Test", email: "test@example.com")

    assert_predicate user, :valid?
  end

  test "name is required" do
    user = User.new(provider: "google_oauth2", uid: "999", name: "", email: "test@example.com")

    assert_not user.valid?
    assert_not_empty user.errors[:name]
  end

  test "email is required" do
    user = User.new(provider: "google_oauth2", uid: "999", name: "Test", email: "")

    assert_not user.valid?
    assert_not_empty user.errors[:email]
  end

  test "find_or_create_from_auth creates new user" do
    auth = mock_auth_hash(uid: "999999", name: "New User", email: "new@example.com", image: "https://example.com/new.png")

    assert_difference "User.count", 1 do
      user = User.find_or_create_from_auth(auth)

      assert_equal "google_oauth2", user.provider
      assert_equal "999999", user.uid
      assert_equal "New User", user.name
      assert_equal "new@example.com", user.email
      assert_equal "https://example.com/new.png", user.avatar_url
    end
  end

  test "find_or_create_from_auth finds existing user" do
    existing = users(:alice)
    auth = mock_auth_hash(uid: existing.uid, name: "Different Name", email: "different@example.com", image: nil)

    assert_no_difference "User.count" do
      user = User.find_or_create_from_auth(auth)

      assert_equal existing.id, user.id
    end
  end

  test "ai_refine_limit_reached? returns false when no usage today" do
    user = users(:alice)

    assert_not user.ai_refine_limit_reached?
  end

  test "ai_refine_limit_reached? returns true when limit is reached" do
    user = users(:alice)
    user.update!(ai_refine_daily_used: User::AI_REFINE_DAILY_LIMIT, ai_refine_usage_date: Time.zone.today)

    assert_predicate user, :ai_refine_limit_reached?
  end

  test "ai_refine_limit_reached? does not count yesterdays usage" do
    user = users(:alice)
    user.update!(ai_refine_daily_used: User::AI_REFINE_DAILY_LIMIT, ai_refine_usage_date: 1.day.ago)

    assert_not user.ai_refine_limit_reached?
  end

  test "increment_ai_refine_usage! increments counter for today" do
    user = users(:alice)
    user.update!(ai_refine_daily_used: 2, ai_refine_usage_date: Time.zone.today)

    user.increment_ai_refine_usage!

    assert_equal 3, user.reload.ai_refine_daily_used
  end

  test "increment_ai_refine_usage! resets counter when date changes" do
    user = users(:alice)
    user.update!(ai_refine_daily_used: 5, ai_refine_usage_date: 1.day.ago)

    user.increment_ai_refine_usage!

    assert_equal 1, user.reload.ai_refine_daily_used
    assert_equal Time.zone.today, user.ai_refine_usage_date
  end

  private

  def mock_auth_hash(uid:, name:, email:, image:)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { name: name, email: email, image: image }
    )
  end
end
