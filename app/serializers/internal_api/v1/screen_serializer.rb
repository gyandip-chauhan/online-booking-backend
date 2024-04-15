module InternalApi::V1
  class ScreenSerializer < ApplicationSerializer
    attributes :id, :name, :created_at, :updated_at
    # attribute :seat_categories do |object|
    #   SeatCategorySerializer.new(object.seat_categories)
    # end
    # attribute :showtimes do |object|
    #   ShowtimeSerializer.new(object.showtimes)
    # end
  end
end
