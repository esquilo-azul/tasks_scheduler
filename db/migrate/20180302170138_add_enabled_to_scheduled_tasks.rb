# frozen_string_literal: true

class AddEnabledToScheduledTasks < ActiveRecord::Migration
  def change
    add_column :scheduled_tasks, :enabled, :boolean, null: false, default: true
  end
end
