class Entity < ActiveRecord::Base
	validates_presence_of :tag
	validates_uniqueness_of :tag
	has_many :deals
end
