class UpdateCountsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    movies = Movie.where(flag: true)

    exit result if movies.empty?

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

        view.save
      end
    end
  end
end
