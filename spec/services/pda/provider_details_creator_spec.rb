require "rails_helper"

RSpec.describe PDA::ProviderDetailsCreator do
  let(:firm_struct) { Struct.new(:id, :name) }
  let(:office_struct) { Struct.new(:id, :code) }
  let(:provider_details_struct) { Struct.new(:firm_id, :contact_id, :firm_name, :firm_offices) }

  describe ".call" do
    context "when the firm does not exist" do
      before do
        stub_provider_offices
        stub_provider_firm_offices
      end

      it "creates the firm" do
        provider = create(:provider, username: "test-user")

        described_class.call(provider)

        expect(provider.firm).to have_attributes(
          ccms_id: "99999",
          name: "Test firm",
        )
      end

      it "creates the offices" do
        provider = create(:provider, username: "test-user")

        described_class.call(provider)

        offices = provider.firm.offices
        expect(offices).to contain_exactly(
          have_attributes(
            class: Office,
            ccms_id: "111111",
            code: "1A111B",
          ),
          have_attributes(
            class: Office,
            ccms_id: "222222",
            code: "2A222B",
          ),
        )
      end

      it "updates the provider" do
        provider = create(:provider, name: nil, username: "test-user")

        described_class.call(provider)

        expect(provider).to have_attributes(
          name: "",
          contact_id: 494_000,
        )
      end
    end

    context "when the provider's selected office is not returned from the API" do
      before do
        stub_provider_offices
        stub_provider_firm_offices
      end

      it "clears the selected office" do
        office = create(:office, code: "6D456C")
        provider = create(:provider, username: "test-user", selected_office: office)

        described_class.call(provider)

        expect(provider.selected_office).to be_nil
      end
    end

    context "when the provider's selected office is returned from the API" do
      before do
        stub_provider_offices
        stub_provider_firm_offices
      end

      it "does not clear the selected office" do
        office = create(:office, ccms_id: "111111", code: "1A111B")
        provider = create(:provider, username: "test-user", selected_office: office)

        described_class.call(provider)

        expect(provider.selected_office).to eq(office)
      end
    end

    context "when the firm already exists with one of the offices" do
      before do
        stub_provider_offices
        stub_provider_firm_offices
      end

      it "does not create the firm" do
        existing_firm = create(:firm, ccms_id: "99999", name: "Test firm")

        provider = create(:provider, username: "test-user")

        expect { described_class.call(provider) }.not_to change(Firm, :count)
        expect(provider.firm).to eq(existing_firm)
      end

      it "updates the firms offices" do
        existing_firm = create(:firm, ccms_id: "99999", name: "Test firm")

        _existing_office = create(
          :office,
          firm: existing_firm,
          ccms_id: "777777",
          code: "5A555B",
        )

        provider = create(:provider, username: "test-user")

        expect { described_class.call(provider) }.to change(Office, :count).by(2)

        expect(existing_firm.offices).to contain_exactly(
          have_attributes(class: Office, ccms_id: "777777", code: "5A555B"),
          have_attributes(class: Office, ccms_id: "111111", code: "1A111B"),
          have_attributes(class: Office, ccms_id: "222222", code: "2A222B"),
        )
      end

      it "updates the firm's name" do
        existing_firm = create(:firm, ccms_id: "99999", name: "Old firm name")
        provider = create(:provider, username: "test-user")

        expect { described_class.call(provider) }
          .to change { existing_firm.reload.name }
            .from("Old firm name")
            .to("Test firm")
      end
    end

    context "when another provider has the same firm, but different offices" do
      before do
        stub_provider_offices
        stub_other_provider_offices
        stub_provider_firm_offices
      end

      it "associates all the firm's offices with each provider" do
        provider = create(:provider, username: "test-user")
        other_provider = create(:provider, username: "other-user")

        described_class.call(provider)
        described_class.call(other_provider)

        expect(provider.offices).to contain_exactly(
          have_attributes(class: Office, ccms_id: "111111", code: "1A111B"),
          have_attributes(class: Office, ccms_id: "222222", code: "2A222B"),
        )

        expect(other_provider.offices).to contain_exactly(
          have_attributes(class: Office, ccms_id: "111111", code: "1A111B"),
          have_attributes(class: Office, ccms_id: "222222", code: "2A222B"),
        )
      end
    end
  end

  ###################
  # provider offices
  ###################
  def stub_provider_offices
    stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-user/test-user/provider-offices})
      .to_return(
        status: 200,
        body: provider_offices_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  def provider_offices_json
    {
      firm: {
        ccmsFirmId: 99_999,
        firmId: 1639,
        firmName: "Test firm",
        firmNumber: "1639",
      },
      officeCodes: [
        {
          ccmsFirmOfficeId: 111_111,
          firmOfficeCode: "1A111B",
        },
      ],
      user: {
        ccmsContactId: 494_000,
      },
    }.to_json
  end

  def stub_other_provider_offices
    stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-user/other-user/provider-offices})
      .to_return(
        status: 200,
        body: other_provider_offices_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )
  end

  def other_provider_offices_json
    {
      firm: {
        ccmsFirmId: 99_999,
        firmId: 1639,
        firmName: "Test firm",
        firmNumber: "1639",
      },
      officeCodes: [
        {
          ccmsFirmOfficeId: 222_222,
          firmOfficeCode: "2A222B",
        },
      ],
      user: {
        ccmsContactId: 494_000,
      },
    }.to_json
  end

  #################
  # firm offices
  #################
  def stub_provider_firm_offices
    stub_request(:get, %r{#{Rails.configuration.x.pda.url}/provider-firms/1639/provider-offices})
    .to_return(
      status: 200,
      body: provider_firm_offices_json,
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    )
  end

  def provider_firm_offices_json
    {
      firm: {
        ccmsFirmId: 99_999,
        firmId: 1639,
        firmName: "Test firm",
        firmNumber: "1639",
      },
      offices: [
        {
          ccmsFirmOfficeId: 111_111,
          firmOfficeCode: "1A111B",
        },
        {
          ccmsFirmOfficeId: 222_222,
          firmOfficeCode: "2A222B",
        },
      ],
    }.to_json
  end
end
