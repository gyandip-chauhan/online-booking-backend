ActiveAdmin.register SeatCategory do
  permit_params :name, :theater_id, :movie_id, :screen_id, :start_num_of_seat, :end_num_of_seat, :seats, :price

  index do
    selectable_column
    id_column
    column :name
    column :theater
    column :movie
    column :screen
    column :seats
    column :price
    actions
  end

  filter :name
  filter :theater
  filter :movie
  filter :screen
  filter :price

  form do |f|
    f.inputs do
      f.input :name
      f.input :theater, as: :select, collection: Theater.all.map { |t| [t.name, t.id] }
      f.input :movie, as: :select, collection: Movie.all.map { |m| [m.title, m.id] }
      f.input :screen, as: :select, collection: Screen.all.map { |s| [s.name, s.id] }
      f.input :price
      f.input :start_num_of_seat, label: 'Start Seat', as: :select, collection: (1..100).to_a
      f.input :end_num_of_seat, label: 'End Seat', as: :select, collection: (1..100).to_a
      f.input :seats, as: :hidden, input_html: { id: 'seats-hidden-input' }
    end

    script do
      raw <<~JS
        document.addEventListener("DOMContentLoaded", function() {
          const startSeatDropdown = document.getElementById("seat_category_start_num_of_seat");
          const endSeatDropdown = document.getElementById("seat_category_end_num_of_seat");
          const hiddenSeatsInput = document.getElementById("seats-hidden-input");

          function updateHiddenSeats() {
            const startSeat = parseInt(startSeatDropdown.value, 10);
            const endSeat = parseInt(endSeatDropdown.value, 10);

            hiddenSeatsInput.value = Array.from({ length: endSeat - startSeat + 1 }, (_, index) => startSeat + index).join(',');
          }

          startSeatDropdown.addEventListener("change", updateHiddenSeats);
          endSeatDropdown.addEventListener("change", updateHiddenSeats);

          updateHiddenSeats();
        });
      JS
    end

    f.actions
  end
end
