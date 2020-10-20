class AuthenticatedIpRanges
  def self.ranges
    cidr_hash = YAML.load_file(Rails.root.join('config', 'ipaddrs.yml'))
    cidr_array = cidr_hash.map { |_name, ranges| ranges }.flatten
    cidr_array.map { |cidr| IPAddr.new(cidr) }
  end
end
