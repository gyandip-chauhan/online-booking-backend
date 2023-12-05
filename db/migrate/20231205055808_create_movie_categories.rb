class CreateMovieCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_categories do |t|
      t.string :name

      t.timestamps
    end
    add_reference :movies, :movie_category, foreign_key: true
  end
end
