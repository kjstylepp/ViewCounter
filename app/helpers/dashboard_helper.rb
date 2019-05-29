module DashboardHelper
  def show_job_interval
    if Rails.configuration.job_interval
      "再生数は#{Rails.configuration.job_interval}に自動で更新されます。"
    else
      '再生数の自動更新は設定されていません。'
    end
  end

  def show_latest_update_date
    if View.latest_update_date
      "現在、再生数の最終更新日は#{View.latest_update_date.strftime('%Y年%m月%d日')}です。"
    else
      "現在、まだ一度も再生数が取得されていません。"
    end
  end

  def artist_view(artist, selected_artist, checked)
    if selected_artist
      artist.name
    elsif checked
      link_to artist.name, "/?artist=#{artist.id}&flag=true"
    else
      link_to artist.name, "/?artist=#{artist.id}"
    end
  end

  def latest_view_count(movie)
    latest_view = movie.views.order(update_date: 'DESC').first

    if latest_view
      tag.td(latest_view.count, class: 'nowrap')
    else
      tag.td('-', class: 'nowrap')
    end
  end

  def to_str_array(list)
    str = '['

    list.each_with_index do |item, i|
      str += if i.zero?
               "\'#{item}\'"
             else
               ", \'#{item}\'"
             end
    end

    str += ']'
  end

  def to_int_array(list)
    str = '['

    list.each_with_index do |item, i|
      str += if i.zero?
               item.to_s
             else
               ", #{item}"
             end
    end

    str += ']'
  end
end
