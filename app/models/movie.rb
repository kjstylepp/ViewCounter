require 'httpclient'
require 'csv'

class Movie < ApplicationRecord
  belongs_to :artist
  has_many :views, dependent: :delete_all

  validates :youtube_id, presence: true
  validates :youtube_id, uniqueness: true
  validates :title, presence: true
  validates :flag, inclusion: { in: [true, false] }

  def import_data
    client = HTTPClient.new
    query = { id: youtube_id, key: Rails.configuration.google_api_key, part: 'snippet,statistics' }
    res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

    return false if res['items'].blank?

    movie_info = res['items'][0]

    return false unless movie_info['id'] == youtube_id

    self.title = movie_info['snippet']['title']
    self.thumb_url = movie_info['snippet']['thumbnails']['default']['url'] if movie_info['snippet']['thumbnails']['default']

    return false unless save

    view = View.find_or_create_by(movie_id: id, update_date: Date.today)
    view.count = movie_info['statistics']['viewCount'].to_i

    view.save

    true
  end

  def self.update_all_count
    movies = Movie.where(flag: true)

    result = {}
    result[:all] = movies.size
    result[:success] = 0

    return result if movies.empty?

    client = HTTPClient.new
    loop_number = (movies.size - 1) / 50 + 1
    today_date = Date.today

    loop_number.times do |i|
      video_ids = ''

      50.times do |j|
        next unless movies[i * 50 + j]

        video_ids = if j.zero?
                      movies[i * 50 + j].youtube_id
                    else
                      video_ids + ',' + movies[i * 50 + j].youtube_id
                    end
      end

      query = { id: video_ids, key: Rails.configuration.google_api_key, part: 'statistics' }
      res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

      break if res['items'].blank?

      res['items'].each do |item|
        code = item['id']
        count = item['statistics']['viewCount'].to_i

        movie = Movie.find_by_youtube_id(code)

        next unless movie

        view = View.find_or_create_by(movie_id: movie.id, update_date: today_date)
        view.count = count

        result[:success] += 1 if view.save
      end
    end

    result
  end

  def self.export_as_csv
    return nil if View.count.zero?

    first_date = View.all.order(update_date: 'ASC').first.update_date
    latest_date = View.all.order(update_date: 'DESC').first.update_date
    lines = (latest_date - first_date + 1).to_i

    movies = Movie.all

    header = ['日付']
    movies.each do |movie|
      header << movie.title
    end

    csv_data = CSV.generate(headers: header, write_headers: true, force_quotes: true) do |csv|
      pre_views = []
      movies.each do
        pre_views << 0
      end

      lines.times do |i|
        date = first_date + i

        line = [date]
        movies.each_with_index do |movie, j|
          view = View.find_by(movie_id: movie.id, update_date: date)

          if view
            line << view.count
            pre_views[j] = view.count
          else
            line << pre_views[j]
          end
        end

        csv << line
      end
    end

    csv_data.encode(Encoding::SJIS)
  end
end
