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
