require "rails_helper"

RSpec.describe "Tasks", type: :request do
  describe "PATCH /tasks/:id" do
    context "when signed in" do
      let(:user) { create(:user) }

      before do
        post session_path, params: {session: {email: user.email, password: user.password}}
      end

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
end
