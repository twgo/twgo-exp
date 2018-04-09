require 'rails_helper'
RSpec.describe GithubsController, type: :controller do
  before do
    @params = {branch: 'siann0102', repo: 'gi2-gian5_boo5-hing5'}
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: @params
      expect(response).to be_success
    end
    
    it "returns repo's Dockerfile code" do
      my_object = GithubsController.new
      origin_code = my_object.send(:get_dockerfile, @params[:repo], @params[:branch])
      expect(origin_code).to start_with("FROM")
    end
  end
end
