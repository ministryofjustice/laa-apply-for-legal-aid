module AccessibilityTestHelpers
  def accessibility_report
    @accessibility_report ||= []
  end

  def check_page_accessibility
    data = page.execute_script('var results = axs.Audit.run();return axs.Audit.createReport(results);')
    accessibility_report << { page: page.current_url, data: data }
  end

  def print_accessibility_report
    puts '== ACCESSIBILITY REPORT =='
    accessibility_report.each do |report|
      puts '*' * 30
      puts "PAGE: #{report[:page]}"
      print report[:data]
      print "\n"
    end
  end
end
