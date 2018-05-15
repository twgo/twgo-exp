require 'rails_helper'
require './app/workers/jenkins_worker'

RSpec.describe JenkinsWorker, type: :worker do
  describe "GET #exp_rate" do
    before do
      @reop = 'siann1-hak8_boo5-hing5'
      @exp_id = '888'
      @round_success_rate = 123.0
      @round_no_print_rate_code = 0.0
      @round_fail_rate_code = 999.0
      @round_running_rate_code = 888.0
      @worker = JenkinsWorker.new
    end
    it "returns rate when success" do
      @worker = double
      allow(@worker).to receive(:exp_rate).and_return @round_success_rate
      expect(@worker.exp_rate).to eq @round_success_rate
    end
    it "returns code 999.0 when fail" do
      expect(@worker.send(:exp_rate, @repo, @exp_id, 'FAILURE')).to eq @round_fail_rate_code
    end
    it "returns code 888.0 rate when running" do
      expect(@worker.send(:exp_rate, @repo, @exp_id, '')).to eq @round_running_rate_code
    end
  end
end
