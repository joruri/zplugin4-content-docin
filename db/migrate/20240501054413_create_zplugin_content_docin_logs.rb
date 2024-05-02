class CreateZpluginContentDocinLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :zplugin_content_docin_logs do |t|
      t.integer :content_id
      t.string        :state
      t.timestamp     :start_at
      t.timestamp     :end_at
      t.string        :parse_state
      t.timestamp     :parse_start_at
      t.timestamp     :parse_end_at
      t.timestamp     :last_updated_at
      t.integer       :parse_total
      t.integer       :parse_success
      t.integer       :parse_failure
      t.integer       :register_total
      t.integer       :register_success
      t.integer       :register_failure
      t.timestamps
    end
  end
end

