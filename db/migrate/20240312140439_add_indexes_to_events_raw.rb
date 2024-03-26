class AddIndexesToEventsRaw < ActiveRecord::Migration[7.0]
  def change
    add_index :events_raws, :event
    add_index :events_raws, :stage
    add_index :events_raws, :section
    add_index :events_raws, :build_card_type
    add_index :events_raws, :event_order
    add_index :events_raws, :project_id
    add_index :events_raws, :project_name
    add_index :events_raws, :build_card_id
    add_index :events_raws, :region
    add_index :events_raws, :event_date
  end
end
