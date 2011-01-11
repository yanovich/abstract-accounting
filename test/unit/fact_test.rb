require 'test_helper'

class FactTest < ActiveSupport::TestCase
  test "Store states" do
    s = State.new
    assert s.side == "active", "State is not initialized"
    assert s.invalid?, "Empty state is valid"
    s.deal = Deal.first
    assert s.invalid?, "State with deal is valid"
    s.start = DateTime.civil(2011, 1, 8)
    s.amount = 5000
    s.side = "passive"
    assert s.valid?, "State is invalid"
    s.side = "passive2"
    assert s.invalid?, "State with wrong side is valid"
    s.side = "active"
    assert s.save, "State is not saved"

    assert Deal.first.state(s.start) == s, "State from first deal is not equal saved state"
    
    s.destroy
    assert State.all.count == 0, "State is not deleted"
  end

  test "Store facts" do
    fact1 = Fact.new :amount => 300, :day => DateTime.civil(2008, 02, 04, 0, 0, 0)
    fact1.to = Deal.where(:tag => deals(:purchase).tag).first
    fact1.from = Deal.where(:tag => deals(:metall).tag).first
    fact1.resource = fact1.from.take
    assert !fact1.valid?, "Fact should not be valid"
    fact1.to, fact1.from = fact1.from, fact1.to
    assert fact1.save, "Fact not saved"

    f = Fact.find(fact1.id)
    assert f.from.state(f.day).side == "passive"
    assert f.from.state(f.day).amount == 30000
    assert f.to.state(f.day).side == "active"
    assert f.to.state(f.day).amount == 300
  end
end
