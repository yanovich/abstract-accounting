class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.references :deal
      t.string :side
      t.float :amount
      t.datetime :start
      t.datetime :paid
    end
  end

  def self.down
    drop_table :states
  end
end
