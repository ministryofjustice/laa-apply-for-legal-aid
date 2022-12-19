class ReferenceNumber
  PREFIX = "L".freeze
  DISALLOWED_CHARACTERS = %w[G I O Q S Z].freeze

  def self.generate
    new.generate
  end

  def generate
    unique_reference_number
  end

private

  def unique_reference_number
    loop do
      reference_number = random_reference_number
      return reference_number unless reference_number_taken?(reference_number)
    end
  end

  def random_reference_number
    random_characters = Array.new(6) { characters_to_use.sample }
    "#{PREFIX}-#{random_characters.insert(3, '-').join}"
  end

  def characters_to_use
    ("0".."9").to_a + ("A".."Z").to_a - DISALLOWED_CHARACTERS
  end

  def reference_number_taken?(reference_number)
    LegalAidApplication.find_by(application_ref: reference_number)
  end
end
