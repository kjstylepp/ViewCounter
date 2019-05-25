module DashboardHelper
  def latest_view_count(movie)
    latest_view = movie.views.order(update_date: 'DESC').first

    if latest_view
      tag.td(latest_view.count) + tag.td(latest_view.update_date)
    else
      tag.td('-') + tag.td('-')
    end
  end
end
