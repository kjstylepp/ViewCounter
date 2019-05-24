class View < ApplicationRecord
  belongs_to :movie

  validates :count, presence: true

  def self.today(movie_id)
    today_date = Date.today

    today_view = self.find_by(movie_id: movie_id, update_date: today_date)

    unless today_view
      today_view = View.new
      today_view.movie_id = movie_id
      today_view.update_date = today_date
    end

    return today_view
  end
end
