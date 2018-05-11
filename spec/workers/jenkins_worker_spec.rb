require 'rails_helper'
require './app/workers/jenkins_worker'

RSpec.describe JenkinsWorker, type: :worker do
  describe "GET #exp_rate" do
    it "returns tri4 no si rate" do
      my_object = JenkinsWorker.new
      origin_code = my_object.send(:exp_rate, 'siann1-hak8_boo5-hing5', '59', 'SUCCESS')
      expect(origin_code).to eq '29.83'
    end
  end
end
