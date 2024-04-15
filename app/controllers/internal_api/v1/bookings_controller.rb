# app/controllers/bookings_controller.rb
module InternalApi::V1
  class BookingsController < ApplicationController
      before_action :set_booking, only: [:invoice, :cancel]
    
      def index
        @my_bookings = current_user.my_bookings.includes(:booked_seats, showtime: [:movie, :theater])
        @cancel_bookings = current_user.cancel_bookings.includes(:booked_seats, showtime: [:movie, :theater])
        @categories = ["my_bookings", "cancelled_bookings"]
        @active_tab = params[:tab] || 'my_bookings'
        
        render json: { my_bookings: BookingSerializer.new(@my_bookings).as_json, cancel_bookings: BookingSerializer.new(@cancel_bookings).as_json, categories: @categories }
      end
    
      def invoice
        @showtime = Showtime.find(params[:showtime_id])
        @booking_details = {
          'Customer Email' => @booking.user.email,
          'Movie' => @booking.showtime.movie.title,
          'Theater' => @booking.showtime.theater.name,
          'Location' => @booking.showtime.theater.location,
          'Date & Time' => @booking.showtime.time.strftime('%B %d, %Y %I:%M %p'),
          'Seats' => @booking.booked_seats.group_by(&:seat_category).map { |sc, b_seats| "#{sc.name}: #{b_seats.pluck(:seats).join(',')}" }.flatten.join(","),
          'Total Price' => @booking.total_price
        }
    
        # Respond with JSON data
        render json: { showtime: @showtime, booking: @booking, booking_details: @booking_details }
      end
    
      def cancel
        if @booking.is_cancelled
          render json: { error: "Booking was already cancelled." }, status: :unprocessable_entity
        else
          begin
            @booking.cancel_booking
            render json: { notice: "Booking canceled successfully." }
          rescue ActiveRecord::RecordInvalid => e
            render json: { error: "Error cancelling booking: #{e.record.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
          end
        end
      end
    
      private
    
      def set_booking
        @booking = Booking.find(params[:id])
      end
  end
end