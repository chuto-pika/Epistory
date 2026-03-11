class AddAiRefineUsageToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.integer :ai_refine_daily_used, default: 0, null: false
      t.date :ai_refine_usage_date
    end
  end
end
