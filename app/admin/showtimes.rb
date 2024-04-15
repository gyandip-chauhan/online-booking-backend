# app/admin/showtime.rb
ActiveAdmin.register Showtime do
  permit_params :movie_id, :theater_id, :screen_id, :time

  index do
    selectable_column
    id_column
    column :movie
    column :theater
    column :screen
    column :time
    actions
  end

  show do
    attributes_table do
      row :id
      row :movie
      row :theater
      row :screen
      row :time
    end

    panel "Showtime Seats" do
      table_for showtime.showtime_seats.includes(:seat_category) do
        column "Seat Category" do |showtime_seat|
          showtime_seat.seat_category.name
        end
        column "Seats" do |showtime_seat|
          showtime_seat.seats
        end
      end
    end

    panel "Associated Bookings" do
      table_for showtime.bookings do
        column :id do |booking|
          link_to "Booking ##{booking.id}", admin_booking_path(booking)
        end
      end
    end
  end

  filter :movie
  filter :theater
  filter :screen
  filter :time

  form do |f|
    f.inputs do
      f.input :movie, as: :select, collection: Movie.all.map { |m| [m.title, m.id] }
      f.input :theater, as: :select, collection: Theater.all.map { |t| [t.name, t.id] }
      f.input :screen, as: :select, collection: Screen.all.map { |s| [s.name, s.id] }
      f.input :time, as: :datetime_select, datetime_local: true
    end

    f.actions
  end
end
