class AuthorizedIpRanges
  @authorized_ranges = nil

  def initialize
    self.class.authorized_ranges ||= parse_ipaddrs_config
  end

  class << self
    attr_accessor :authorized_ranges
  end

  def authorized?(string_ipaddr)
    ipaddr = IPAddr.new(string_ipaddr)
    AuthorizedIpRanges.authorized_ranges.each do |ip_range|
      return true if ip_range.include?(ipaddr)
    end
    false
  end

  private

  def parse_ipaddrs_config
    cidr_hash = YAML.load_file(Rails.root.join('config/ipaddrs.crypt.yml'))
    cidr_array = cidr_hash.map { |_name, ranges| ranges }.flatten
    cidr_array.map { |cidr| IPAddr.new(cidr) }
  end
end
