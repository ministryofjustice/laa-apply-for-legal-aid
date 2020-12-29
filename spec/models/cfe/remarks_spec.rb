require 'rails_helper'

module CFE
  RSpec.describe Remarks do
    let(:remarks) { Remarks.new(remarks_hash) }

    describe '#caseworker_review_required?' do
      context 'no remarks' do
        let(:remarks_hash) { empty_hash }
        it 'returns false' do
          expect(remarks.caseworker_review_required?).to be false
        end
      end

      context 'remarks exist' do
        let(:remarks_hash) { populated_hash }
        it 'returns false' do
          expect(remarks.caseworker_review_required?).to be true
        end
      end
    end

    describe '#review_reasons' do
      context 'no remarks' do
        let(:remarks_hash) { empty_hash }
        it 'returns empty array' do
          expect(remarks.review_reasons).to eq []
        end
      end

      context 'with remarks' do
        let(:remarks_hash) { populated_hash }
        it 'returns an array of reasons' do
          expect(remarks.review_reasons).to eq %i[amount_variation policy_disregards unknown_frequency]
        end
      end
    end

    describe '#review_categories_by_reason' do
      context 'no remarks' do
        let(:remarks_hash) { empty_hash }
        it 'returns empty hash' do
          expect(remarks.review_categories_by_reason).to eq({})
        end
      end

      context 'with remarks' do
        let(:remarks_hash) { populated_hash }
        it 'returns an hash of categories by reason' do
          expected_results = {
            amount_variation: [:state_benefit_payment],
            unknown_frequency: %i[state_benefit_payment outgoings_housing_cost],
            policy_disregards: %i[england_infected_blood_support]
          }
          expect(remarks.review_categories_by_reason).to eq expected_results
        end
      end

      context 'with remarks that do not require a category' do
        before { populated_hash[:current_account_balance] = { residual_balance: [] } }
        let(:remarks_hash) { populated_hash }
        it 'does not include the remarks in the hash of categories by reason' do
          expected_results = {
            amount_variation: [:state_benefit_payment],
            unknown_frequency: %i[state_benefit_payment outgoings_housing_cost],
            policy_disregards: %i[england_infected_blood_support]
          }
          expect(remarks.review_categories_by_reason).to eq expected_results
        end
      end
    end

    describe '#review_transactions' do
      context 'no remarks' do
        let(:remarks_hash) { empty_hash }
        let(:collection) { remarks.review_transactions }

        it 'returns an an instance of RemarkedTransactionCollection' do
          expect(collection).to be_instance_of(RemarkedTransactionCollection)
        end

        it 'returns an empty collection' do
          expect(collection.transactions).to be_empty
        end
      end

      context 'with remarks' do
        let(:remarks_hash) { populated_hash }
        let(:collection) { remarks.review_transactions }

        it 'returns an an instance of RemarkedTransactionCollection' do
          expect(collection).to be_instance_of(RemarkedTransactionCollection)
        end

        it 'returns an collection with the expected transaction_ids' do
          expected_transaction_ids = %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
            5d58c3b1-c34d-4f20-90fc-c22642410cfa
            05bcd12c-6790-49bc-a1aa-490fba8d2624
          ]
          expect(collection.transactions.keys).to match_array expected_transaction_ids
        end

        it 'returns a collection with the expected values for a transacton' do
          tx = collection.transactions['d55743b5-c1c4-4c9a-98a3-bad709aac422']
          expect(tx).to be_instance_of(RemarkedTransaction)
          expect(tx.category).to eq :state_benefit_payment
          expect(tx.reasons).to eq %i[amount_variation unknown_frequency]

          tx = collection.transactions['05bcd12c-6790-49bc-a1aa-490fba8d2624']
          expect(tx).to be_instance_of(RemarkedTransaction)
          expect(tx.category).to eq :outgoings_housing_cost
          expect(tx.reasons).to eq [:unknown_frequency]
        end
      end
    end

    def empty_hash
      {}
    end

    def populated_hash
      {
        state_benefit_payment: {
          amount_variation: %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
          ],
          unknown_frequency: %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
          ]
        },
        outgoings_housing_cost: {
          unknown_frequency: %w[
            5d58c3b1-c34d-4f20-90fc-c22642410cfa
            05bcd12c-6790-49bc-a1aa-490fba8d2624
          ]
        },
        policy_disregards: [
          'england_infected_blood_support'
        ]
      }
    end
  end
end
