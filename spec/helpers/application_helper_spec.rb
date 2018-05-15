require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  describe "#has_up(repo)" do
    it "return y if has_up repo" do
      expect(helper.has_up('gi2-gian5_boo5-hing5')).to eq 'y'
    end
    it "return n if not has_up repo" do
      expect(helper.has_up('siann1-hak8_boo5-hing5')).to eq 'n'
    end
  end

  describe "#show_rate_status(rate)" do
    before do
      @round_success = Round.create(rate: 123.0)
      @round_no_print = Round.create(rate: 0.0)
      @round_fail = Round.create(rate: 999.0)
      @round_running = Round.create(rate: 888.0)
    end
    it "returns 失敗" do
      expect(helper.show_rate_status(@round_fail.rate)).to eq '失敗'
    end
    it "returns 無印結果" do
      expect(helper.show_rate_status(@round_no_print.rate)).to eq '無印結果'
    end
    it "returns 正在跑" do
      expect(helper.show_rate_status(@round_running.rate)).to eq '正在跑'
    end
    it "returns rate" do
      expect(helper.show_rate_status(@round_success.rate)).to eq 123.0
    end
  end
end
