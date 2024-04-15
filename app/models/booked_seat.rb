class BookedSeat < ApplicationRecord
  belongs_to :seat_category
  belongs_to :booking

  validate :unique_booking_per_showtime_and_seats

  def self.ransackable_attributes(auth_object = nil)
    ["booking_id", "created_at", "id", "price", "seat_category_id", "seats", "updated_at"]
  end

  private

  def unique_booking_per_showtime_and_seats
    # Convert the seats string to an array of seat numbers
    booked_seats_seats = self.seats.split(',')

    # Check if any of the seats are already booked for this seat category and not the current booking
    if BookedSeat.where(seat_category_id: self.seat_category_id)
                 .where("ARRAY[?]::text[] && string_to_array(seats, ',')", booked_seats_seats)
                 .where.not(booking_id: self.booking_id)
                 .exists?
      errors.add(:base, "Some seats are already booked for this seat category.")
    end
  end
end
