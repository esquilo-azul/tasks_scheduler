Rails.application.routes.draw do
  resources(:scheduled_tasks) do
    as_routes
    collection do
      get :status
      get :status_content
    end
    member do
      get :log
      put :run_now
    end
  end
end
