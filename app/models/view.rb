class View < ApplicationRecord
  belongs_to :movie

  validates :count, presence: true
  validates :update_date, presence: true

  paginates_per 10

  def self.latest_update_date
    return nil if View.count.zero?

    View.all.order(update_date: 'DESC').first.update_date
  end
end
