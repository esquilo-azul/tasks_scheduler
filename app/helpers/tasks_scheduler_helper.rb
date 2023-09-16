# frozen_string_literal: true

module TasksSchedulerHelper
  def tasks_scheduler_navbar
    tag.navbar do
      safe_join(tasks_scheduler_navbar_entries.map { |label, path| link_to label, path }, ' | ')
    end
  end

  def tasks_scheduler_navbar_entries
    ::Rails.application.root_menu.sub(:admin).sub(:tasks_scheduler).children
           .map { |child| [child.label, child.view_path(self)] }
           .to_h
  end
end
