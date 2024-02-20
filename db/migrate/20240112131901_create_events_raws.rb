class CreateEventsRaws < ActiveRecord::Migration[7.0]
  def change
    create_table :events_raws do |t|
      t.string :section
      t.string :stage
      t.bigint :event_order
      t.string :event
      t.datetime :event_date
      t.bigint :count_column
      t.bigint :project_id
      t.string :project_name
      t.string :project_status
      t.bigint :build_card_id
      t.string :start_month
      t.string :build_card_type
      t.string :region
      t.string :period_type
      t.string :month_year

      t.timestamps
    end
  end
end
