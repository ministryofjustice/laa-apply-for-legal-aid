module V1
  class AddressesController < ApiController
    def create
      applicant = Applicant.find(params[:applicant_id])
      address = applicant.addresses.build(address_params)

      if address.save
        render json: address, status: :created
      else
        render_400 address.errors
      end
    end

    private

    def address_params
      params.require(:address).permit(:address_line_one, :address_line_two, :city, :county, :postcode)
    end
  end
end
