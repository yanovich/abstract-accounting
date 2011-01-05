require 'test_helper'

class ChartTest < ActiveSupport::TestCase
  test "chart should be saved" do
    c = Chart.new
	assert !c.save, "Empty chart saved"
	c.money = Money.where(:alpha_code => "USD").first
	assert !c.save, "Dublicate chart saved"
  end
end
