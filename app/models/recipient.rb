class Recipient < ApplicationRecord
  default_scope { order(position: :asc) }

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
