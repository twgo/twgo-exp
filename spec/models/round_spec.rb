require 'rails_helper'

RSpec.describe Round, type: :model do
  describe "#jid_info" do
    it 'returns an jid_info string' do
      Round.create(jid: 'exp/1', info: 'test', label: 'more info', branch: 'branch')
      expect(Round.first.jid_info).to eq 'exp/1 - branch - test - more info'
    end
  end
end
