class CreateFacts < ActiveRecord::Migration
  def self.up
    create_table :facts do |t|
      t.datetime :day
      t.float :amount
      t.integer :from_deal_id
      t.integer :to_deal_id 
      t.references :resource, :polymorphic => true
    end
  end

  def self.down
    drop_table :facts
  end
end
