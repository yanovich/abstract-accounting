require 'test_helper'

class FactTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Store facts" do
    fact1 = Fact.new :amount => 300, :day => DateTime.civil(2008, 02, 04, 0, 0, 0)
    fact1.to = Deal.where(:tag => deals(:purchase).tag).first
    fact1.from = Deal.where(:tag => deals(:metall).tag).first
    fact1.resource = fact1.from.take
    assert !fact1.valid?, "Fact should not be valid"
    fact1.to, fact1.from = fact1.from, fact1.to
    assert fact1.save, "Fact not saved"

    f = Fact.find(fact1.id)
    pp f
    #assert f.from.state(f.day).side == "passive"
    #assert f.from.state(f.day).amount == 30000
    #assert f.to.state(f.day).side == "active"
    #assert f.to.state(f.day).side == 300
  end
end
