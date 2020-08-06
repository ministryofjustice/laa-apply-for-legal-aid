class Opponent < ApplicationRecord # rubocop:disable Metrics/ClassLength
  CASE_RELATIONSHIP_REGEX = /^relationship_case_(\S+)\?$/.freeze # begins with 'relationship_case_' and ends with a question mark
  CLIENT_RELATIONSHIP_REGEX = /^relationship_client_(\S+)\?$/.freeze # begins with "relationship_client_' and ends with a question mark

  CLIENT_RELATIONSHIP_VALUES = {
    civil_partner: 'Civil partner',
    customer: 'Customer',
    employee: 'Employee',
    employer: 'Employer',
    ex_civil_partner: 'Ex civil partner',
    ex_husband_wife: 'Ex_spouse',
    grandparent: 'Grandparent',
    husband_wife: 'Husband / wife',
    landlord: 'Landlord',
    legal_guardian: 'Legal guardian',
    local_authority: 'Local authority',
    medical_professional: 'Medial professional',
    none: 'None',
    other_family_member: 'Other family members',
    other_party_type: 'Other party type',
    parent: 'Parent',
    property_owner: 'Property owner',
    solicitor_barrister: 'Solicitor / barrister',
    step_parent: 'Step parent',
    supplier: 'Supplier',
    tenant: 'Tenant'
  }.freeze

  CASE_RELATIONSHIP_VALUES = {
    agent: 'Agent',
    child: 'Child',
    intervenor: 'Intevenor',
    opponent: 'Opp',
    guardian: 'Guardian',
    beneficiary: 'Beneficiary',
    interested_party: 'Interested party'
  }.freeze

  def self.dummy_opponent
    Opponent.find_or_create_by!(other_party_id: 'OPPONENT_00000001') do |opponent|
      opponent.title = 'MR.'
      opponent.first_name = 'Dummy'
      opponent.surname = 'Opponent'
      opponent.date_of_birth = Date.new(2015, 1, 1)
      opponent.relationship_to_case = 'OPP'
      opponent.relationship_to_client = 'EX_SPOUSE'
      opponent.opponent_type = 'PERSON'
      opponent.opp_relationship_to_case = 'Opponent'
      opponent.opp_relationship_to_client = 'Ex Husband/ Wife'
      opponent.child = false
    end
  end

  def shared_ind
    false # TODO: CCMS placeholder
  end

  def assessed_income
    0 # TODO: CCMS placeholder
  end

  def assessed_assets
    0 # TODO: CCMS placeholder
  end

  def full_name
    "#{title.capitalize} #{first_name} #{surname}"
  end

  def person?
    opponent_type.capitalize == 'Person'.freeze
  end

  def organisation?
    opponent_type.capitalize == 'Organisation'.freeze
  end

  def other_party_relationship_to_client
    relationship_to_client.capitalize
  end

  def other_party_relationship_to_case
    relationship_to_case.capitalize
  end

  def method_missing(method, *args)
    if valid_relationship_to_case_method?(method)
      case_relationship?(method)
    elsif valid_relationship_to_client_method?(method)
      client_relationship?(method)
    else
      super
    end
  end

  def respond_to_missing?(meth, include_private = false) # rubocop:disable Style/OptionalBooleanParameter
    return true if valid_relationship_to_case_method?(meth) || valid_relationship_to_client_method?(meth)

    super
  end

  private

  def valid_relationship_to_case_method?(meth)
    CASE_RELATIONSHIP_REGEX.match(meth.to_s) && CASE_RELATIONSHIP_VALUES.key?(Regexp.last_match(1).to_sym)
  end

  def valid_relationship_to_client_method?(meth)
    CLIENT_RELATIONSHIP_REGEX.match(meth.to_s) && CLIENT_RELATIONSHIP_VALUES.key?(Regexp.last_match(1).to_sym)
  end

  def client_relationship?(meth)
    CLIENT_RELATIONSHIP_REGEX.match meth.to_s
    key = Regexp.last_match(1).to_sym
    relationship_to_client.capitalize == CLIENT_RELATIONSHIP_VALUES[key]
  end

  def case_relationship?(meth)
    CASE_RELATIONSHIP_REGEX.match meth.to_s
    key = Regexp.last_match(1).to_sym
    relationship_to_case.capitalize == CASE_RELATIONSHIP_VALUES[key]
  end
end
