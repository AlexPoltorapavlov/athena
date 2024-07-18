class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.string :chat_name,                    null: false
      # t.string :chat_link,                    null: false
      t.bigint :chat_id,                      null: false

      t.references :group, foreign_key: true, null: true

      t.timestamps
    end

    add_index :chats, :chat_name,             unique: true
    # add_index :chats, :chat_link,             unique: true
    add_index :chats, :chat_id,               unique: true
  end
end
