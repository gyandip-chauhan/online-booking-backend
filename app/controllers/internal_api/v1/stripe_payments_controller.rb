# frozen_string_literal: true

module InternalApi::V1
  class StripePaymentsController < ApplicationController
    before_action :setup_stripe

    def create
      begin
        payment_params = params['data']['attributes']
        showtime = Showtime.find(payment_params['showtime_id'])
        selected_seats = payment_params[:selected_seats] || {}
    
        ActiveRecord::Base.transaction do
          booking = current_user.bookings.build(showtime: showtime)
          
          if booking.valid?  # Check validity before proceeding
            showtime.update_available_seats(selected_seats, booking)
            user = current_user
            amount = booking.total_price.to_i * 100
            User.create_stripe_customers(current_user)
            payment_intent = create_payment_intent(amount, params['data']['payment_token'])
    
            if payment_intent
              booking.transaction do  # Another transaction block for booking save
                booking.save!
                booking.update_column(:stripe_payment_method_id, payment_intent['payment_method'])
              end
    
              render json: {
                notice: 'Payment initiated successfully.',
                booking_id: booking.id,
                client_secret: payment_intent['client_secret'],
                success: true
              }, status: :ok
            else
              render json: { success: false, error: 'Invalid data format for payment' }, status: :unprocessable_entity
            end
          else
            render json: { success: false, error: booking.errors.full_messages.join(', ') }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { success: false, error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
      rescue Stripe::StripeError => e
        render json: { error: "Stripe payment error: #{e.message}" }, status: :unprocessable_entity
      rescue => e
        Rails.logger.error "Unexpected error in create action: #{e.message}"
        render json: { success: false, error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
      end
    end
    

    def confirm
      payment_params = params
      if payment_params['data'].present? && payment_params['data']['stripe_payment_id'].present?
        booking = Booking.find_by(stripe_payment_method_id: payment_params['data']['stripe_payment_id'])
      end
      if booking.present?
        @payment_intent = if Rails.env.test?
                            { 'amount_received': booking.total_price.to_i, 'payment_method': 'test' }
                          else
                            Stripe::PaymentIntent.retrieve(payment_params['data']['payment_intent_id'])
                          end

        if @payment_intent['amount_received'] != 0
          create_booking_transaction(booking, @payment_intent)

          unless booking.confirmed?
            booking.update(source: 'Stripe', status: 'confirmed', stripe_payment_confirmed_at: Time.current)
            BookingNotifier.with(record: booking).deliver_later(current_user)
          end
          render json: { notice: 'Payment successfull.', client_secret: @payment_intent.client_secret, booking: BookingSerializer.new(booking).serializable_hash[:data] }, status: :ok
        else
          render json: { success: false, error: 'Invalid data format' }, status: :unprocessable_entity
        end
      else
        render json: { success: false, error: 'Booking not found.' }, status: :unprocessable_entity
      end
    end

    private

    def create_payment_intent(amount, payment_method)
      return { 'payment_method': 'test_intent' }.with_indifferent_access if Rails.env.test?

      Stripe::PaymentIntent.create({
                                      customer: current_user.stripe_id,
                                      amount: amount,
                                      currency: 'inr',
                                      payment_method: payment_method,
                                      description: 'Online Booking services',
                                      payment_method_types: ['card']
                                    })
    end

    def create_booking_transaction(booking, payment_charge)
      BookingTransaction.create(user_id: current_user.id,
                                                      stripe_payment_id: payment_charge['payment_method'], status: 'verified', amount: payment_charge['amount_received'], payment_provider: 'Stripe', booking_id: booking.id)
    end

    def setup_stripe
      Stripe.api_key =  ENV['STRIPE_SECRET_KEY']
    end
  end
end
