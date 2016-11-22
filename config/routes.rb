Rails.application.routes.draw do
  resources(:scheduled_tasks) { as_routes }
end
