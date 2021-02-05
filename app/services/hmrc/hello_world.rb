module HMRC
  class HelloWorld < OAuth
    def call
      response = super.get(hmrc_api_path)
      JSON.parse(response.body)
    end

    private

    def hmrc_api_path
      '/hello/application'
    end

    def accept
      'application/vnd.hmrc.1.0+json'
    end
  end
end
