require "rails_helper"

RSpec.describe "Tasks", type: :request do
  context "when signed in" do
    let(:user) { create(:user) }

    before do
      post session_path, params: {session: {email: user.email, password: user.password}}
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
      it "marks a task complete" do
        task = create(:task)

        patch task_path(task), params: {task: {complete: true}}

        expect(task.reload).to be_complete
        expect(response).to redirect_to(tasks_path)
      end

      it "marks a completed task incomplete" do
        task = create(:task, complete: true)

        patch task_path(task), params: {task: {complete: false}}

        expect(task.reload).not_to be_complete
        expect(response).to redirect_to(tasks_path)
      end

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

  context "when signed out" do
    it "redirects to sign in without updating the task" do
      task = create(:task)

      patch task_path(task), params: {task: {complete: true}}

      expect(task.reload).not_to be_complete
      expect(response).to redirect_to(new_session_path)
    end
  end
end
