class AddIsCancelledToBooking < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :is_cancelled, :boolean, default: false
  end
end
