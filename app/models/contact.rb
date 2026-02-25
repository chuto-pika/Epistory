class Contact < ApplicationRecord
  NAME_MAX_LENGTH = 100
  MESSAGE_MAX_LENGTH = 5000

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: MESSAGE_MAX_LENGTH }
end
