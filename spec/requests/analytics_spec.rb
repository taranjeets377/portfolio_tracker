require "rails_helper"

RSpec.describe "Analytics", type: :request do
  let(:user) { create(:user) }

  describe "GET /analytics" do
    it "is accessible to authenticated users" do
      sign_in user

      get analytics_path

      expect(response).to have_http_status(:success)
    end

    it "loads successfully" do
      sign_in user

      get analytics_path

      expect(response.body).to include("Analytics")
      expect(response.body).to include("Total Invested")
      expect(response.body).to include("Allocation chart will be added in PPT-101")
      expect(response.body).to include("Growth chart will be added in PPT-102")
      expect(response.body).to include("Not yet calculated")
    end
  end
end
