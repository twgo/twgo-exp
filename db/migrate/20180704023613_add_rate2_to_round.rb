class AddRate2ToRound < ActiveRecord::Migration[5.1]
  def change
    add_column :rounds, :rate2, :decimal
  end
end
