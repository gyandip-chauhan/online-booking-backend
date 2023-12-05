class ShowtimeSeat < ApplicationRecord
  belongs_to :showtime
  belongs_to :seat_category

  before_save :set_available_seats

  private

  def set_available_seats
    self.seats = seat_category.seats unless seats.present?
  end
end
