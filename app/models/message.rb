class Message < ApplicationRecord
  EPISODE_MAX_LENGTH = 500
  ADDITIONAL_MESSAGE_MAX_LENGTH = 200

  belongs_to :recipient
  belongs_to :occasion
  belongs_to :feeling
  has_many :message_impressions, dependent: :destroy
  has_many :impressions, through: :message_impressions

  validates :episode, length: { maximum: EPISODE_MAX_LENGTH }
  validates :additional_message, length: { maximum: ADDITIONAL_MESSAGE_MAX_LENGTH }
end
