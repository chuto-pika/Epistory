class Message < ApplicationRecord
  belongs_to :recipient
  belongs_to :occasion
  belongs_to :feeling
  has_many :message_impressions, dependent: :destroy
  has_many :impressions, through: :message_impressions
end
