Rails.application.routes.draw do
  mod = 'docin'

  ## admin
  scope "#{Zomeki::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources :contents,
      :controller => 'admin/contents',
      :path       => 'contents' do
        collection do
          post :install, :uninstall
        end
      end
    resources :imports,
      :controller => 'admin/imports',
      :path       => ':content/imports'
  end
end
