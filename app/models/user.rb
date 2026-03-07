class User < ApplicationRecord
  AI_REFINE_DAILY_LIMIT = 5

  has_many :messages, dependent: :nullify

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :name, presence: true
  validates :email, presence: true

  def ai_refine_limit_reached?
    messages.where(ai_refined_at: Time.zone.now.beginning_of_day..).count >= AI_REFINE_DAILY_LIMIT
  end

  def self.find_or_create_from_auth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.avatar_url = auth.info.image
    end
  end
end
