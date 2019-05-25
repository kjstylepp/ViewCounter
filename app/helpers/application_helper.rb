module ApplicationHelper
  def show_flash
    if flash[:notice]
      tag.div flash[:notice], class: 'alert alert-success', role: 'alert'
    elsif flash[:alert]
      tag.div flash[:alert], class: 'alert alert-danger', role: 'alert'
    end
  end

  def movie_flag_text(flag)
    if flag
      '○'
    else
      '×'
    end
  end

  def thumb(url)
    if url
      image_tag url, border: 0
    else
      '（サムネ画像なし）'
    end
  end
end
