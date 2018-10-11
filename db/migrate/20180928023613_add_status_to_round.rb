class AddStatusToRound < ActiveRecord::Migration[5.1]
  def change
    add_column :rounds, :status, :string, default: 'added'
  end
end
