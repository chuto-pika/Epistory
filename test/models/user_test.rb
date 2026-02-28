require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = users(:alice)

    assert_predicate user, :valid?
  end

  test "provider is required" do
    user = User.new(provider: "", uid: "123", name: "Test", email: "test@example.com")

    assert_not user.valid?
    assert_includes user.errors[:provider], "can't be blank"
  end

  test "uid is required" do
    user = User.new(provider: "google_oauth2", uid: "", name: "Test", email: "test@example.com")

    assert_not user.valid?
    assert_includes user.errors[:uid], "can't be blank"
  end

  test "uid must be unique within provider" do
    existing = users(:alice)
    user = User.new(provider: existing.provider, uid: existing.uid, name: "Dup", email: "dup@example.com")

    assert_not user.valid?
    assert_includes user.errors[:uid], "has already been taken"
  end

  test "same uid with different provider is valid" do
    user = User.new(provider: "github", uid: users(:alice).uid, name: "Test", email: "test@example.com")

    assert_predicate user, :valid?
  end

  test "name is required" do
    user = User.new(provider: "google_oauth2", uid: "999", name: "", email: "test@example.com")

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "email is required" do
    user = User.new(provider: "google_oauth2", uid: "999", name: "Test", email: "")

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "find_or_create_from_auth creates new user" do
    auth = OpenStruct.new(
      provider: "google_oauth2",
      uid: "999999",
      info: OpenStruct.new(name: "New User", email: "new@example.com", image: "https://example.com/new.png")
    )

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
    auth = OpenStruct.new(
      provider: existing.provider,
      uid: existing.uid,
      info: OpenStruct.new(name: "Different Name", email: "different@example.com", image: nil)
    )

    assert_no_difference "User.count" do
      user = User.find_or_create_from_auth(auth)

      assert_equal existing.id, user.id
    end
  end
end
