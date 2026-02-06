class Impression < ApplicationRecord
  default_scope { order(position: :asc) }

  has_many :message_impressions, dependent: :restrict_with_error
  has_many :messages, through: :message_impressions

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
