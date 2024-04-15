module InternalApi::V1
class TheaterSerializer < ApplicationSerializer
  attributes :id, :name, :location, :created_at, :updated_at
  # attribute :showtimes do |object|
  #   ShowtimeSerializer.new(object.showtimes)
  # end
  # attribute :movies do |object|
  #   MovieSerializer.new(object.movies)
  # end
  # attribute :seat_categories do |object|
  #   SeatCategorySerializer.new(object.seat_categories)
  # end
  # attribute :bookings do |object|
  #   BookingSerializer.new(object.bookings)
  # end
end
end