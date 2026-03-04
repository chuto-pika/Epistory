class AddGeneratedPartsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :generated_parts, :jsonb
  end
end
