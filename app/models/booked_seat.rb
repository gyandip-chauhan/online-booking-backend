class BookedSeat < ApplicationRecord
  belongs_to :seat_category
  belongs_to :booking
end
