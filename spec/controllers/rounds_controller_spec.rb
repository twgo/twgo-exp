require 'rails_helper'
RSpec.describe RoundsController, type: :controller do
  before do
    allow_any_instance_of(RoundsController).to receive(:ci_answer)
    allow_any_instance_of(RoundsController).to receive(:ci_best)
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
  describe "download results" do
    let(:answer_file) { "#{Rails.root}/public/results/text.filt" }
    let(:best_file) { "#{Rails.root}/public/results/best.txt" }
    it 'download #answer' do
      answer_rounds_path(repo: 'siann1-hak8_boo5-hing5',expid: 1)
      %x(touch #{answer_file})
      expect(File).to exist answer_file
    end
    it 'download #best results' do
      best_rounds_path(repo: 'siann1-hak8_boo5-hing5',expid: 1)
      %x(touch #{best_file})
      expect(File).to exist best_file
    end
  end
end
