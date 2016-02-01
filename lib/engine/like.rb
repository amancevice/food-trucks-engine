module Like
  def =~ name
    patterns.map{|x| x =~ name }.compact.min
  end

  def default_patterns
    [ patterns.new(value:"(?i-mx:#{Regexp.escape name})") ]
  end
end
