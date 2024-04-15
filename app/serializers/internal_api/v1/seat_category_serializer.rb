module InternalApi::V1
class SeatCategorySerializer < ApplicationSerializer
  attributes :id, :name, :created_at, :updated_at
  attribute :showtime_seats do |object|
    ShowtimeSeatSerializer.new(object.showtime_seats)
  end
  # attribute :booked_seats do |object|
  #   BookedSeatSerializer.new(object.booked_seats)
  # end
  # attribute :screen do |object|
  #   ScreenSerializer.new(object.screen)
  # end
  # attribute :theater do |object|
  #   TheaterSerializer.new(object.theater)
  # end
  # attribute :movie do |object|
  #   MovieSerializer.new(object.movie)
  # end
end
end