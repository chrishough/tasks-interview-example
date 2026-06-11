require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user, password: "abcde12345") }

  before do
    post session_path, params: {session: {email: user.email, password: "abcde12345"}}
  end

  describe "POST /tasks" do
    context "with a title" do
      it "creates the task and redirects to the task list" do
        expect {
          post tasks_path, params: {task: {title: "Buy milk"}}
        }.to change(Task, :count).by(1)

        expect(response).to redirect_to(tasks_path)
      end
    end

    context "without a title" do
      it "does not create the task and re-renders the form with an error" do
        expect {
          post tasks_path, params: {task: {title: ""}}
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Title can&#39;t be blank")
      end
    end
  end

  describe "PATCH /tasks/:id" do
    let(:task) { create(:task) }

    context "with a title" do
      it "updates the task and redirects to the task list" do
        patch task_path(task), params: {task: {title: "New title"}}

        expect(task.reload.title).to eq("New title")
        expect(response).to redirect_to(tasks_path)
      end
    end

    context "without a title" do
      it "does not update the task and re-renders the form with an error" do
        patch task_path(task), params: {task: {title: ""}}

        expect(task.reload.title).to be_present
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Title can&#39;t be blank")
      end
    end
  end
end
