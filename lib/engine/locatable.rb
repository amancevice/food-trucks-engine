module Locatable
  def nearby? lat, lon, max:0.05
    unless lat.nil? || lon.nil? || latitude.nil? || longitude.nil?
      r    = 6371.0
      dlat = radians lat - latitude
      dlon = radians lon - longitude
      a    = Math::sin(dlat/2.0) ** 2 +
             Math::cos(radians latitude) *
             Math::cos(radians lat) *
             Math::sin(dlon/2.0) ** 2
      c    = 2.0 * Math::atan2(Math::sqrt(a), Math::sqrt(1.0 - a))

      r * c <= max
    end
  end

  private

  def radians degrees
    degrees * Math::PI/180.0
  end
end
