class Zplugin::Content::Docin::Admin::FrontController < Cms::Admin::BaseController
  def pre_dispatch
    @plugin = Sys::Plugin.find(params[:plugin_id])
    @policy = authorize
  end

  def index
    @items = ::Docin::Content::Import.order(:id)
                                    .paginate(page: params[:page], per_page: params[:limit])
  end
  
  def install
    redirect_to url_for(action: :index)
  end

  def uninstall
    redirect_to url_for(action: :index)
  end

end