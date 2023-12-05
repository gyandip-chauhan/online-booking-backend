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

    showtime.update_available_seats(selected_seats, booking)

    respond_to do |format|
      format.json do
        render json: { success: true, booking_id: booking.id, redirect_to: invoice_showtime_path(showtime, booking_id: booking.id) }
      end
    end
  end

  def invoice
    @showtime = Showtime.find(params[:id])
    @booking = Booking.find(params[:booking_id])
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

  private

  def calculate_total_price(selected_seats)
    total_price = selected_seats.map { |item| item["price"].to_i }.sum
  end
end
