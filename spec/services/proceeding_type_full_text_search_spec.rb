require 'rails_helper'

RSpec.describe ProceedingTypeFullTextSearch do
  context 'whole service' do
    before(:all) do
      ServiceLevel.create!(service_level_number: 3, name: 'Full representation')
      Setting.setting.update!(allow_multiple_proceedings: true)
      ProceedingType.populate
    end

    after(:all) do
      ServiceLevel.delete_all
      DefaultCostLimitation.delete_all
      ProceedingType.delete_all
      Setting.setting.update!(allow_multiple_proceedings: false)
    end

    let(:legal_aid_application) { create :legal_aid_application }
    let(:source_url) { Rails.application.routes.url_helpers.providers_legal_aid_application_proceedings_types_path(legal_aid_application) }

    describe '.call' do
      subject { described_class.call(search_term, source_url) }

      context 'searching for a non-existent term' do
        let(:search_term) { 'animals' }

        it 'returns an empty array' do
          expect(subject).to eq []
        end
      end

      context 'when application has no proceeding types already selected' do
        context 'searching for a term that only exists on one record' do
          let(:search_term) { 'mutilation' }

          it 'returns one result row' do
            result_set = subject
            expect(result_set.size).to eq 1
          end

          it 'returns an instance of Result' do
            result = subject.first
            expect(result).to be_an_instance_of(ProceedingTypeFullTextSearch::Result)
          end

          it 'returns FGM Protection order' do
            result = subject.first
            expect(result.meaning).to eq 'FGM Protection Order'
            expect(result.description).to eq 'To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act.'
          end
        end

        context 'search term only exists in additional_search_terms' do
          let(:search_term) { 'cao' }

          it 'returns two records' do
            result_set = subject
            expect(result_set.map(&:code).sort).to eq %w[PH0003 PH0004]
          end
        end

        context 'searching for a term which occures in more than one proceeding' do
          let(:search_term) { 'injunction' }

          it 'returns two results' do
            result_set = subject
            expect(result_set.size).to eq 3
          end

          it 'returns the one with the search term in meaning first' do
            result_set = subject
            expect(result_set.map(&:meaning)).to eq ['Harassment - injunction', 'Inherent jurisdiction high court injunction', 'Non-molestation order']
          end
        end

        context 'multiple term searches' do
          let(:search_term) { 'protection order' }

          it 'only returns results matching both terms' do
            result_set = subject
            expect(result_set.map(&:meaning)).to match_array(['FGM Protection Order',
                                                              'Forced marriage protection order',
                                                              'Variation or discharge under section 5 protection from harassment act 1997'])
          end
        end
      end

      context 'when application already has proceeding types selected' do
        before do
          # add Forced mariage protection order and Occupation order
          legal_aid_application.proceeding_types << ProceedingType.find_by(code: 'PR0203')
          legal_aid_application.proceeding_types << ProceedingType.find_by(code: 'PR0214')
        end

        context 'searching for a term not on an already-selected proceeding' do
          context 'searching for a term that only exists on one record' do
            let(:search_term) { 'mutilation' }

            it 'returns one result row' do
              result_set = subject
              expect(result_set.size).to eq 1
            end

            it 'returns an instance of Result' do
              result = subject.first
              expect(result).to be_an_instance_of(ProceedingTypeFullTextSearch::Result)
            end

            it 'returns FGM Protection order' do
              result = subject.first
              expect(result.meaning).to eq 'FGM Protection Order'
              expect(result.description).to eq 'To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act.'
            end
          end

          context 'searching for a term which occurs in more than one proceeding' do
            let(:search_term) { 'injunction' }

            it 'returns two results' do
              result_set = subject
              expect(result_set.size).to eq 3
            end

            it 'returns the one with the search term in meaning first' do
              result_set = subject
              expect(result_set.map(&:meaning)).to eq ['Harassment - injunction', 'Inherent jurisdiction high court injunction', 'Non-molestation order']
            end
          end

          context 'multiple term searches' do
            let(:search_term) { 'har inj' } # harassment injuction

            it 'only returns results matching both terms' do
              result_set = subject
              expect(result_set.map(&:meaning)).to match_array(['Non-molestation order', 'Harassment - injunction'])
            end

            it 'returns the item with the search terms in meaning first' do
              result_set = subject
              expect(result_set.first.meaning).to eq 'Harassment - injunction'
            end
          end
        end

        context 'searching for a term on a proceeding type that has already been selected' do
          let(:search_term) { 'order' }

          it 'does not include either of the proceeding types already on the application' do
            meanings = subject.map(&:meaning)
            expect(meanings).not_to include('Forced marriage protection order')
            expect(meanings).not_to include('Occupation order')
          end

          it 'does include all the other matching proceeding types' do
            meanings = subject.map(&:meaning)
            expect(meanings).to match_array(['Non-molestation order',
                                             'FGM Protection Order',
                                             'Variation or discharge under section 5 protection from harassment act 1997',
                                             'Inherent jurisdiction high court injunction',
                                             'Extend, variation or discharge - Part IV',
                                             'Child arrangements order (contact)',
                                             'Child arrangements order (residence)',
                                             'Prohibited steps order',
                                             'Specific issue order'])
          end
        end
      end
    end
  end

  describe 'transformation of search terms' do
    let(:dummy_url) { nil }
    let(:service) { described_class.new(search_terms, dummy_url) }

    subject { service.instance_variable_get(:@ts_query) }

    context 'one single search term' do
      let(:search_terms) { 'term1' }
      it 'returns term followed by :*' do
        expect(subject).to eq 'term1:*'
      end
    end

    context 'terms separated by a single space' do
      let(:search_terms) { 'term1 term2' }
      it 'returns :* after each item separated by &' do
        expect(subject).to eq 'term1:* & term2:*'
      end
    end

    context 'terms separated by a tab' do
      let(:search_terms) { "term1\tterm2" }
      it 'returns :* after each item separated by &' do
        expect(subject).to eq 'term1:* & term2:*'
      end
    end

    context 'terms separated by multiple spaces' do
      let(:search_terms) { 'term1   term2' }
      it 'returns :* after each item separated by &' do
        expect(subject).to eq 'term1:* & term2:*'
      end
    end

    context 'terms separated by mixture of multiple spaces and tabs' do
      let(:search_terms) { "term1\t\tterm2  term3\t term4  \tterm5" }
      it 'returns :* after each item separated by &' do
        expect(subject).to eq 'term1:* & term2:* & term3:* & term4:* & term5:*'
      end
    end
  end
end
