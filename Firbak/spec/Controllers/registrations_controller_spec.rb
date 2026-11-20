require "rails_helper"

# Issue #62 - sign-up always creates a student, whatever the form sends
RSpec.describe RegistrationsController, type: :controller do
  let(:valid_params) do
    { name: "Kim Lee", email: "kim.controller@tamu.edu",
      password: "password123", password_confirmation: "password123" }
  end

  it "creates a student account and logs the user in" do
    expect { post :create, params: { user: valid_params } }.to change(User, :count).by(1)

    user = User.find_by(email: "kim.controller@tamu.edu")
    expect(user.role).to eq("student")
    expect(session[:user_id]).to eq(user.id)
    expect(response).to redirect_to(join_session_path)
  end

  it "ignores a role sent with the form" do
    post :create, params: { user: valid_params.merge(role: "instructor") }
    expect(User.find_by(email: "kim.controller@tamu.edu").role).to eq("student")
  end

  it "shows the form again when something is wrong" do
    expect { post :create, params: { user: valid_params.merge(password_confirmation: "nope") } }
      .not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end
end