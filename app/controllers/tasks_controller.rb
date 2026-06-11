class TasksController < ApplicationController
  before_action :authenticate_user
  before_action :set_users, only: [:index, :edit, :create, :update]

  def index
    @tasks = Task.includes(:user)
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
      @tasks = Task.all
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

  def set_users
    @users = User.order(:name)
  end

  def task_params
    params.require(:task).permit(:title, :description, :complete, :due_date, :user_id)
  end
end
