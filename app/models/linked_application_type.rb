class LinkedApplicationType
  LinkTypeStruct = Struct.new(:code, :description)

  LINK_TYPES = [
    LinkTypeStruct.new(code: "FAMILY", description: "Family"),
    LinkTypeStruct.new(code: "LEGAL", description: "Legal"),
  ].freeze

  def self.all
    LINK_TYPES
  end
end
