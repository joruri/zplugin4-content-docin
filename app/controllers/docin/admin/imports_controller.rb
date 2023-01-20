class Docin::Admin::ImportsController < Docin::Admin::BaseController
  def pre_dispatch
    @content = Docin::Content::Import.in_site(core.site).find(params[:content])
    @policy = authorize(Docin::ImportPolicy, content: @content)
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
    return redirect_to url_for(action: :index), alert: "CSVファイルの形式が不正です。#{e}"
  end

  def register
    Docin::ImportJob.perform_later(@content, user: core.user, csv: params[:item][:csv])
    return redirect_to url_for(action: :index), notice: 'CSVファイルのインポートを開始しました。'
  end
end
