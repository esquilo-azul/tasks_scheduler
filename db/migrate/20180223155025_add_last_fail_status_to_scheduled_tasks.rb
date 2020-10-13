# frozen_string_literal: true

class AddLastFailStatusToScheduledTasks < (
    Rails.version < '5' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  )
  def change
    add_column :scheduled_tasks, :last_fail_status, :string
  end
end
