class LinkedApplicationType
  LinkTypeStruct = Struct.new(:code, :description)

  LINK_TYPES = [
    { code: "FAMILY", description: "Family" },
    { code: "LEGAL", description: "Legal" },
  ].freeze

  def self.all
    LINK_TYPES.map { |link_type_hash| LinkTypeStruct.new(code: link_type_hash[:code], description: link_type_hash[:description]) }
  end
end
