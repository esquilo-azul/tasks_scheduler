# frozen_string_literal: true

class AddStatusAttributesToScheduledTasks < (
    Rails.version < '5' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  )
  def change
    add_column :scheduled_tasks, :last_run_start, :datetime
    add_column :scheduled_tasks, :last_run_successful_start, :datetime
    add_column :scheduled_tasks, :last_run_successful_end, :datetime
    add_column :scheduled_tasks, :last_run_unsuccessful_start, :datetime
    add_column :scheduled_tasks, :last_run_unsuccessful_end, :datetime
  end
end
