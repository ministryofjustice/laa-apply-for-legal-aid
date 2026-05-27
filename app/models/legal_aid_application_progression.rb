class LegalAidApplicationProgression < ApplicationRecord
  belongs_to :legal_aid_application

  DEFAULT_FORMS = {
    client_case_details: { # section
      client_details: { # task_list_item
        state: :in_progress,
        forms: {},
      },
      linked_application: {
        state: :cannot_start_yet,
        forms: {},
      },
      proceedings: {
        state: :cannot_start_yet,
        forms: {},
      },
      partner_details: {
        state: :cannot_start_yet,
        forms: {},
      },
      check_your_answers: {
        state: :cannot_start_yet,
        forms: {},
      },
      dwp_outcome: {
        state: :cannot_start_yet,
        forms: {},
      },
    },
    means: {
      state: :on_hold,
      forms: {},
    },
    capital: {
      state: :on_hold,
      forms: {},
    },
    merits: {
      state: :on_hold,
      forms: {},
    },
  }.freeze

  def initialize(legal_aid_application)
    super
    self.derek = DEFAULT_FORMS
  end

  def record_form_progression(form, section, task, state, uuid: nil)
    if uuid
      build_uuid_folder(section, task, uuid)
      sequence = derek.dig(section.to_s, task.to_s, uuid, "forms", form.to_s, "sequence") || next_sequence(section, task, uuid:)
      derek[section.to_s][task.to_s][uuid]["forms"][form.to_s] = { sequence:, updated_at: Time.zone.now, valid: state }
    else
      sequence = derek.dig(section.to_s, task.to_s, "forms", form.to_s, "sequence") || next_sequence(section, task)
      derek[section.to_s][task.to_s]["forms"][form.to_s] = { sequence:, updated_at: Time.zone.now, valid: state }
    end
    save!
  end

  def heading_summary
    derek.keys.map { |k| { "#{k}": derek[k][:state] } }
  end

  def steps_for(section)
    derek[section.to_s][task.to_s]["forms"].sort_by { |hash| hash[1]["sequence"] }
  end

private

  def next_sequence(section, task, uuid: nil)
    forms = uuid.nil? ? derek[section.to_s][task.to_s]["forms"] : derek[section.to_s][task.to_s][uuid]["forms"]
    return 1 if forms == {}

    forms.map { |form| form[1]["sequence"] }.max + 1
  end

  def clive
    derek.deep_symbolize_keys
  end

  def build_uuid_folder(section, task, uuid)
    derek[section.to_s][task.to_s][uuid] = { "forms" => {}, "state" => :in_progress } if derek[section.to_s][task.to_s][uuid].nil?
  end
end
