require 'rails_helper'
RSpec.describe RoundsController, type: :controller do
  before do
  end
  # describe "GET #index" do
  #   it "returns a success response" do
  #     get :index
  #     expect(response).to be_success
  #   end
  # end
  describe "#update" do
    it 'update label of a round' do
      Round.create(jid: 'exp/1', info: 'test', label: 'info')
      post :update, params: {id: 1, round: {id: 1, label: 'update info'}}
      expect(Round.first.label).to eq 'update info'
    end
  end
  describe "GET #refresh" do
    # it "refresh CI data" do
    # 待掛VPN以測試
    #   get :refresh
    #   expect(response).to redirect_to(rounds_path)
    # end
  end
end
