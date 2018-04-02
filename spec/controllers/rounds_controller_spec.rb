require 'rails_helper'
RSpec.describe RoundsController, type: :controller do
  before do
  end
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_success
    end
  end
end
