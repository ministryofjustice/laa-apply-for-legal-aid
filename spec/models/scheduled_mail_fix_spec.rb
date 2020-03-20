require 'rails_helper'

Rails.application.load_tasks

RSpec.describe 'rake scheduled_mailer:bugfix' do
  let(:application) { create :application, :with_applicant }
  before do
    create_list :scheduled_mailing, 2, :missing_client_name, legal_aid_application: application
  end

  it 'adds the second parameter client_name' do
    Rake::Task['scheduled_mailer:bugfix'].invoke
    ScheduledMailing.all.each do |mailing|
      expect(mailing.arguments[1]).to eq(application.applicant.full_name)
    end
  end
end
