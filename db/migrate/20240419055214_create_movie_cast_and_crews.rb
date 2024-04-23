class CreateMovieCastAndCrews < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_cast_and_crews do |t|
      t.string :name
      t.integer :role
      t.integer :kind
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
  end
end
