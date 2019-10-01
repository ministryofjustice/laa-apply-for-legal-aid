# use as follows:
#
# expect(history.request).to be_soap_envelope_with(
#                                      command: 'ns2:ReferenceDataInqRQ',
#                                      transaction_id: '20190301030405123456',
#                                      matching: ['<ns5:ContextKey>CaseReferenceNumber</ns5:ContextKey>', 'ns5:Key>CaseReferenceNumber</ns5:Key']
#                                    )
module SoapMatcher
  RSpec::Matchers.define :be_soap_envelope_with do |options|
    results = []
    match do |actual|
      results << 'String does not start with a soap Envelope declaration' unless /<soap:Envelope xmlns:(soap=|xsd=)/.match?(actual)

      if options[:command]
        results << "String does not contain the #{options[:command]} command immediately after the soap:Body element" unless /<soap:Body>\n\s*<#{options[:command]}>/.match?(actual)
      end

      if options[:transaction_id]
        unless %r{TransactionRequestID>#{options[:transaction_id]}</.+TransactionRequestID>}.match?(actual)
          results << "String does not contain an ns3:/ns6:TransactionRequestID with a value of #{options[:transaction_id]}"
        end
      end

      options[:matching]&.each do |string_to_match|
        results << "String '#{string_to_match}' not found" unless actual&.match?(Regexp.new(string_to_match))
      end
      results.empty?
    end

    failure_message do
      "#{results.join("\n")}\n\nThe string being checked was:\n\n#{actual}"
    end
  end
end
