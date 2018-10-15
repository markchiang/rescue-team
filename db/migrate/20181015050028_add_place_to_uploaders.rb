class AddPlaceToUploaders < ActiveRecord::Migration[5.2]
  def change
    add_column :uploaders, :place, :string
  end
end
