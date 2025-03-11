module Task
  class Applicants < Base
    # uri/path to the section start page/form
    delegate :path, to: :ApplicantsStep

    # IF NEEDED? the form that the start page uses?!
    def form
    end
  end
end
