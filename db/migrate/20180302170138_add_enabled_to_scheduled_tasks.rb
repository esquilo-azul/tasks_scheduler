# frozen_string_literal: true

class AddEnabledToScheduledTasks < (
    Rails.version < '5' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  )
  def change
    add_column :scheduled_tasks, :enabled, :boolean, null: false, default: true
  end
end
