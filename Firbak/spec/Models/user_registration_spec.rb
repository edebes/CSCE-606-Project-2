require "rails_helper"

# Issue #62 - rules that apply when someone signs up
RSpec.describe User, "registration", type: :model do
  def sign_up(**overrides)
    User.new({ name: "Kim Lee", email: "kim.signup@tamu.edu", role: "student",
               password: "password123", password_confirmation: "password123" }.merge(overrides))
  end

  it "accepts a name, email and matching passwords" do
    expect(sign_up.save(context: :registration)).to be true
  end

  it "requires a password" do
    user = sign_up(password: nil, password_confirmation: nil)
    expect(user.save(context: :registration)).to be false
    expect(user.errors[:password]).to be_present
  end

  it "requires a password of at least 8 characters" do
    user = sign_up(password: "short", password_confirmation: "short")
    expect(user.save(context: :registration)).to be false
    expect(user.errors[:password]).to be_present
  end

  it "requires the confirmation to match" do
    user = sign_up(password_confirmation: "different123")
    expect(user.save(context: :registration)).to be false
    expect(user.errors[:password_confirmation]).to be_present
  end

  it "lets the new user log in with their password" do
    user = sign_up
    user.save!(context: :registration)
    expect(User.find_by(email: "KIM.SIGNUP@tamu.edu").authenticate("password123")).to eq(user)
  end
end