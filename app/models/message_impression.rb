class MessageImpression < ApplicationRecord
  belongs_to :message
  belongs_to :impression
end
