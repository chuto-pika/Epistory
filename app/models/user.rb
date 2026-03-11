class User < ApplicationRecord
  AI_REFINE_DAILY_LIMIT = 5

  has_many :messages, dependent: :nullify

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :name, presence: true
  validates :email, presence: true

  def ai_refine_limit_reached?
    ai_refine_daily_used_today >= AI_REFINE_DAILY_LIMIT
  end

  def ai_refine_daily_used_today
    ai_refine_usage_date == Time.zone.today ? ai_refine_daily_used : 0
  end

  def increment_ai_refine_usage!
    if ai_refine_usage_date == Time.zone.today
      update!(ai_refine_daily_used: ai_refine_daily_used + 1)
    else
      update!(ai_refine_daily_used: 1, ai_refine_usage_date: Time.zone.today)
    end
  end

  def self.find_or_create_from_auth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.avatar_url = auth.info.image
    end
  end
end
