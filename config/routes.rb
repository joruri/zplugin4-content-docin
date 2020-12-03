Zplugin::Content::Docin::Engine.routes.draw do
  root 'docin/admin/contents#index'
  namespace 'docin' do
    scope module: 'admin' do
      resources :contents
    end
  end
end
