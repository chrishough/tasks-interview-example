require "rails_helper"

RSpec.describe Task, type: :model do
  it "has a valid factory" do
    expect(build(:task)).to be_valid
  end

  it "is valid without a due date" do
    expect(build(:task, due_date: nil)).to be_valid
  end

  it "stores a due date" do
    task = create(:task, due_date: Date.new(2026, 7, 1))

    expect(task.reload.due_date).to eq(Date.new(2026, 7, 1))
  end
end
