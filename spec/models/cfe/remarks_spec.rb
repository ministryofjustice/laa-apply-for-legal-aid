require "rails_helper"

module CFE
  RSpec.describe Remarks do
    let(:remarks) { described_class.new(remarks_hash) }

    describe "#caseworker_review_required?" do
      context "with no remarks" do
        let(:remarks_hash) { empty_hash }

        it "returns false" do
          expect(remarks.caseworker_review_required?).to be false
        end
      end

      context "when remarks exist" do
        let(:remarks_hash) { populated_hash }

        it "returns false" do
          expect(remarks.caseworker_review_required?).to be true
        end
      end
    end

    describe "#review_reasons" do
      context "with no remarks" do
        let(:remarks_hash) { empty_hash }

        it "returns empty array" do
          expect(remarks.review_reasons).to eq []
        end
      end

      context "with remarks" do
        let(:remarks_hash) { populated_hash }

        it "returns an array of reasons" do
          expect(remarks.review_reasons).to eq %i[amount_variation policy_disregards unknown_frequency]
        end
      end
    end

    describe "#review_categories_by_reason" do
      context "with no remarks" do
        let(:remarks_hash) { empty_hash }

        it "returns empty hash" do
          expect(remarks.review_categories_by_reason).to eq({})
        end
      end

      context "with remarks" do
        let(:remarks_hash) { populated_hash }

        it "returns an hash of categories by reason" do
          expected_results = {
            amount_variation: [:state_benefit_payment],
            unknown_frequency: %i[state_benefit_payment outgoings_housing_cost],
            policy_disregards: %i[england_infected_blood_support],
          }
          expect(remarks.review_categories_by_reason).to eq expected_results
        end
      end

      context "with remarks that do not require a category" do
        before { populated_hash[:current_account_balance] = { residual_balance: [] } }

        let(:remarks_hash) { populated_hash }

        it "does not include the remarks in the hash of categories by reason" do
          expected_results = {
            amount_variation: [:state_benefit_payment],
            unknown_frequency: %i[state_benefit_payment outgoings_housing_cost],
            policy_disregards: %i[england_infected_blood_support],
          }
          expect(remarks.review_categories_by_reason).to eq expected_results
        end
      end
    end

    describe "#review_transactions" do
      context "with no remarks" do
        let(:remarks_hash) { empty_hash }
        let(:collection) { remarks.review_transactions }

        it "returns an an instance of RemarkedTransactionCollection" do
          expect(collection).to be_instance_of(RemarkedTransactionCollection)
        end

        it "returns an empty collection" do
          expect(collection.transactions).to be_empty
        end
      end

      context "with remarks" do
        let(:remarks_hash) { populated_hash }
        let(:collection) { remarks.review_transactions }

        it "returns an an instance of RemarkedTransactionCollection" do
          expect(collection).to be_instance_of(RemarkedTransactionCollection)
        end

        it "returns an collection with the expected transaction_ids" do
          expected_transaction_ids = %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
            5d58c3b1-c34d-4f20-90fc-c22642410cfa
            05bcd12c-6790-49bc-a1aa-490fba8d2624
          ]
          expect(collection.transactions.keys).to match_array expected_transaction_ids
        end

        it "returns a collection with the expected values for a transactIon" do
          tx = collection.transactions["d55743b5-c1c4-4c9a-98a3-bad709aac422"]
          expect(tx).to be_instance_of(RemarkedTransaction)
          expect(tx.category).to eq :state_benefit_payment
          expect(tx.reasons).to eq %i[amount_variation unknown_frequency]

          tx = collection.transactions["05bcd12c-6790-49bc-a1aa-490fba8d2624"]
          expect(tx).to be_instance_of(RemarkedTransaction)
          expect(tx.category).to eq :outgoings_housing_cost
          expect(tx.reasons).to eq [:unknown_frequency]
        end
      end

      context "with remarks in the new client/partner style" do
        let(:remarks_hash) { populated_hash_specific }
        let(:collection) { remarks.review_transactions }

        it "returns an an instance of RemarkedTransactionCollection" do
          expect(collection).to be_instance_of(RemarkedTransactionCollection)
        end

        it "returns an collection with the expected transaction_ids" do
          expected_transaction_ids = %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
            17f4bc9f-574f-4f53-a371-16db2a0197f8
            28dc9ead-f8d3-498d-80f7-12087407ba22
            2130cf51-5257-4818-b2be-c4629fac0803
            9c7abff4-b6a9-4403-8a08-44e785724b07
          ]
          expect(collection.transactions.keys).to match_array expected_transaction_ids
        end

        it "returns a collection with the expected values for a transactIon" do
          tx = collection.transactions["d55743b5-c1c4-4c9a-98a3-bad709aac422"]
          expect(tx).to be_instance_of(RemarkedTransaction)
          expect(tx.category).to eq :partner_state_benefit_payment
          expect(tx.reasons).to eq %i[amount_variation unknown_frequency]

          tx = collection.transactions["28dc9ead-f8d3-498d-80f7-12087407ba22"]
          expect(tx).to be_instance_of(RemarkedTransaction)
          expect(tx.category).to eq :client_employment
          expect(tx.reasons).to eq [:multiple_employments]
        end
      end

      context "with duplicate reason and transaction for non-employment category remark" do
        let(:duplicate_remarks) do
          {
            some_other_category: {
              amount_variation: %w[
                d55743b5-c1c4-4c9a-98a3-bad709aac422
              ],
            },
          }
        end

        # NOTE: hash key order is significant due to `break` statement
        let(:remarks_hash) { duplicate_remarks.merge!(populated_hash) }

        it "raises \"Category mismatch\" error" do
          expect { remarks.review_transactions }.to raise_error(/category/i)
        end
      end

      context "with duplicate reason and transaction for employment category remark" do
        let(:employment_remarks) do
          {
            employment_tax: {
              refunds: %w[d55743b5-c1c4-4c9a-98a3-bad709aac422],
            },
            employment_nic: {
              refunds: %w[d55743b5-c1c4-4c9a-98a3-bad709aac422],
            },
          }
        end

        # NOTE: hash key order is significant due to `break` statement
        let(:remarks_hash) { employment_remarks.merge!(populated_hash) }

        it "does not raise \"Category mismatch\" error" do
          expect { remarks.review_transactions }.not_to raise_error
        end
      end

      context "with duplicate reason and transaction for client/partner employment category remark" do
        let(:employment_remarks) do
          {
            client_employment_tax: {
              refunds: %w[d55743b5-c1c4-4c9a-98a3-bad709aac422],
            },
            client_employment_nic: {
              refunds: %w[d55743b5-c1c4-4c9a-98a3-bad709aac422],
            },
          }
        end

        # NOTE: hash key order is significant due to `break` statement
        let(:remarks_hash) { employment_remarks.merge!(populated_hash) }

        it "does not raise \"Category mismatch\" error" do
          expect { remarks.review_transactions }.not_to raise_error
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
          ],
        },
        outgoings_housing_cost: {
          unknown_frequency: %w[
            5d58c3b1-c34d-4f20-90fc-c22642410cfa
            05bcd12c-6790-49bc-a1aa-490fba8d2624
          ],
        },
        policy_disregards: %w[
          england_infected_blood_support
        ],
      }
    end

    def populated_hash_specific
      {
        partner_state_benefit_payment: {
          amount_variation: %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
          ],
          unknown_frequency: %w[
            d55743b5-c1c4-4c9a-98a3-bad709aac422
            a277038a-86df-4bbd-8b87-d576ae150369
          ],
        },
        client_employment: {
          multiple_employments: %w[
            17f4bc9f-574f-4f53-a371-16db2a0197f8
            28dc9ead-f8d3-498d-80f7-12087407ba22
            2130cf51-5257-4818-b2be-c4629fac0803
            9c7abff4-b6a9-4403-8a08-44e785724b07
          ],
        },
        client_employment_tax: {
          refunds: %w[
            5094660c-afed-4a0f-b81f-78de6a390fa8
            0a0e4976-8605-44fe-b6c2-c3d72ef3e337
            abc472a7-04cf-4096-9f53-8fb022dc1812
            fea4f1fa-3f87-40d3-a43c-622ba4b80579
          ],
        },
        policy_disregards: %w[
          england_infected_blood_support
        ],
      }
    end
  end
end
