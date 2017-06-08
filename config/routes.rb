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
  get '/tasks_scheduler_daemon', to: 'tasks_scheduler_daemon#index', as: :tasks_scheduler_daemon
  post '/tasks_scheduler_daemon/:tasks_scheduler_execute_action',
       to: 'tasks_scheduler_daemon#execute', as: :execute_tasks_scheduler_daemon
  get '/tasks_scheduler_daemon/running', to: 'tasks_scheduler_daemon#running',
                                         as: :running_tasks_scheduler_daemon
end
