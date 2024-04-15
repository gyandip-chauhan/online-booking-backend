module InternalApi::V1
  class ShowtimeSerializer < ApplicationSerializer
    attributes :id, :time, :screen_id, :theater_id, :movie_id, :created_at, :updated_at
    attribute :movie do |object|
      MovieSerializer.new(object.movie, {params: {disable_showtimes: true}})
    end
    attribute :theater do |object|
      TheaterSerializer.new(object.theater)
    end
    attribute :screen do |object|
      ScreenSerializer.new(object.screen)
    end
    # attribute :bookings do |object|
    #   BookingSerializer.new(object.bookings, {params: {disable_showtime: true, disable_movie: true}})
    # end
    attribute :showtime_seats do |object|
      ShowtimeSeatSerializer.new(object.showtime_seats)
    end
  end
end
