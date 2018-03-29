class HTTPSource
  attr_reader :city, :endpoint, :timezone

  def initialize args
    @city     = args[:city]
    @endpoint = URI.parse args[:endpoint]
    @timezone = args[:timezone]
  end

  def response
    Net::HTTP.get @endpoint
  end
end

class JSONSource < HTTPSource
  def response
    JSON.parse super
  end
end

class HTMLSource < HTTPSource
  def response
    Oga.parse_html super
  end
end

class StreetFood < JSONSource
  def response
    super['vendors'].map do |key, row|
      row['open'].map do |opening|
        start  = Time.at(opening['start']).utc
        stop   = Time.at(opening['end']).utc
        start -= 7.days if start == Date.today + 7.days
        stop  -= 7.days if stop  == Date.today + 7.days
        opening.update(
          city:      @city,
          endpoint:  @endpoint.to_s,
          latitude:  opening['latitude'],
          longitude: opening['longitude'],
          place:     opening['display'],
          site:      row['url'],
          source:    self.class.to_s,
          start:     start.to_s,
          stop:      stop.to_s,
          timezone:  @timezone,
          truck:     row['name'])
        .select{|k,v| k.is_a? Symbol }
      end
    end.flatten
  end
end

class CityOfBoston < HTMLSource
  def response
    super.xpath("//div[@class=department-components]").map do |row|
    end
    super.xpath("//tr[@class='trFoodTrucks']").map do |row|
      a_node     = row.xpath(".//td[@class='com']/a").first
      dow_node   = row.xpath(".//td[@class='dow']").first
      tod_node   = row.xpath(".//td[@class='tod']").first
      place_node = row.xpath(".//td[@class='loc']").first

      # Get values from nodes
      truck = a_node.text.strip
      site  = a_node.attribute('href').value.strip
      place = place_node.children.last.text.strip

      # Get start/stop
      date = Chronic.parse(dow_node.text).to_date
      date -= 7.days if date == Date.today + 7.days
      datetime = date.in_time_zone @timezone

      meal  = Meal.parse tod_node.text
      delta = [meal.hours.first, meal.hours.last]
      delta[-1] += 23 if delta.last < delta.first
      start = (datetime + delta.first.hours).utc
      stop  = (datetime + delta.last.hours).utc

      { city:      @city,
        endpoint:  @endpoint.to_s,
        latitude:  nil,
        longitude: nil,
        place:     place,
        site:      site,
        source:    self.class.to_s,
        start:     start.to_s,
        stop:      stop.to_s,
        timezone:  @timezone,
        truck:     truck } unless stop <= Time.now.utc
    end.compact
  end
end

class RoseKennedyGreenway < HTMLSource
  def response
    script = super.xpath("//script").last
    var    = script.text.strip.split(/\n/).first.strip
    json   = JSON.parse var.sub(/\A\$(.*?) = (.*?);\z/, "{\"\\1\": \\2}")
    json["trucksJSON"].map do |id, truck|
      truck["locations"].map do |location|
        location["days"].map do |day|
          if Date.today.wday == day.to_i
            date = Date.today
          else
            date = Chronic.parse("Next #{Date::DAYNAMES[day.to_i]}")
          end
          datetime = date.in_time_zone @timezone

          meal  = Meal::LUNCH
          delta = [meal.hours.first, meal.hours.last]
          delta[-1] += 23 if delta.last < delta.first
          start = (datetime + delta.first.hours).utc
          stop  = (datetime + delta.last.hours).utc

          { city:      @city,
            endpoint:  @endpoint.to_s,
            latitude:  nil,
            longitude: nil,
            place:     location["name"],
            site:      truck["url"],
            source:    self.class.to_s,
            start:     start.to_s,
            stop:      stop.to_s,
            timezone:  @timezone,
            truck:     truck["name"] }
        end
      end.flatten
    end.flatten
  end
end
