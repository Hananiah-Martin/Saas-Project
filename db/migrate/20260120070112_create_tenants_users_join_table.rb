class CreateTenantsUsersJoinTable < ActiveRecord::Migration[8.1]
  def change
    create_join_table :tenants, :users do |t|
      t.index :tenant_id
      t.index :user_id
    end
  end
end
