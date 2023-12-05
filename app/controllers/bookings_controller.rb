# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  before_action :set_showtime, only: [:new, :create]

  def new
    @booking = Booking.new
  end

  def create
    @booking = @showtime.bookings.build(booking_params)

    if @booking.save
      redirect_to showtime_path(@showtime), notice: 'Booking was successfully created.'
    else
      render :new
    end
  end

  private

  def set_showtime
    @showtime = Showtime.find(params[:showtime_id])
  end

  def booking_params
    params.require(:booking).permit(:user_name, :seats)
  end
end
