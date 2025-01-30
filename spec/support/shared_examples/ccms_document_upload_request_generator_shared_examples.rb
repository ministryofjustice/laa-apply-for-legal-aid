RSpec.shared_examples "a Document Upload Request XML generator" do
  include_context "with ccms soa configuration"

  it "generates the expected Document Upload Request XML" do
    allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)

    expect(requestor.formatted_xml)
      .to be_soap_envelope_with(
        command: "casebim:DocumentUploadRQ",
        transaction_id: expected_tx_id,
        matching: matching,
      )
  end
end
