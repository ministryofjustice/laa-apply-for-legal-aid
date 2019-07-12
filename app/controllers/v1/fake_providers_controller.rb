module V1
  class FakeProvidersController < ApiController
    def show
      render json: provider_details
    end

    private

    def provider_details
      {
        providerOffices: Array.new(number_of_offices) do |office_index|
          provider_office(office_index)
        end,
        contactId: username_number * 3,
        contactName: contact_name
      }
    end

    def provider_office(office_index)
      # unique office_id for each office
      office_id = username_number * 2 + office_index

      # unique office_number for each office
      office_number = "0A#{office_id}"

      {
        providerfirmId: firm_id,
        officeId: office_id,
        officeName: "#{firm_name}-#{office_number}",
        smsVendorNum: ((office_id + firm_id) * 4).to_s,
        smsVendorSite: office_number
      }
    end

    def number_of_offices
      (username_number & 3) + 1
    end

    def firm_id
      @firm_id ||= username_number
    end

    def firm_name
      @firm_name ||= "#{contact_name} & Co."
    end

    def contact_name
      @contact_name ||= params[:username].snakecase.titlecase
    end

    def username_number
      @username_number ||= params[:username].upcase.chars.map(&:ord).sum
    end
  end
end
