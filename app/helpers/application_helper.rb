# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  GMAPS_API_KEY = "123"
  
  def dist(distance)
    "%.0f" % distance
  end
  
  def get_key_from_host(host)
    ENV['GMAP_KEY'] = case host
    when 'plotmytrip.heroku.com' then ENV['GMAPS_KEY_HEROKU']
    when 'plotmytrip.com' then ENV['GMAPS_KEY_ROOT']
    when 'www.plotmytrip.com' then ENV['GMAPS_KEY_WWW']
    else
      ENV['GMAPS_KEY_ROOT']
    end
  end
end
