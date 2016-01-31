module Meal
  BREAKFAST  = "Breakfast"
  LUNCH      = "Lunch"
  DINNER     = "Dinner"
  LATE_NIGHT = "Late Night"

  def self.between args
    start = Time.parse args[:start]
    stop  = Time.parse args[:stop]
    range = start.to_i..stop.to_i
    hours = range.step(1.hour).map{|x| Time.at(x).in_time_zone(args[:timezone]).hour }
    meals = []
    meals << BREAKFAST  if hours.map{|x|  (5...11).include? x }.include? true
    meals << LUNCH      if hours.map{|x| (11...16).include? x }.include? true
    meals << DINNER     if hours.map{|x| (16...20).include? x }.include? true
    meals << LATE_NIGHT if hours.map do |x|
      (20...24).include?(x)||(0...5).include?(x)
    end.include? true

    meals
  end
end
