module Like
  def =~ name
    exps.map{|x| name =~ x }.compact.min
  end

  def exps
    [Regexp.new("(?i-mx:#{Regexp.escape name})")] + patterns.collect(&:exp)
  end
end
