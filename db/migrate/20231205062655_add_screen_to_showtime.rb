class AddScreenToShowtime < ActiveRecord::Migration[7.0]
  def change
    add_reference :showtimes, :screen, foreign_key: true
  end
end
