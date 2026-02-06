class CreateMessageImpressions < ActiveRecord::Migration[7.0]
  def change
    create_table :message_impressions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :impression, null: false, foreign_key: true

      t.timestamps
    end

    add_index :message_impressions, %i[message_id impression_id], unique: true
  end
end
