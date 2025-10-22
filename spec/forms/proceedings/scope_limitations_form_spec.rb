require "rails_helper"

RSpec.describe Proceedings::ScopeLimitationsForm, :vcr, type: :form do
  subject(:form) { described_class.call(scopes) }

  let(:scopes) do
    [{ "code" => "FM007", "meaning" => "Blood Tests or DNA Tests", "description" => "Limited to all steps up to and including the obtaining of blood tests or DNA tests and thereafter a solicitor's report.", "additional_params" => [] },
     { "code" => "FM004", "meaning" => "CAFCASS report", "description" => "Limited to all steps up to and including the Children and Family Reporter's Report and thereafter a solicitor's report.", "additional_params" => [] },
     { "code" => "CV079",
       "meaning" => "Counsel's Opinion",
       "description" => "Limited to obtaining external Counsel's Opinion or the opinion of an external solicitor with higher court advocacy rights on the information already available.",
       "additional_params" => [{ "name" => "hearing_date", "type" => "date", "mandatory" => true }] },
     { "code" => "FM019",
       "meaning" => "Exchange of Evidence",
       "description" =>
       "Limited to all steps up to and including the exchange of evidence (including any welfare officer's/guardian ad litem's report) and directions appointments but not including a final contested hearing and thereafter to a solicitors report (or if so advised a Counsel's opinion) on the issues and prospects of success.",
       "additional_params" => [] },
     { "code" => "CV118",
       "meaning" => "Hearing",
       "description" => "Limited to all steps up to and including the hearing on [see additional limitation notes]",
       "additional_params" => [{ "n(:same" => "hearing_date", "type" => "date", "mandatory" => true }] },
     { "code" => "CV027",
       "meaning" => "Hearing/Adjournment",
       "description" => "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
       "additional_params" => [{ "name" => "hearing_date", "type" => "date", "mandatory" => true }] },
     { "code" => "CV117",
       "meaning" => "Interim order inc. return date",
       "description" => "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.",
       "additional_params" => [] },
     { "code" => "FM015", "meaning" => "Section 37 Report", "description" => "Limited to a section 37 report only.", "additional_params" => [] }]
  end

  let(:proceeding) { create(:proceeding, :se013, :without_df_date, :with_cit_z, no_scope_limitations: true) }
  let(:scope_type) { "substantive" }
  let(:scope_codes) { ["", "CV027"] }
  let(:hearing_date_cv027) { "4/10/2022" }
  let(:meaning_cv027) { "Hearing/Adjournment" }
  let(:description_cv027) { "Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date." }
  let(:limitation_note_cv027) { "" }

  let(:params) do
    {
      scope_codes:,
      scope_type:,
      meaning_CV027: meaning_cv027,
      description_CV027: description_cv027,
      hearing_date_CV027: hearing_date_cv027,
    }
  end

  let(:form_params) { params.merge(model: proceeding) }

  describe "#save" do
    subject(:save_form) { form.save(form_params) }

    before do
      save_form
      proceeding.reload
    end

    context "with one selected scope limitation" do
      context "when the scope limitation selected is valid" do
        it "is valid" do
          expect(form).to be_valid
        end

        it "updates the scope limitations" do
          expect(proceeding.scope_limitations.where(scope_type: "substantive").map(&:code)).to match_array(%w[CV027])
        end

        it "populates the hearing_date" do
          expect(proceeding.scope_limitations.where(code: "CV027").pluck(:hearing_date)).to eq [Date.parse("2022-10-04")]
        end
      end

      context "when a mandatory hearing date is blank" do
        let(:hearing_date_cv027) { "" }

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:hearing_date_CV027]).to include("Enter a valid hearing date for Hearing/Adjournment in the correct format")
        end

        it "does not update the scope limitations" do
          expect(proceeding.scope_limitations.where(scope_type: "substantive").map(&:code)).to be_empty
        end
      end

      context "when a mandatory hearing date is using a 2 digit year" do
        let(:hearing_date_cv027) { "#{Time.zone.tomorrow.day}/#{Time.zone.tomorrow.month}/#{Time.zone.tomorrow.strftime('%y').to_i}" }

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:hearing_date_CV027]).to include("Enter a valid hearing date for Hearing/Adjournment in the correct format")
        end
      end

      context "when a mandatory hearing date is using an invalid month" do
        let(:hearing_date_cv027) { "1/13/#{Time.zone.tomorrow.year}" }

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:hearing_date_CV027]).to include("Enter a valid hearing date for Hearing/Adjournment in the correct format")
        end
      end

      context "when a mandatory hearing date is using an invalid day" do
        let(:hearing_date_cv027) { "32/#{Time.zone.tomorrow.month}/#{Time.zone.tomorrow.year}" }

        it "is invalid with expected error" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:hearing_date_CV027]).to include("Enter a valid hearing date for Hearing/Adjournment in the correct format")
        end
      end

      context "with a mandatory limitation note" do
        let(:scopes) do
          [{ "code" => "CV027",
             "meaning" => "Hearing/Adjournment",
             "description" => "Limited to all steps (including any adjournment thereof) up to and including the hearing on",
             "additional_params" => [{ "name" => "limitation_note", "type" => "text", "mandatory" => true }] }]
        end

        let(:params) do
          {
            scope_codes:,
            scope_type:,
            meaning_CV027: meaning_cv027,
            description_CV027: description_cv027,
            limitation_note_CV027: limitation_note_cv027,
          }
        end

        context "when the limitation note is blank" do
          it "is invalid" do
            expect(form).not_to be_valid
          end

          it "does not update the scope limitations" do
            expect(proceeding.scope_limitations.where(scope_type: "substantive").map(&:code)).to be_empty
          end

          it "generates the expected error message" do
            expect(form.errors.map(&:attribute)).to eq [:limitation_note_CV027]
          end
        end

        context "when the limitation note is populated" do
          let(:limitation_note_cv027) { "a limitation note" }

          it "is valid" do
            expect(form).to be_valid
          end

          it "updates the scope limitations" do
            expect(proceeding.scope_limitations.where(scope_type: "substantive").map(&:code)).to match_array(%w[CV027])
          end

          it "populates the limitation note" do
            expect(proceeding.scope_limitations.where(code: "CV027").pluck(:limitation_note)).to eq ["a limitation note"]
          end
        end
      end
    end

    context "when no scope limitation is selected" do
      let(:scope_codes) { [""] }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "does not update the scope limitations" do
        expect(proceeding.scope_limitations.where(scope_type: "substantive").map(&:code)).to be_empty
      end

      it "generates the expected error message" do
        expect(form.errors.map(&:attribute)).to eq [:scope_codes]
      end
    end

    context "when multiple scope limitation are selected" do
      let(:scope_codes) { ["", "CV027", "FM015"] }
      let(:meaning_fm015) { "Section 37 Report" }
      let(:description_fm015) { "Limited to a section 37 report only." }

      let(:params) do
        {
          scope_codes:,
          scope_type:,
          meaning_CV027: meaning_cv027,
          description_CV027: description_cv027,
          hearing_date_CV027: hearing_date_cv027,
          meaning_FM015: meaning_fm015,
          description_FM015: description_fm015,
        }
      end

      it "is valid" do
        expect(form).to be_valid
      end

      it "updates the scope limitations" do
        expect(proceeding.scope_limitations.where(scope_type: "substantive").map(&:code)).to match_array(%w[CV027 FM015])
      end
    end
  end
end
