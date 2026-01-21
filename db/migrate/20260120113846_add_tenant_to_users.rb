class AddTenantToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :tenant, null: true, foreign_key: true
  end
end
