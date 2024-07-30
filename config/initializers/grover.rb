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
    launch_args: ["--no-sandbox"],
    timeout: 30_000, # TODO: 30 JUl 2024 - this is _no_ timeout and should be increased to make it more realistic when we know it fixes the issue!
  }
end
