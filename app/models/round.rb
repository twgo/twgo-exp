class Round < ApplicationRecord
  has_many :down_streams
  def jid_info
    "#{jid} - #{branch} - #{info} - #{label}"
  end
end
