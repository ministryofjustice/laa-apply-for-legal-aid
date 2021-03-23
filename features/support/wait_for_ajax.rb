module WaitForAjax
  def wait_for_ajax(wait: Capybara.default_max_wait_time)
    Timeout.timeout(wait) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('$.active').zero?
  end
end

World(WaitForAjax)
