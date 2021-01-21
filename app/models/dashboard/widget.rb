module Dashboard
  class Widget
    def initialize(widget_klass)
      @widget_klass = "Dashboard::WidgetDataProviders::#{widget_klass}".constantize
      log_start_message
      @client = Geckoboard.client(Rails.configuration.x.geckoboard.api_key)
      raise 'Unable to access Geckoboard' unless @client.ping
    end

    def run
      @dataset = @client.datasets.find_or_create(dataset_name, @widget_klass.dataset_definition)
      @dataset.put(data)
      log_data_message
    end

    def data
      @data ||= @widget_klass.data
    end

    private

    def dataset_name
      "apply_for_legal_aid.#{HostEnv.environment}.#{@widget_klass.handle}"
    end

    def log_start_message
      log_message("***** #{@widget_klass.name.split('::').last} starting job at #{Time.current} for dataset: #{dataset_name}")
    end

    def log_data_message
      log_message "***** #{@widget_klass.name.split('::').last} sending: #{data} job at #{Time.current} for dataset: #{dataset_name}"
    end

    def log_message(message)
      Rails.logger.info message unless Rails.env.test?
    end
  end
end
