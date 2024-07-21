class ChatsGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :chats_groups do |t|
      t.references :group
      t.references :chat
    end
  end
end
