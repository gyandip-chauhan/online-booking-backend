class AddTrailerUrlToMovie < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :trailer_url, :string
  end
end
