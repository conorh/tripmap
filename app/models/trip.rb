class Trip < ActiveRecord::Base
  has_many :locations
end
