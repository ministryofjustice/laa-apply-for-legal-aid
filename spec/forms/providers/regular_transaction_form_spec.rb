require "rails_helper"

RSpec.describe Providers::RegularTransactionForm do
  describe "#transaction_type_conditions" do
    context "when the method is not implemented" do
      let(:conditions_not_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            "fake object"
          end

          def transaction_type_exclusions
            {}
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "raises an error" do
        params = { "transaction_type_ids" => ["", "none"] }

        expect { conditions_not_implemented_form.new(params) }
          .to raise_error(NotImplementedError)
      end
    end

    context "when the method is implemented" do
      let(:conditions_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            "fake object"
          end

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def transaction_type_exclusions
            {}
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "does not raise an error" do
        params = { "transaction_type_ids" => ["", "none"] }

        expect { conditions_implemented_form.new(params) }.not_to raise_error
      end
    end
  end

  describe "#transaction_type_exclusions" do
    context "when the method is not implemented" do
      let(:conditions_not_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            "fake object"
          end

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "raises an error" do
        params = { "transaction_type_ids" => ["", "none"] }

        expect { conditions_not_implemented_form.new(params) }
          .to raise_error(NotImplementedError)
      end
    end

    context "when the method is implemented" do
      let(:conditions_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            "fake object"
          end

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def transaction_type_exclusions
            {}
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "does not raise an error" do
        params = { "transaction_type_ids" => ["", "none"] }

        expect { conditions_implemented_form.new(params) }.not_to raise_error
      end
    end
  end

  describe "#legal_aid_application_attributes" do
    context "when the method is not implemented" do
      let(:attributes_not_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            "fake object"
          end

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def transaction_type_exclusions
            {}
          end
        end
      end

      it "raises an error" do
        legal_aid_application = create(:legal_aid_application)
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = attributes_not_implemented_form.new(params)

        expect { form.save }.to raise_error(NotImplementedError)
      end
    end

    context "when the method is implemented" do
      let(:attributes_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            legal_aid_application.applicant
          end

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def transaction_type_exclusions
            {}
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "does not raise an error" do
        legal_aid_application = create(:legal_aid_application)
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        form = attributes_implemented_form.new(params)

        expect { form.save }.not_to raise_error
      end
    end
  end

  describe "#owner" do
    context "when the method is not implemented" do
      let(:conditions_not_implemented_form) do
        Class.new(described_class) do
        private

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def transaction_type_exclusions
            {}
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "raises an error" do
        params = { "transaction_type_ids" => ["", "none"] }

        expect { conditions_not_implemented_form.new(params) }
          .to raise_error(NotImplementedError)
      end
    end

    context "when the method is implemented" do
      let(:conditions_implemented_form) do
        Class.new(described_class) do
        private

          def owner
            legal_aid_application.applicant
          end

          def transaction_type_conditions
            { operation: :credit, parent_id: nil }
          end

          def transaction_type_exclusions
            {}
          end

          def legal_aid_application_attributes
            {}
          end
        end
      end

      it "does not raise an error" do
        legal_aid_application = create(:legal_aid_application, :with_applicant)
        params = {
          "transaction_type_ids" => ["", "none"],
          legal_aid_application:,
        }
        expect { conditions_implemented_form.new(params) }.not_to raise_error
      end
    end
  end
end
