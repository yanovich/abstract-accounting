require 'test_helper'

class DealTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Deal should be stored" do
	d = Deal.new
	assert !d.save, "Empty deal saved"
	d = Deal.new
	d.tag = "purchase 1"
	d.rate = 100.0
	d.entity = Entity.where(:tag => entities(:acorp).tag).first
	assert_raise ActiveRecord::RecordNotUnique do
	  !d.save
	end
  end
end
