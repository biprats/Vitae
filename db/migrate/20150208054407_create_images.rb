class CreateImages < ActiveRecord::Migration
  def change
    create_table :watermarks do |t|
      t.integer :user_id
      t.string :link_id
      t.string :payoff_id
      t.string :trigger_id

      t.timestamps
    end
  end
end
