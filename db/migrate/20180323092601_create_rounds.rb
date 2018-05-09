class CreateRounds < ActiveRecord::Migration[5.1]
  def change
    create_table :rounds do |t|
      t.string :jid
      t.string :cid
      t.string :did
      t.string :info
      t.string :label
      t.decimal :rate, precision: 10, scale: 2
      t.string :repo
      t.string :expid
      t.string :sha1
      t.string :branch

      t.timestamps
    end
  end
end
