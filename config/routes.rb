# frozen_string_literal: true

Rails.application.routes.draw do
  concern :active_scaffold, ActiveScaffold::Routing::Basic.new(association: true)
  resources(:scheduled_tasks, concerns: :active_scaffold) do
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
  get '/tasks_scheduler_daemon/status', to: 'tasks_scheduler_daemon#status',
                                        as: :status_tasks_scheduler_daemon
  get '/tasks_scheduler_daemon/download_log/:log_key', to: 'tasks_scheduler_daemon#download_log',
                                                       as: :download_log_tasks_scheduler_daemon
end
