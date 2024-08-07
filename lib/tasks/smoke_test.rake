namespace :smoke_test do
  desc "Tries to generate a grover document"
  task pdf: :environment do
    Timeout.timeout(5) { Grover.new("test").to_pdf.size }
    Rails.logger.info "PDF generation succeeded"
  rescue Timeout::Error
    SlackAlerter.capture_message("PDF generation failed during deploy smoke test")
    raise StandardError, "PDF generation failed"
  end
end
