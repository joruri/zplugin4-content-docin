class Docin::Admin::ImportsController < Docin::Admin::BaseController

  def pre_dispatch
    @content = Docin::Content::Import.in_site(core.site).find(params[:content])
    @policy = authorize(nil, content: @content, policy: Docin::ImportPolicy)
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
