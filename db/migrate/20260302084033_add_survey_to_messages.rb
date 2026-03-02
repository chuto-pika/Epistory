class AddSurveyToMessages < ActiveRecord::Migration[7.0]
  def change
    change_table :messages, bulk: true do |t|
      t.integer :satisfaction_rating
      t.string :usage_purpose
    end
  end
end
