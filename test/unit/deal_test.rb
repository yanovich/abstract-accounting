require 'test_helper'

class DealTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Deal should be stored" do
	d = Deal.new
	assert !d.save, "Empty deal saved"

	e = Entity.where(:tag => entities(:acorp).tag).first
	m = Money.where(:num_code => money(:usd).num_code).first
	a = Asset.where(:tag => assets(:steel).tag).first

	d = Deal.new
	d.tag = "purchase 1"
	d.rate = 100.0
	d.entity = e 
	d.give = m
	d.take = a
	assert_raise ActiveRecord::RecordNotUnique do
	  !d.save
	end

	d = Deal.where(:tag => "purchase 1").first
	assert e.deals.first == d
	assert m.deal_gives.where(:tag => "purchase 1").first == d
	assert a.deal_takes.where(:tag => "purchase 1").first == d
  end
end
