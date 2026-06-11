module TasksHelper
  def task_sort_link(label:, column:)
    active = params[:sort] == column
    descending = active && params[:direction] == "desc"
    indicator = if active
      descending ? " ↓" : " ↑"
    end

    next_direction = (active && !descending) ? "desc" : "asc"

    link_to "#{label}#{indicator}",
      tasks_path(sort: column, direction: next_direction),
      class: "underline"
  end
end
