class TasksController < ApplicationController
  SORTABLE_COLUMNS = ["title", "due_date"].freeze

  before_action :authenticate_user

  def index
    @tasks = sorted_tasks
    @task = Task.new
  end

  def edit
    @task = Task.find(params[:id])
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      redirect_to tasks_path
    else
      @tasks = sorted_tasks
      render :index, status: :unprocessable_content
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      redirect_to tasks_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @task = Task.find(params[:id])

    if @task.destroy
      redirect_to tasks_path
    else
      # TODO: handle
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :complete, :due_date)
  end

  def sorted_tasks
    return Task.all unless SORTABLE_COLUMNS.include?(params[:sort])

    direction = (params[:direction] == "desc") ? :desc : :asc
    Task.order(params[:sort] => direction)
  end
end
