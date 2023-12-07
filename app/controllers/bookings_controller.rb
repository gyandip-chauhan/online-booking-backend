# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:invoice, :cancel]

  def index
    @my_bookings = current_user.my_bookings.includes(:booked_seats, showtime: [:movie, :theater])
    @cancel_bookings = current_user.cancel_bookings.includes(:booked_seats, showtime: [:movie, :theater])
    @categories = ["my_bookings", "cancelled_bookings"]
    @active_tab = params[:tab] || 'my_bookings'
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

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'invoice',
               locals: { showtime: @showtime, booking: @booking, booking_details: @booking_details }
      end
    end
  end

  def cancel
    if @booking.is_cancelled
      flash[:alert] = "Booking was already cancelled."
      redirect_to bookings_path(tab: 'my_bookings')
    end
    begin
      @booking.cancel_booking
      flash[:notice] = "Booking canceled successfully."
      redirect_to bookings_path(tab: 'cancelled_bookings')
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Error cancelling booking: #{e.record.errors.full_messages.join(', ')}"
      redirect_to bookings_path(tab: 'my_bookings')
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
