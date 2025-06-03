require 'addons/redscribe/mrblib/resource'

resource :chapter do
  resource :image
  resources :stage => :stages do
    resource :image
  end
end
