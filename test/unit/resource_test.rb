require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "asset should store" do
	a = Asset.new
	assert !a.save, "Asset with empty tag saved"
	a.tag = "steel, tn"
	assert !a.save, "Asset with repeating tag saved"
  end

  test "money should store" do
	m = Money.new
	m.num_code = 840
	m.alpha_code = "BYR"
	assert !m.save, "Money with repeating tag saved"
	m = Money.new
	assert !m.save, "Money with empty num_code and alpha_code saved"
	m.num_code = 643
	assert !m.save, "Money with empty alpha_code saved"
	m.alpha_code = "RUB"
	assert m.save
  end
end
