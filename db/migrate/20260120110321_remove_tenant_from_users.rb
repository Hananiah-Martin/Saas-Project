class RemoveTenantFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_reference :users, :tenant, null: false, foreign_key: true
  end
end
