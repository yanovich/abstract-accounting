class CreateResources < ActiveRecord::Migration
  def self.up
	create_table :assets do |t|
		t.string :tag
	end
	create_table :money, :id => false do |t|
		t.integer :num_code
		t.string :alpha_code
	end
	add_index :money, :num_code, :unique => true
	add_index :money, :alpha_code, :unique => true
	add_index :assets, :tag, :unique => true
  end

  def self.down
	drop_table :assets
	drop_table :money
  end
end
