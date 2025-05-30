Grover.configure do |config|
  config.options = {
    format: "A4",
    emulate_media: "print",
    prefer_css_page_size: true,
    print_background: true,
    bypass_csp: true,
    cache: false,
    wait_until: "networkidle2",
    display_url: Rails.configuration.x.application.host_url,
    style_tag_options: [content: Rails.root.join("app/assets/builds/application.css").read],
    margin: {
      top: "10mm",
      bottom: "10mm",
      left: "10mm",
      right: "20mm",
    },
    launch_args: %w[--no-sandbox --disable-gpu],
  }
end
