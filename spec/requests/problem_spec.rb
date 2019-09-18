require 'rails_helper'

RSpec.describe ProblemController, type: :request do
  describe 'GET /problem' do
    subject { get problem_index_path }
    before { subject }

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct content' do
      expect(unescaped_response_body).to match(I18n.t('problem.index.title'))
      expect(unescaped_response_body).to match(I18n.t('problem.index.try_later'))
      expect(unescaped_response_body).to match(I18n.t('problem.index.answers_saved'))
    end
  end
end
