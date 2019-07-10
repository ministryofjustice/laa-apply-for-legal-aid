class SaveApplicantMeansAnswers
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  attr_reader :legal_aid_application

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    legal_aid_application.update!(applicant_means_answers: applicant_means_answers)
  end

  private

  def applicant_means_answers
    legal_aid_application.as_json(
      except: :applicant_means_answers,
      include: %i[
        savings_amount
        other_assets_declaration
        vehicle
      ]
    ).merge(bank_transactions: bank_transactions)
  end

  def bank_transactions
    legal_aid_application
      .bank_transactions
      .where
      .not(transaction_type: nil)
      .as_json(include: :transaction_type)
  end
end
