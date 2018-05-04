class CreateDownStreams < ActiveRecord::Migration[5.1]
  def change
    create_table :down_streams do |t|
      t.integer :round_id
      t.string :branch
      t.timestamps
    end
  end
end
