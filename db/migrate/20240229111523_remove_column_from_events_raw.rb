class RemoveColumnFromEventsRaw < ActiveRecord::Migration[7.0]
  def change
    remove_column :events_raws, :id
    remove_column :events_raws, :created_at
    remove_column :events_raws, :updated_at
  end
end
