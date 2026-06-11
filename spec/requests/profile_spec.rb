require "rails_helper"

RSpec.describe "Profile", type: :request do
  context "when signed in" do
    let(:user) { create(:user) }

    before do
      post session_path, params: {session: {email: user.email, password: user.password}}
    end

    describe "GET /profile/edit" do
      it "shows the profile form with the user's details" do
        get edit_profile_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(user.name)
        expect(response.body).to include(user.email)
      end
    end

    describe "PATCH /profile" do
      context "with valid details" do
        it "updates the user and redirects back to the profile" do
          patch profile_path, params: {user: {name: "New Name", email: "new@example.com"}}

          expect(user.reload.name).to eq("New Name")
          expect(user.email).to eq("new@example.com")
          expect(response).to redirect_to(edit_profile_path)

          follow_redirect!
          expect(response.body).to include("Profile updated")
        end
      end

      context "with an avatar image" do
        it "attaches the avatar" do
          patch profile_path, params: {user: {avatar: fixture_file_upload("avatar.png", "image/png")}}

          expect(user.reload.avatar).to be_attached
          expect(response).to redirect_to(edit_profile_path)
        end
      end

      context "without a name" do
        it "does not update the user and re-renders the form with an error" do
          patch profile_path, params: {user: {name: ""}}

          expect(user.reload.name).to be_present
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Name can&#39;t be blank")
        end
      end

      context "with a file that is not an image" do
        it "does not attach the avatar and re-renders the form with an error" do
          patch profile_path, params: {user: {avatar: fixture_file_upload("not_an_image.txt", "text/plain")}}

          expect(user.reload.avatar).not_to be_attached
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Avatar must be a PNG, JPEG, GIF, or WebP image")
        end
      end

      context "with another user's email" do
        it "does not update the user and re-renders the form with an error" do
          other_user = create(:user)

          patch profile_path, params: {user: {email: other_user.email}}

          expect(user.reload.email).not_to eq(other_user.email)
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Email has already been taken")
        end
      end
    end
  end

  context "when signed out" do
    it "redirects to sign in" do
      get edit_profile_path

      expect(response).to redirect_to(new_session_path)
    end
  end
end
