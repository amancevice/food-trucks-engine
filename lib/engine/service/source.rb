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
        opening.update(
          city:      @city,
          endpoint:  @endpoint.to_s,
          latitude:  opening['latitude'],
          longitude: opening['longitude'],
          place:     opening['display'],
          site:      row['url'],
          source:    self.class.to_s,
          start:     Time.at(opening['start']).utc.to_s,
          stop:      Time.at(opening['end']).utc.to_s,
          timezone:  @timezone,
          truck:     row['name'])
        .select{|k,v| k.is_a? Symbol }
      end
    end.flatten
  end
end

class CityOfBoston < HTMLSource
  def response
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
      datetime = date.in_time_zone @timezone

      case tod_node.text
      when 'Breakfast'
        start = (datetime + 5.hours ).utc
        stop  = (datetime + 11.hours).utc
      when 'Lunch'
        start = (datetime + 11.hours).utc
        stop  = (datetime + 16.hours).utc
      when 'Dinner'
        start = (datetime + 16.hours).utc
        stop  = (datetime + 20.hours).utc
      when 'Late Night'
        start = (datetime + 20.hours).utc
        stop  = (datetime + 25.hours).utc
      end

      { id:        nil,
        type:      self.class.to_s,
        city:      @city,
        endpoint:  @endpoint.to_s,
        latitude:  nil,
        longitude: nil,
        place:     place,
        site:      site,
        start:     start.to_s,
        stop:      stop.to_s,
        timezone:  @timezone,
        truck:     truck } unless stop <= Time.now.utc
    end
  end
end
