class CreateUploaders < ActiveRecord::Migration[5.2]
  def change
    create_table :uploaders do |t|
      t.timestamp :time
      t.string :content

      t.timestamps
    end
  end
end
