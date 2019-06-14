require 'httpclient'
require 'csv'

class Movie < ApplicationRecord
  belongs_to :artist
  has_many :views, dependent: :delete_all

  validates :youtube_id, presence: true
  validates :youtube_id, uniqueness: true
  validates :title, presence: true
  validates :flag, inclusion: { in: [true, false] }

  paginates_per 10

  def import_data
    client = HTTPClient.new
    query = { id: youtube_id, key: Rails.configuration.google_api_key, part: 'snippet,statistics' }
    res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

    return false if res['items'].blank?

    movie_info = res['items'][0]

    return false unless movie_info['id'] == youtube_id

    self.title = movie_info['snippet']['title']
    self.thumb_url = movie_info['snippet']['thumbnails']['default']['url'] if movie_info['snippet']['thumbnails']['default']
    self.published_at = DateTime.parse(movie_info['snippet']['publishedAt']).new_offset("+09:00").to_date

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

  def self.export_as_csv(artist_id, checked, start_date, end_date)
    movies = Movie.all.order(created_at: 'DESC')
    movies = movies.where(artist_id: artist_id) if artist_id
    movies = movies.where(flag: true) unless checked

    return nil if movies.empty?

    first_date = nil
    latest_date = nil

    if artist_id
      movie_ids = []
      movies.each do |movie|
        movie_ids << movie.id
      end

      first_date = View.where(movie_id: movie_ids).order(update_date: 'ASC').first.update_date
      latest_date = View.where(movie_id: movie_ids).order(update_date: 'DESC').first.update_date
    else
      first_date = View.all.order(update_date: 'ASC').first.update_date
      latest_date = View.all.order(update_date: 'DESC').first.update_date
    end

    first_date = start_date if start_date && start_date > first_date
    latest_date = end_date if end_date && end_date < latest_date
    lines = (latest_date - first_date + 1).to_i
    return nil unless lines.positive?

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

    csv_data.encode(Encoding::SJIS, invalid: :replace, undef: :replace)
  end
end
