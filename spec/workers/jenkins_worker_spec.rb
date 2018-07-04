require 'rails_helper'
require './app/workers/jenkins_worker'
include ApplicationHelper

RSpec.describe JenkinsWorker, type: :worker do
  describe "GET #exp_rate" do
    before do
      @reop = 'siann1-hak8_boo5-hing5'
      @exp_id = '888'
      @worker = JenkinsWorker.new
    end
    it "returns rate when success" do
      @worker = double
      success_rate = 123.0
      allow(@worker).to receive(:exp_rate).and_return success_rate
      expect(show_rate_status(@worker.exp_rate)).to eq 123.0
    end
    it "returns code '失敗' when fail" do
      result = @worker.send(:exp_rate, @repo, @exp_id, 'FAILURE', 'rate')
      expect(show_rate_status(result)).to eq '失敗'
    end
    it "returns code '正在跑' rate when running" do
      result = @worker.send(:exp_rate, @repo, @exp_id, '', 'rate')
      expect(show_rate_status(result)).to eq '正在跑'
    end
  end
end
