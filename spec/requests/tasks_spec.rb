require "rails_helper"

RSpec.describe "Tasks", type: :request do
  context "when signed in" do
    let(:user) { create(:user) }

    before do
      post session_path, params: {session: {email: user.email, password: user.password}}
    end

    describe "POST /tasks" do
      context "with a title" do
        it "creates the task and redirects to the task list" do
          expect {
            post tasks_path, params: {task: {title: "Buy milk"}}
          }.to change(Task, :count).by(1)

          expect(response).to redirect_to(tasks_path)
        end

        it "creates the task with a due date" do
          post tasks_path, params: {task: {title: "Book flights", due_date: "2026-07-01"}}

          expect(response).to redirect_to(tasks_path)
          expect(Task.last.due_date).to eq(Date.new(2026, 7, 1))
        end

        it "creates the task without a due date" do
          post tasks_path, params: {task: {title: "Book flights"}}

          expect(response).to redirect_to(tasks_path)
          expect(Task.last.due_date).to be_nil
        end

        it "creates the task assigned to a user" do
          assignee = create(:user)

          post tasks_path, params: {task: {title: "Book flights", user_id: assignee.id}}

          expect(response).to redirect_to(tasks_path)
          expect(Task.last.user).to eq(assignee)
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

      it "marks a task complete" do
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

      it "assigns the task to a user" do
        assignee = create(:user)

        patch task_path(task), params: {task: {user_id: assignee.id}}

        expect(response).to redirect_to(tasks_path)
        expect(task.reload.user).to eq(assignee)
      end

      it "unassigns the task" do
        task = create(:task, user: create(:user))

        patch task_path(task), params: {task: {user_id: ""}}

        expect(response).to redirect_to(tasks_path)
        expect(task.reload.user).to be_nil
      end

      it "updates the due date" do
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

      it "shows the task's assignee" do
        assignee = create(:user, name: "Avery Quill")
        create(:task, user: assignee)

        get tasks_path

        expect(response.body).to include("Avery Quill")
      end

      it "shows unassigned tasks as Unassigned" do
        create(:task)

        get tasks_path

        expect(response.body).to include("Unassigned")
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
