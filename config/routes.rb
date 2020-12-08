Zplugin::Content::Docin::Engine.routes.draw do
  root 'admin/front#index'
  scope module: 'admin' do
    resource :front, only: [:index] do
      match 'install' => 'front#install', via: :post
      match 'uninstall' => 'front#uninstall', via: :post
    end
  end
end
