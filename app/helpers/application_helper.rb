# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def dist(distance)
    "%.0f" % distance
  end
  
  def gmap_key
    case request.host
    when 'plotmytrip.heroku.com' then ENV['GMAPS_KEY_HEROKU']
    when 'plotmytrip.com' then ENV['GMAPS_KEY_ROOT']
    when 'www.plotmytrip.com' then ENV['GMAPS_KEY_WWW']
    else
      'ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ'
    end
  end
end
