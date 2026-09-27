# frozen_string_literal: true

RSpec.describe ScheduledTasksController, type: :feature do
  include_context 'active_scaffold_controller',
                  index_path: '/scheduled_tasks'
end
