class LegalaidApplicatonController < ApplicationController
  def create
    render(json: { 'application_ref' => '1234' })
  end
end
