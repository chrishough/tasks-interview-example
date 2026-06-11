require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user, password: "abc123") }

  before do
    post session_path, params: {session: {email: user.email, password: "abc123"}}
  end

  describe "POST /tasks" do
    it "creates a task with a due date" do
      post tasks_path, params: {task: {title: "Book flights", due_date: "2026-07-01"}}

      expect(response).to redirect_to(tasks_path)
      expect(Task.last.due_date).to eq(Date.new(2026, 7, 1))
    end

    it "creates a task without a due date" do
      post tasks_path, params: {task: {title: "Book flights"}}

      expect(response).to redirect_to(tasks_path)
      expect(Task.last.due_date).to be_nil
    end
  end

  describe "PATCH /tasks/:id" do
    it "updates the due date" do
      task = create(:task)

      patch task_path(task), params: {task: {due_date: "2026-08-15"}}

      expect(response).to redirect_to(tasks_path)
      expect(task.reload.due_date).to eq(Date.new(2026, 8, 15))
    end

    it "clears the due date" do
      task = create(:task, due_date: Date.new(2026, 7, 1))

      patch task_path(task), params: {task: {due_date: ""}}

      expect(response).to redirect_to(tasks_path)
      expect(task.reload.due_date).to be_nil
    end
  end

  describe "GET /tasks" do
    it "shows the task's due date" do
      create(:task, title: "Book flights", due_date: Date.new(2026, 7, 1))

      get tasks_path

      expect(response.body).to include("Due Jul 1, 2026")
    end
  end
end
