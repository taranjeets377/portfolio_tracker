require "rails_helper"

RSpec.describe "User Signup", type: :request do
  it "creates a new user" do
    get new_user_registration_path

    expect {
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    }.to change(User, :count).by(1)
  end
end
