module InternalApi::V1
  class BookingTransactionSerializer < ApplicationSerializer
    attributes :id, :amount, :booking_id, :created_at, :payment_provider, :status, :stripe_payment_id,
                :updated_at, :user_id
    # attribute :seat_category do |object|
    #   SeatCategorySerializer.new(object.seat_category)
    # end
    # attribute :booking do |object|
    #   BookingSerializer.new(object.booking)
    # end
  end
end
