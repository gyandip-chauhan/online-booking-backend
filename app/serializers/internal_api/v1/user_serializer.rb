module InternalApi::V1
  class UserSerializer < ApplicationSerializer
    attributes :id, :email, :balance, :stripe_id, :created_at, :updated_at
    # attribute :my_bookings do |object|
    #   BookingSerializer.new(object.my_bookings)
    # end
    # attribute :cancel_bookings do |object|
    #   BookingSerializer.new(object.cancel_bookings)
    # end
  end
end
