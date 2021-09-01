class SlackAlerter

  def capture_message(message)
    puts ">>>>>>>>>>>> #{message} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
  end

  def capture_exception(exception)
    puts ">>>>>>>>>>>> #{exception.class} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
    puts ">>>>>>>>>>>> #{exception.message} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
    puts exception.backtrace
  end
end
