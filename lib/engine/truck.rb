class Truck < ActiveRecord::Base
  include Like
  has_many :patterns, class_name:"TruckPattern"
  validates :name, :city, presence: true
  validates :name, uniqueness: {scope: :city}
  after_validation :default_patterns
  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :match, -> args {
    truck   = Truck.where(city:args[:city]).like(args[:name]).first
    truck ||= Truck.new city:args[:city], name:args[:name], source:args[:source]
  }

  def to_h
    { truck:name, site:site, source:source }.reject{|k,v| v.nil? }
  end
end
