require 'rails_helper'

RSpec.describe Round, type: :model do
  describe "#jid_info" do
    it 'returns an jid_info string' do
      Round.create(jid: 'exp/1', info: 'test', label: 'more info')
      expect(Round.first.jid_info).to eq 'exp/1 - test - more info'
    end
  end
end
