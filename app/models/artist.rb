class Artist < ApplicationRecord
  has_many :movies, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 100 }
  validates :name, uniqueness: true

  paginates_per 10

  def self.select_list
    list = { '全アーティスト' => nil }

    Artist.all.order(created_at: 'DESC').each do |artist|
      list.store(artist.name, artist.id) unless artist.movies.empty?
    end

    list
  end
end
