class CreateExps < ActiveRecord::Migration[5.1]
  def change
    create_table :exps do |t|
      t.string :upstream
      t.string :upstream_info
      t.string :repo
      t.string :branch
      t.string :content
      t.string :sha
      t.string :status, default: 'added'
      t.timestamps
    end
  end
end
