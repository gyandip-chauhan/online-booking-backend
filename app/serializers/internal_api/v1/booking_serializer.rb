module InternalApi::V1
  class BookingSerializer < ApplicationSerializer
    attributes :id, :total_price, :is_cancelled, :showtime_id, :movie_id, :theater_id,
      :stripe_payment_method_id,:source,:status,:stripe_payment_confirmed_at, :created_at, :updated_at

    attribute :user do |object|
      UserSerializer.new(object.user)
    end
    attribute :showtime do |object, params|
      ShowtimeSerializer.new(object.showtime) if !params[:disable_showtime]
    end
    # attribute :movie do |object, params|
    #   MovieSerializer.new(object.movie, {params: {disable_showtimes: true}}) if !params[:disable_movie]
    # end
    # attribute :theater do |object, params|
    #   TheaterSerializer.new(object.theater) if !params[:disable_theater]
    # end
    attribute :booked_seats do |object, params|
      BookedSeatSerializer.new(object.booked_seats) if !params[:disable_booked_seats]
    end
    attribute :booking_transactions do |object, params|
      BookingTransactionSerializer.new(object.booking_transactions) if !params[:disable_booking_transactions]
    end
  end
end
