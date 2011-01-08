class FactValidator #< ActiveRecord::Validator
	def validate(record)
		record.errors[:base] << "bad resource" unless
			record.resource == record.from.take \
			and	record.resource == record.to.give
	end
end

class Fact < ActiveRecord::Base
	validates_presence_of :day
	validates_presence_of :amount
	validates_presence_of :resource
	validates_presence_of :from
	validates_presence_of :to
	validates_with FactValidator
	belongs_to :resource, :polymorphic => true
	belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
	belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"
end


