class DashboardController < ApplicationController
  before_action :set_artist_and_movie, only: %i[count_history update_count]

  def index
    @selected_artist = if params[:artist].blank?
                         nil
                       else
                         params[:artist]
                       end

    @checked = params[:flag] == 'true'

    movies = Movie.all.order(published_at: 'DESC')
    movies = movies.where(artist_id: @selected_artist) if @selected_artist
    movies = movies.where(flag: true) unless @checked

    @movies = movies.page(params[:page])
  end

  def count_history
    @views = @movie.views.order(update_date: 'DESC').page(params[:page])

    @date_list = []
    @sum_list = []
    @diff_list = []

    @views.reverse.each_with_index do |view, i|
      @date_list << view.update_date.strftime('%Y年%m月%d日')
      @sum_list << view.count
      @diff_list << if i.zero?
                      0
                    else
                      @sum_list[i] - @sum_list[i - 1]
                    end
    end
  end

  def update_counts
    if Rails.configuration.allow_manual_update
      result = Movie.update_all_count

      redirect_to '/', notice: "全#{result[:all]}件の動画の#{result[:success]}件の再生数を更新しました"
    else
      redirect_to '/', alert: '手動での更新は現在許可されていません'
    end
  end

  def export_counts; end

  def do_export_counts
    artist_id = params[:artist] unless params[:artist].blank?
    checked = true if params[:flag] == 'true'

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

    csv = Movie.export_as_csv(artist_id, checked, start_date, end_date)

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
    if params[:password] == Rails.configuration.password
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
end
