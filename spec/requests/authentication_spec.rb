require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user) }

  describe "GET /dashboard" do
    it "redirects unauthenticated user to login" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "Authenticated user" do
    before do
      sign_in user
    end

    it "allows access to dashboard" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
