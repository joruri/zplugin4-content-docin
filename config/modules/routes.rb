Rails.application.routes.draw do
  mod = 'docin'

  ## admin
  scope "#{Zomeki::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => "#{mod}/admin", :as => mod do
    resources :imports,
      controller: 'imports',
      path: ':content/imports'
    resources :contents,
      :controller => 'admin/contents',
      :path       => 'contents'

    ## contents
    resources :content_contents,
      controller: 'content/contents'
    resources :content_settings,
      controller: 'content/settings',
      path: ':content/content_settings',
      only: [:index, :show, :edit, :update]

  end
end
