require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "requires a name" do
    user = build(:user, name: "")

    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it "requires an email" do
    user = build(:user, email: "")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "requires a well-formed email" do
    user = build(:user, email: "not-an-email")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  it "requires a unique email, ignoring case" do
    existing_user = create(:user)
    user = build(:user, email: existing_user.email.upcase)

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("has already been taken")
  end

  describe "avatar" do
    it "accepts a PNG image" do
      user = build(:user)
      user.avatar.attach(fixture_file_upload("avatar.png", "image/png"))

      expect(user).to be_valid
    end

    it "rejects a file that is not an image" do
      user = build(:user)
      user.avatar.attach(fixture_file_upload("not_an_image.txt", "text/plain"))

      expect(user).not_to be_valid
      expect(user.errors[:avatar]).to include("must be a PNG, JPEG, GIF, or WebP image")
    end
  end
end
