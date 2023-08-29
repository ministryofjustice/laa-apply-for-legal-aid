require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe InvolvedChildForm do
      subject(:described_form) { described_class.new(params) }

      let(:earliest_date) { Date.new(2000, 1, 1) }
      let(:dob) { Faker::Date.between(from: earliest_date, to: Date.current) }
      let(:full_name) { Faker::Name.name }
      let(:params) do
        {
          full_name:,
          date_of_birth_3i: dob.day.to_s,
          date_of_birth_2i: dob.month.to_s,
          date_of_birth_1i: dob.year.to_s,
        }
      end

      describe "#valid?" do
        context "when all fields are valid" do
          it "returns true" do
            expect(described_form).to be_valid
          end
        end

        context "when missing name" do
          let(:full_name) { "" }

          it "returns false" do
            expect(described_form).not_to be_valid
            expect(described_form.errors[:full_name]).to eq ["Enter the child's full name"]
          end
        end

        context "when missing date of birth" do
          let(:params) do
            {
              full_name:,
              date_of_birth_3i: "",
              date_of_birth_2i: "",
              date_of_birth_1i: "",
            }
          end

          it "returns false" do
            expect(described_form).not_to be_valid
            expect(described_form.errors[:date_of_birth]).to eq ["Enter the date of birth"]
          end
        end

        context "with invalid date of birth" do
          let(:params) do
            {
              full_name:,
              date_of_birth_3i: "32",
              date_of_birth_2i: "2",
              date_of_birth_1i: "2021",
            }
          end

          it "returns false" do
            expect(described_form).not_to be_valid
            expect(described_form.errors[:date_of_birth]).to eq ["Enter a valid date of birth"]
          end
        end
      end
    end
  end
end
