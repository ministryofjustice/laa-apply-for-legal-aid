class StatementOfCasePdfConverterWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(statement_of_case_id)
    statement_of_case = StatementOfCase.find(statement_of_case_id)
    StatementOfCases::PdfConverter.call(statement_of_case)
  end
end
