class Parsers
  def self.get(version)
    case version
    when :ruby18
      raise "Not supported version"
    when :ruby19
      Parser::Ruby19
    when :ruby20
      raise "Not supported version"
    when :ruby21
      raise "Not supported version"
    when :ruby22
      raise "Not supported version"
    when :ruby23
      raise "Not supported version"
    when :ruby24
      raise "Not supported version"
    else
      raise "Not supported version"
    end
  end

  def self.default
    :ruby19
  end
end
