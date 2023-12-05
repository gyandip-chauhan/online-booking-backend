module ShowtimesHelper
  def category_for_row(row_index)
    alphabet = ('A'..'Z').to_a
    alphabet[row_index % 26]
  end
end
