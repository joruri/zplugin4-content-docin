class Docin::Admin::ImportsController < Docin::Admin::BaseController
  def pre_dispatch
    @content = Docin::Content::Import.in_site(core.site).find(params[:content])
    @policy = authorize(Docin::ImportPolicy, content: @content)
  end

  def index
    @log = @content.log
  end

  def create
    if params[:confirm]
      confirm
    elsif params[:register]
      register
    end
  end

  def start
    if @content.setting.import_path.blank?
      return redirect_to url_for(action: :index), notice: "CSVファイルのパスを設定してください。"
    end
    if !File.exist?(@content.setting.import_path)
      return redirect_to url_for(action: :index), notice: "CSVファイルがありません。"
    end
    Docin::ImportJob.perform_later(@content, user: core.user, path: @content.setting.import_path)
    return redirect_to url_for(action: :index), notice: "取り込みを開始しました。"
  end

  def export
    body = File.exist?(@content.export_csv_path) ? File.read(@content.export_csv_path) : ''
    if body.blank?
      Docin::ExportCsvJob.perform_later(@content)
      return redirect_to url_for(action: :index), notice: "CSVファイルを作成中です。"
    else
      return send_data platform_encode(body), type: 'text/csv', filename: "import_result_#{Time.now.to_i}.csv"
    end
  end

  private

  def confirm
    @csv = NKF.nkf('-w', params[:item][:file].read)
    @rows = Docin::Parse::CsvInteractor.call(content: @content, user: core.user, csv: @csv).results
    @rows.each(&:validate)
  rescue CSV::MalformedCSVError => e
    return redirect_to url_for(action: :index), alert: "CSVファイルの形式が不正です。#{e}"
  end

  def register
    Docin::ImportJob.perform_later(@content, user: core.user, csv: params[:item][:csv])
    return redirect_to url_for(action: :index), notice: 'CSVファイルのインポートを開始しました。'
  end
end
