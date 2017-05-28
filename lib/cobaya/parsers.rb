class Parsers
  def self.get(version)
    case version
    when :ruby18
      RubyParser::V18.new
    when :ruby19
      RubyParser::V19.new
    when :ruby20
      RubyParser::V20.new
    when :ruby21
      RubyParser::V21.new
    when :ruby22
      RubyParser::V22.new
    when :ruby23
      RubyParser::V23.new
    when :ruby24
      RubyParser::V24.new
    else
      raise "Not supported version"
    end
  end

  def self.default
    :ruby19
  end
end
