class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string :tag
      t.float :rate
      t.references :entity
    end
	add_index :deals, [:entity_id, :tag], :unique => true
  end

  def self.down
    drop_table :deals
  end
end
