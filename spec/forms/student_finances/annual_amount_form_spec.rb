require "rails_helper"

RSpec.describe StudentFinances::AnnualAmountForm do
  let(:legal_aid_application) do
    create(:legal_aid_application, student_finance: nil)
  end

  let(:params) { attributes.merge(legal_aid_application:) }
  let(:attributes) { { student_finance:, amount: } }
  let(:student_finance) { "" }
  let(:amount) { "" }

  describe "#validate" do
    subject(:form) { described_class.new(params) }

    context "when student finance is true" do
      let(:student_finance) { "true" }

      context "when amount is blank" do
        let(:amount) { "" }

        it "is invalid" do
          expect(form).to be_invalid
          expect(form.errors).to be_added(:amount, :not_a_number, value: "")
        end
      end

      context "when amount is not a number" do
        let(:amount) { "not a number" }

        it "is invalid" do
          expect(form).to be_invalid
          expect(form.errors).to be_added(
            :amount,
            :not_a_number,
            value: "not a number",
          )
        end
      end

      context "when amount is less than 0" do
        let(:amount) { "-1" }

        it "is invalid" do
          expect(form).to be_invalid
          expect(form.errors).to be_added(
            :amount,
            :greater_than_or_equal_to,
            count: 0,
            value: -1,
          )
        end
      end

      context "when amount is greater than 0" do
        let(:amount) { "110" }

        it "is valid" do
          expect(form).to be_valid
        end
      end
    end

    context "when student finance is false" do
      let(:student_finance) { "false" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when student finance is blank" do
      let(:student_finance) { "" }

      it "is invalid" do
        expect(form).to be_invalid
        expect(form.errors).to be_added(:student_finance, :inclusion, value: "")
      end
    end
  end

  describe "#save" do
    subject(:save_form) { form.save }

    let(:form) { described_class.new(params) }
    let(:irregular_incomes) { legal_aid_application.irregular_incomes }

    context "when student finance is true" do
      let(:student_finance) { "true" }
      let(:amount) { "2000" }

      it "creates an irregular income" do
        save_form

        expect(irregular_incomes.first).to have_attributes(
          legal_aid_application:,
          income_type: "student_loan",
          frequency: "annual",
          amount: 2000,
        )
      end

      it "updates the legal aid application" do
        save_form

        expect(legal_aid_application.student_finance).to be true
      end
    end

    context "when student finance is false" do
      let(:student_finance) { "false" }

      it "does not create an irregular income" do
        save_form

        expect(irregular_incomes).to be_empty
      end

      it "updates the legal aid application" do
        save_form

        expect(legal_aid_application.student_finance).to be false
      end

      context "when there is an existing irregular income" do
        before { create(:irregular_income, legal_aid_application:) }

        it "destroys the irregular income" do
          save_form

          expect(irregular_incomes).to be_empty
        end
      end
    end

    context "when student finance is blank" do
      let(:student_finance) { "" }

      it "does not create an irregular income" do
        save_form

        expect(irregular_incomes).to be_empty
      end

      it "does not update the legal aid application" do
        save_form

        expect(legal_aid_application.student_finance).to be_nil
      end
    end
  end
end
