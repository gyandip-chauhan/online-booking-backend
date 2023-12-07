# app/controllers/showtimes_controller.rb
class ShowtimesController < ApplicationController
  def index
    @categories = MovieCategory.includes(movies: :showtimes).all
  end

  def show
    @showtime = Showtime.find(params[:id])
    @theater = Theater.find(params[:theater_id])
    @screen = Screen.find(params[:screen_id])
    @movie = Movie.find(params[:movie_id])
    @seat_categories = SeatCategory.where(screen: @screen, theater: @theater, movie: @movie)
    @showtime_seats_group_by_sc = ShowtimeSeat.where(showtime: @showtime, seat_category: @seat_categories).group_by(&:seat_category).transform_values{|val| val.first}
    respond_to do |format|
      format.html
      format.json { render json: { available_seats: @showtime.available_seats } }
    end
  end

  def select_seat
    selected_seats = params[:selected_seats] || {}

    total_price = calculate_total_price(selected_seats.values.flatten)

    render json: { total_price: total_price }
  end

  def book_now
    showtime = Showtime.find(params[:id])
    selected_seats = params[:selected_seats] || {}

    booking = current_user.bookings.create(showtime: showtime)

    begin
      showtime.update_available_seats(selected_seats, booking)
      flash[:notice] = "Booking successful. Your booking ID is #{booking.id}."
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Error processing booking: #{e.record.errors.full_messages.join(', ')}"
    end

    respond_to do |format|
      format.json do
        render json: { success: true, booking_id: booking.id, redirect_to: invoice_booking_path(booking, showtime_id: showtime.id) }
      end
    end
  end

  private

  def calculate_total_price(selected_seats)
    total_price = selected_seats.map { |item| item["price"].to_i }.sum
  end
end
