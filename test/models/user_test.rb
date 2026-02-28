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

  private

  def mock_auth_hash(uid:, name:, email:, image:)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { name: name, email: email, image: image }
    )
  end
end
