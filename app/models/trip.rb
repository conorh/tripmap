class Trip < ActiveRecord::Base
  has_many :locations
  belongs_to :user
  
  def can_edit?(edit_user)
    edit_user == user
  end
end
