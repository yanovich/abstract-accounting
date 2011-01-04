require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "entity should save" do
	e = Entity.new
    assert !e.save, "Entity without tag saved"
	e.tag = "A Corp."
    assert !e.save, "Entity with repeating tag saved"
  end
end
