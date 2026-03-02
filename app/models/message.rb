class Message < ApplicationRecord
  EPISODE_MAX_LENGTH = 500
  ADDITIONAL_MESSAGE_MAX_LENGTH = 200
  SATISFACTION_RANGE = (1..5)
  USAGE_PURPOSE_OPTIONS = %w[send_as_is edit_and_send reference just_tried].freeze

  belongs_to :user, optional: true
  belongs_to :recipient
  belongs_to :occasion
  belongs_to :feeling
  has_many :message_impressions, dependent: :destroy
  has_many :impressions, through: :message_impressions

  validates :episode, length: { maximum: EPISODE_MAX_LENGTH }
  validates :additional_message, length: { maximum: ADDITIONAL_MESSAGE_MAX_LENGTH }
  validates :recipient_name, length: { maximum: 20 }
  validates :satisfaction_rating, inclusion: { in: SATISFACTION_RANGE }, allow_nil: true
  validates :usage_purpose, inclusion: { in: USAGE_PURPOSE_OPTIONS }, allow_nil: true

  def survey_answered?
    satisfaction_rating.present?
  end
end
