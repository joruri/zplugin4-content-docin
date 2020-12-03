class Docin::Admin::ContentsController < Cms::Admin::BaseController
  layout  'admin/cms'

  def pre_dispatch
    return http_error(403) unless core.user.root?
  end

  def index
    @items = Docin::Content::Import.order(:id)
                                   .paginate(page: params[:page], per_page: params[:limit])
  end

  def install
    Zplugin::Content::Docin::Engine.install
    redirect_to url_for(action: :index), notice: 'インストールしました。'
  end

  def uninstall
    Zplugin::Content::Docin::Engine.uninstall
    redirect_to url_for(action: :index), notice: 'アンインストールしました。'
  end
end
