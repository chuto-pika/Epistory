class Feeling < ApplicationRecord
  default_scope { order(position: :asc) }

  has_many :messages, dependent: :restrict_with_error

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
