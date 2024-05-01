admin_scope 'docin/c:concept', module: 'docin/admin' do
  scope ':content' do
    resources :imports do
      collection do
        get :start
      end
    end
    resources :content_settings,
      controller: 'content/settings',
      only: [:index, :show, :edit, :update]
  end

  namespace :content do
    resources :imports,
      only: [:show, :edit, :update]
  end
end
