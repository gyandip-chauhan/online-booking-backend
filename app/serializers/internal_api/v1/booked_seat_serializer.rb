module InternalApi::V1
  class BookedSeatSerializer < ApplicationSerializer
    attributes :id, :seats, :price, :created_at, :updated_at
    attribute :seat_category do |object|
      SeatCategorySerializer.new(object.seat_category)
    end
    # attribute :booking do |object|
    #   BookingSerializer.new(object.booking)
    # end
  end
end
