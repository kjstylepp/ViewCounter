class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.string :youtube_id
      t.string :title
      t.references :artist, foreign_key: true
      t.string :thumb_url

      t.timestamps
    end
  end
end
