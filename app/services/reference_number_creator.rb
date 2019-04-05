class ReferenceNumberCreator
  UNUSED_LETTERS = %w[G I O Q S Z].freeze

  def self.call
    new.call
  end

  def call
    unique_reference_number
  end

  private

  def unique_reference_number
    loop do
      reference_number = random_reference_number
      return reference_number unless LegalAidApplication.find_by(application_ref: reference_number)
    end
  end

  def random_reference_number
    regex.random_example
  end

  def regex
    /L(-[#{Regexp.quote(letters_to_use.join)}0-9]{3}){2}/
  end

  def letters_to_use
    ('A'..'Z').to_a - UNUSED_LETTERS
  end
end
