class AddAiRefinedAtToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :ai_refined_at, :datetime
  end
end
