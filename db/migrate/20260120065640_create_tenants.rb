class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name
      t.references :tenant, index: true, foreign_key: true
      t.timestamps
    end
    add_index :tenants, :name
  end
end
