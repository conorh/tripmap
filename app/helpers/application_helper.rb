# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def dist(distance)
    "%.0f" % distance
  end
end
