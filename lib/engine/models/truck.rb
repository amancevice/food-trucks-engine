class Truck < ActiveRecord::Base
  has_many :patterns, class_name:'TruckPattern'
  validates :name, :city, presence: true
  validates :name, uniqueness: {scope: :city}
  after_validation :default_patterns
  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :match, -> args {
    truck   = Truck.where(city:args[:city]).like(args[:name]).first
    truck ||= Truck.create city:args[:city], name:args[:name], source:args[:source]
  }

  def =~ name
    patterns.map{|x| x.exp =~ name }.compact.min
  end

  def default_patterns
    [patterns.new(value:"(?i-mx:#{name})")]
  end

  def to_h
    { truck:name, site:site, source:source }
  end
end
