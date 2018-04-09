class Round < ApplicationRecord
  def jid_info
    "#{jid} - #{info} - #{label}"
  end
end
