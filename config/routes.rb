Zplugin::Content::Docin::Engine.routes.draw do
  root 'admin/front#index'
  scope module: 'admin' do
    resources :front, only: [:index]
  end
end
