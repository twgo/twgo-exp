require 'rails_helper'
require './app/workers/jenkins_worker'

RSpec.describe JenkinsWorker, type: :worker do
  describe "GET #exp_rate" do
    # todo stub
    # it "returns tri4 no si rate" do
    #   input_repo = 'siann1-hak8_boo5-hing5'
    #   input_exp_id = '59'
    #   input_status = 'SUCCESS'
    #   my_object = JenkinsWorker.new
    #   my_exp_rate = my_object.send(:exp_rate, input_repo, input_exp_id, input_status)
    #   expect(my_exp_rate).to eq '29.83'
    # end
  end
end
