class Zplugin::Content::Docin::Admin::FrontController < Cms::Admin::BaseController
  def pre_dispatch
    @plugin = Sys::Plugin.find(params[:plugin_id])
    @policy = authorize(policy: Zplugin::Content::Docin::FrontPolicy)
  end

  def index
    @items = ::Docin::Content::Import.order(:id)
                                    .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

end