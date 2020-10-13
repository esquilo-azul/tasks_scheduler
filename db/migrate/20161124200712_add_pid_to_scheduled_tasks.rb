# frozen_string_literal: true

class AddPidToScheduledTasks < (
    Rails.version < '5' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  )
  def change
    add_column :scheduled_tasks, :pid, :integer
  end
end
