class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.string :group_name, null: false

      t.timestamps
    end

    add_index :groups, :group_name, unique: true
  end
end
