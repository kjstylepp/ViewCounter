module DashboardHelper
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
      tag.td(latest_view.count, class: 'nowrap') + tag.td(latest_view.update_date.strftime('%Y年%m月%d日'), class: 'nowrap')
    else
      tag.td('-', class: 'nowrap') + tag.td('-', class: 'nowrap')
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
