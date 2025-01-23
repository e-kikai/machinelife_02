class AddContactsLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :utag,    :string, default: ""
    add_column :contacts, :ip,      :string, default: ""
    add_column :contacts, :host,    :string, default: ""
    add_column :contacts, :ua,      :string, default: ""
    add_column :contacts, :referer, :string, default: ""
    add_column :contacts, :r,       :string, default: "", null: false

    add_index :contacts, :machine_id
    add_index :contacts, :created_at
  end
end
