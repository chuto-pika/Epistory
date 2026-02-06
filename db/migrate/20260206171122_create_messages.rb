class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.bigint :user_id, null: true
      t.references :recipient, null: false, foreign_key: true
      t.references :occasion, null: false, foreign_key: true
      t.references :feeling, null: false, foreign_key: true
      t.text :episode
      t.text :additional_message
      t.text :generated_content
      t.text :edited_content

      t.timestamps
    end
  end
end
