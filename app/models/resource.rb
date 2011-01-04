class Asset < ActiveRecord::Base
	validates_presence_of :tag
	validates_uniqueness_of :tag
end

class Money < ActiveRecord::Base
	set_primary_key "num_code"
	validates_presence_of :num_code
	validates_presence_of :alpha_code
	validates_uniqueness_of :num_code
	validates_uniqueness_of :alpha_code
end
