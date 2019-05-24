class CreateViews < ActiveRecord::Migration[5.2]
  def change
    create_table :views do |t|
      t.integer :count
      t.date :update_date
      t.references :movie, foreign_key: true

      t.timestamps
    end
  end
end
