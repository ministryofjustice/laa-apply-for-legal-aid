require "rails_helper"

FirmStruct = Struct.new(:id, :name)
OfficeStruct = Struct.new(:id, :code)
ProviderDetailsStruct = Struct.new(:firm_id, :contact_id, :firm_name, :offices)

RSpec.describe PDA::ProviderDetailsCreator do
  describe ".call" do
    context "when the firm does not exist" do
      it "creates the firm" do
        ccms_firm = FirmStruct.new(1, "Test Firm")
        ccms_office = OfficeStruct.new(1, "6D424Y")
        provider = create(:provider, username: "test-user")
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office],
        )

        described_class.call(provider)

        expect(provider.firm).to have_attributes(
          ccms_id: "1",
          name: "Test Firm",
        )
      end

      it "creates the offices" do
        ccms_firm = FirmStruct.new(1, "Test Firm")
        ccms_office1 = OfficeStruct.new(1, "6D424Y")
        ccms_office2 = OfficeStruct.new(2, "4C880Q")
        provider = create(:provider, username: "test-user")
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office1, ccms_office2],
        )

        described_class.call(provider)

        offices = provider.firm.offices
        expect(offices).to contain_exactly(
          have_attributes(
            class: Office,
            ccms_id: ccms_office1.id.to_s,
            code: ccms_office1.code,
          ),
          have_attributes(
            class: Office,
            ccms_id: ccms_office2.id.to_s,
            code: ccms_office2.code,
          ),
        )
      end

      it "updates the provider" do
        ccms_firm = FirmStruct.new(1, "Test Firm")
        ccms_office = OfficeStruct.new(1, "6D424Y")
        provider = create(:provider, name: nil, username: "test-user")
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office],
        )

        described_class.call(provider)

        expect(provider).to have_attributes(
          name: "",
          contact_id: 104,
        )
      end
    end

    context "when the provider's office is not returned from the API" do
      it "clears the selected office" do
        ccms_firm = FirmStruct.new(1, "Test Firm")
        ccms_office = OfficeStruct.new(1, "6D424Y")
        office = create(:office, code: "6D456C")
        provider = create(
          :provider,
          username: "test-user",
          selected_office: office,
        )
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office],
        )

        described_class.call(provider)

        expect(provider.selected_office).to be_nil
      end
    end

    context "when the provider's office is returned from the API" do
      it "does not clear the selected office" do
        ccms_firm = FirmStruct.new(1, "Test Firm")
        ccms_office = OfficeStruct.new(1, "6D456C")
        office = create(
          :office,
          ccms_id: ccms_office.id,
          code: ccms_office.code,
        )
        provider = create(
          :provider,
          username: "test-user",
          selected_office: office,
        )
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office],
        )

        described_class.call(provider)

        expect(provider.selected_office).to eq(office)
      end
    end

    context "when the firm already exists with one of the offices" do
      it "does not create the firm" do
        ccms_firm = FirmStruct.new(1, "Existing Firm")
        ccms_office = OfficeStruct.new(1, "6D456C")
        existing_firm = create(
          :firm,
          ccms_id: ccms_firm.id,
          name: "Existing Firm",
        )
        _existing_office = create(
          :office,
          firm: existing_firm,
          ccms_id: ccms_office.id,
          code: ccms_office.code,
        )
        provider = create(:provider, username: "test-user")
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office],
        )

        described_class.call(provider)

        expect(provider.firm).to eq(existing_firm)
      end

      it "updates the firms offices" do
        ccms_firm = FirmStruct.new(1, "Existing Firm")
        ccms_office1 = OfficeStruct.new(1, "6D456C")
        ccms_office2 = OfficeStruct.new(2, "4C880Q")
        existing_firm = create(
          :firm,
          ccms_id: ccms_firm.id,
          name: "Existing Firm",
        )
        existing_office = create(
          :office,
          firm: existing_firm,
          ccms_id: ccms_office1.id,
          code: ccms_office1.code,
        )
        provider = create(:provider, username: "test-user")
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office1, ccms_office2],
        )

        described_class.call(provider)

        expect(existing_firm.offices).to contain_exactly(
          existing_office,
          have_attributes(
            class: Office,
            ccms_id: ccms_office2.id.to_s,
            code: ccms_office2.code,
          ),
        )
      end

      it "updates the firm's name" do
        ccms_firm = FirmStruct.new(1, "New Firm Name")
        ccms_office = OfficeStruct.new(1, "6D456C")
        existing_firm = create(
          :firm,
          ccms_id: ccms_firm.id,
          name: "Old Firm Name",
        )
        _existing_office = create(
          :office,
          firm: existing_firm,
          ccms_id: ccms_office.id,
          code: ccms_office.code,
        )
        provider = create(:provider, username: "test-user")
        stub_provider_details_retriever(
          provider:,
          firm: ccms_firm,
          offices: [ccms_office],
        )

        described_class.call(provider)

        expect(existing_firm.reload.name).to eq("New Firm Name")
      end
    end

    context "when another provider has the same firm, but different offices" do
      it "only adds offices to the correct provider" do
        ccms_firm = FirmStruct.new(1, "New Firm Name")
        ccms_office1 = OfficeStruct.new(1, "6D456C")
        ccms_office2 = OfficeStruct.new(2, "4C880Q")
        ccms_office3 = OfficeStruct.new(3, "9R678Y")
        provider = create(:provider, username: "test-user")
        other_provider = create(:provider, username: "other-user")
        stub_provider_details_retriever(
          provider:,
          contact_id: 105,
          firm: ccms_firm,
          offices: [ccms_office1, ccms_office2],
        )
        stub_provider_details_retriever(
          provider: other_provider,
          contact_id: 106,
          firm: ccms_firm,
          offices: [ccms_office2, ccms_office3],
        )

        described_class.call(provider)
        described_class.call(other_provider)

        expect(provider.offices).to contain_exactly(
          have_attributes(
            class: Office,
            ccms_id: ccms_office1.id.to_s,
            code: ccms_office1.code,
          ),
          have_attributes(
            class: Office,
            ccms_id: ccms_office2.id.to_s,
            code: ccms_office2.code,
          ),
        )

        expect(other_provider.offices).to contain_exactly(
          have_attributes(
            class: Office,
            ccms_id: ccms_office2.id.to_s,
            code: ccms_office2.code,
          ),
          have_attributes(
            class: Office,
            ccms_id: ccms_office3.id.to_s,
            code: ccms_office3.code,
          ),
        )
      end
    end
  end

  def stub_provider_details_retriever(provider:, firm:, offices:, contact_id: 104)
    allow(PDA::ProviderDetailsRetriever)
      .to receive(:call)
      .with(provider.username)
      .and_return(api_response(firm:, offices:, contact_id:))
  end

  def api_response(firm:, offices:, contact_id:)
    ProviderDetailsStruct.new(firm_id: firm.id, contact_id:, firm_name: firm.name, offices:)
  end
end
