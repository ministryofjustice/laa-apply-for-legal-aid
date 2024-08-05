Grover.configure do |config|
  protocol = if Rails.env.development?
               "http://"
             else
               "https://"
             end

  config.options = {
    format: "A4",
    emulate_media: "print",
    prefer_css_page_size: true,
    bypass_csp: true,
    cache: false,
    wait_until: "networkidle2",
    display_url: protocol + ENV.fetch("HOST", "localhost:3002"),
    margin: {
      top: "10mm",
      bottom: "10mm",
      left: "10mm",
      right: "20mm",
    },
    launch_args: %w[--no-sandbox --disable-gpu],
  }
end
