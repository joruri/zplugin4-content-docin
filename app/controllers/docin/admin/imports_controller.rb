class Docin::Admin::ImportsController < Cms::Admin::BaseController
  #include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Docin::Content::Import.find(params[:content])
    return error_auth unless core.user.has_priv?(:read, concept: @content.concept)
  end

  def index
  end

  def create
    if params[:confirm]
      confirm
    elsif params[:register]
      register
    end
  end

  private

  def confirm
    @csv = NKF.nkf('-w', params[:item][:file].read)
    @rows = Docin::ParseService.new(@content, core.user).parse(@csv)
    @rows.each(&:validate)
  rescue CSV::MalformedCSVError => e
    return redirect_to url_for(action: :index), notice: "CSVファイルの形式が不正です。#{e}"
  end

  def register
    Docin::ImportJob.perform_now(@content, core.user, params[:item][:csv])
    return redirect_to url_for(action: :index), notice: "CSVファイルのインポートが完了しました。"
  end
end
