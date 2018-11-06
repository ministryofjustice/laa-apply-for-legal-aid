module Citizens
  class AccountsController < ApplicationController
    before_action :authenticate_applicant!

    def index
      @applicant = current_applicant
    end
  end
end
