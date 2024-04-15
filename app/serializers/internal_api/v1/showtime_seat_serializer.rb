module InternalApi::V1
  class ShowtimeSeatSerializer < ApplicationSerializer
    attributes :id, :seats, :seat_category_id, :showtime_id, :created_at, :updated_at
    # attribute :seat_category do |object|
    #   SeatCategorySerializer.new(object.seat_category)
    # end
    # attribute :showtime do |object|
    #   ShowtimeSerializer.new(object.showtime)
    # end
  end
end
