class DashboardController < ApplicationController
  before_action :set_artist_and_movie, only: %i[count_history update_count]

  def index
    @movies = Movie.order(artist_id: 'ASC').page(params[:page])
  end

  def count_history
    @views = @movie.views.order(update_date: 'DESC').page(params[:page])

    views = @movie.views.order(update_date: 'ASC')

    @date_list = []
    @sum_list = []
    @diff_list = []

    diff_min_act = 0
    diff_max_act = 0

    views.each_with_index do |view, i|
      @date_list << view.update_date.strftime('%Y年%m月%d日')
      @sum_list << view.count
      @diff_list << if i.zero?
                      0
                    else
                      @sum_list[i] - @sum_list[i - 1]
                    end

      if i == 1
        diff_min_act = @diff_list[1]
        diff_max_act = @diff_list[1]
      elsif i > 1
        if @diff_list[i] < diff_min_act
          diff_min_act = @diff_list[i]
        else
          diff_max_act = @diff_list[i]
        end
      end
    end

    @sum_step = 100_000
    @sum_min = detect_min(@sum_list.first, @sum_list.last, @sum_step)
    @sum_max = detect_max(@sum_list.first, @sum_list.last, @sum_step)

    @diff_step = 1_000
    @diff_min = detect_min(diff_min_act, diff_max_act, @diff_step)
    @diff_max = detect_max(diff_min_act, diff_max_act, @diff_step)
  end

  def update_counts
    if Rails.configuration.allow_manual_update
      result = Movie.update_all_count

      redirect_to '/', notice: "全#{result[:all]}件の動画の#{result[:success]}件の再生数を更新しました"
    else
      redirect_to '/', alert: '手動での更新は現在許可されていません'
    end
  end

  def export_counts
    @artists_list = { '全アーティスト' => nil }
    Artist.all.each do |artist|
      @artists_list.store artist.name, artist.id unless artist.movies.empty?
    end
  end

  def do_export_counts
    artist_id = params[:artist] unless params[:artist].blank?

    start_date = nil
    end_date = nil

    unless params[:start_date].blank?
      begin
        start_date = Date.parse params[:start_date]
      rescue ArgumentError
        redirect_to '/', alert: '指定した日付が不正です'
        return
      end
    end

    unless params[:end_date].blank?
      begin
        end_date = Date.parse params[:end_date]
      rescue ArgumentError
        redirect_to '/', alert: '指定した日付が不正です'
        return
      end
    end

    if start_date && end_date && start_date > end_date
      redirect_to '/', alert: '集計開始日は終了日以前を指定してください'
      return
    end

    csv = Movie.export_as_csv(artist_id, start_date, end_date)

    if csv
      send_data csv, type: 'text/csv; charset=shift_jis', filename: '再生数履歴.csv'
    else
      redirect_to '/', alert: 'エクスポートできるデータがありません'
    end
  end

  def login
    session[:admin_session] = nil
  end

  def create_admin_session
    if params[:password] == 'password'
      session[:admin_session] = 'admin_session'

      redirect_to '/', notice: 'ログインに成功しました'
    else
      redirect_to '/login', alert: 'パスワードが間違っています'
    end
  end

  def destroy_admin_session
    session[:admin_session] = nil

    redirect_to '/', notice: 'ログアウトしました'
  end

  private

  def set_artist_and_movie
    artist = Artist.find_by_id(params[:artist_id])

    redirect_to '/', alert: '不正な画面遷移です' if artist.nil?

    @movie = Movie.find_by_id(params[:id])

    redirect_to '/', alert: '不正な画面遷移です' if @movie.nil? || @movie.artist_id != artist.id
  end

  def detect_min(min_act, max_act, step)
    range = max_act - min_act

    min = if (min_act - range / 10).positive?
            if ((min_act - range / 10) / step).ceil > 1
              (((min_act - range / 10) / step).ceil - 1) * step
            else
              0
            end
          else
            0
          end
  end

  def detect_max(min_act, max_act, step)
    range = max_act - min_act

    (((max_act + range / 10) / step).floor + 1) * step
  end
end
