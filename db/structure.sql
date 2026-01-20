SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    blob_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    record_id uuid NOT NULL,
    record_type character varying NOT NULL
);


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    content_type character varying,
    created_at timestamp without time zone NOT NULL,
    filename character varying NOT NULL,
    key character varying NOT NULL,
    metadata text,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id uuid NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: actor_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actor_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    permission_id uuid,
    permittable_id uuid,
    permittable_type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address_line_one character varying,
    address_line_three character varying,
    address_line_two character varying,
    applicant_id uuid NOT NULL,
    building_number_name character varying,
    care_of character varying,
    care_of_first_name character varying,
    care_of_last_name character varying,
    care_of_organisation_name character varying,
    city character varying,
    country_code character varying,
    country_name character varying,
    county character varying,
    created_at timestamp without time zone NOT NULL,
    location character varying,
    lookup_id character varying,
    lookup_used boolean DEFAULT false NOT NULL,
    organisation character varying,
    postcode character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    auth_provider character varying DEFAULT ''::character varying NOT NULL,
    auth_subject_uid character varying,
    created_at timestamp without time zone NOT NULL,
    current_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip inet,
    locked_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    username character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: allegations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.allegations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    additional_information character varying,
    created_at timestamp(6) without time zone NOT NULL,
    denies_all boolean,
    legal_aid_application_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body character varying,
    created_at timestamp(6) without time zone NOT NULL,
    display_type integer,
    end_at timestamp(6) without time zone,
    gov_uk_header_bar character varying,
    heading character varying,
    link_display character varying,
    link_url character varying,
    start_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: appeals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appeals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    court_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    original_judge_level character varying,
    second_appeal boolean,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: applicants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applicants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    age_for_means_test_purposes integer,
    applied_previously boolean,
    armed_forces boolean DEFAULT false,
    changed_last_name boolean,
    confirmation_sent_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    correspondence_address_choice character varying,
    created_at timestamp without time zone NOT NULL,
    date_of_birth date,
    email character varying,
    employed boolean,
    encrypted_true_layer_token jsonb,
    extra_employment_information boolean,
    extra_employment_information_details character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    first_name character varying,
    has_national_insurance_number boolean,
    has_partner boolean,
    last_name character varying,
    last_name_at_birth character varying,
    locked_at timestamp without time zone,
    national_insurance_number character varying,
    no_fixed_residence boolean,
    partner_has_contrary_interest boolean,
    previous_reference character varying,
    receives_state_benefits boolean,
    relationship_to_children character varying,
    remember_created_at timestamp without time zone,
    remember_token character varying,
    same_correspondence_and_home_address boolean,
    self_employed boolean DEFAULT false,
    shared_benefit_with_partner boolean,
    student_finance boolean,
    student_finance_amount numeric,
    unlock_token character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: application_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_digests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    applicant_age integer,
    autogranted boolean,
    bank_statements_path boolean,
    biological_parent boolean,
    child_subject boolean,
    contrary_interest boolean,
    created_at timestamp(6) without time zone NOT NULL,
    date_started date NOT NULL,
    date_submitted date,
    days_to_submission integer,
    df_reported_date date,
    df_used boolean DEFAULT false,
    earliest_df_date date,
    ecct_routed boolean,
    employed boolean DEFAULT false NOT NULL,
    family_linked boolean,
    family_linked_lead_or_associated character varying,
    firm_name character varying NOT NULL,
    has_partner boolean,
    hmrc_data_used boolean DEFAULT false NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    legal_linked boolean,
    legal_linked_lead_or_associated character varying,
    matter_types character varying NOT NULL,
    no_fixed_address boolean,
    non_means_tested boolean,
    number_of_family_linked_applications integer,
    number_of_legal_linked_applications integer,
    parental_responsibility_agreement boolean,
    parental_responsibility_court_order boolean,
    parental_responsibility_evidence boolean,
    partner_dwp_challenge boolean,
    passported boolean DEFAULT false,
    proceedings character varying NOT NULL,
    provider_username character varying NOT NULL,
    referred_to_caseworker boolean DEFAULT false NOT NULL,
    true_layer_data boolean,
    true_layer_path boolean,
    updated_at timestamp(6) without time zone NOT NULL,
    use_ccms boolean DEFAULT false,
    working_days_to_report_df integer,
    working_days_to_submit_df integer
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    attachment_name character varying,
    attachment_type character varying,
    created_at timestamp without time zone NOT NULL,
    legal_aid_application_id uuid,
    original_filename text,
    pdf_attachment_id uuid,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attempts_to_settles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attempts_to_settles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    attempts_made text,
    created_at timestamp(6) without time zone NOT NULL,
    proceeding_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bank_account_holders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_account_holders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    addresses json,
    bank_provider_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    date_of_birth date,
    full_name character varying,
    true_layer_response json,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_number character varying,
    account_type character varying,
    balance numeric,
    bank_provider_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    currency character varying,
    name character varying,
    sort_code character varying,
    true_layer_balance_response json,
    true_layer_id character varying,
    true_layer_response json,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_errors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    applicant_id uuid NOT NULL,
    bank_name character varying,
    created_at timestamp without time zone NOT NULL,
    error text,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_holidays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_holidays (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    dates text,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    applicant_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    credentials_id character varying,
    name character varying,
    true_layer_provider_id character varying,
    true_layer_response json,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    amount numeric,
    bank_account_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    currency character varying,
    description character varying,
    flags json,
    happened_at timestamp without time zone,
    merchant character varying,
    meta_data character varying,
    operation character varying,
    running_balance numeric,
    transaction_type_id uuid,
    true_layer_id character varying,
    true_layer_response json,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: benefit_check_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.benefit_check_results (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    dwp_ref character varying,
    legal_aid_application_id uuid NOT NULL,
    result character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: capital_disregards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capital_disregards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_name character varying,
    amount numeric,
    created_at timestamp(6) without time zone NOT NULL,
    date_received date,
    legal_aid_application_id uuid NOT NULL,
    mandatory boolean NOT NULL,
    name character varying NOT NULL,
    payment_reason character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cash_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cash_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    amount numeric,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id character varying,
    month_number integer,
    owner_id uuid,
    owner_type character varying,
    transaction_date date,
    transaction_type_id uuid,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ccms_opponent_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_opponent_ids (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    serial_id integer NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ccms_submission_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_submission_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    attachment_id uuid,
    ccms_document_id character varying,
    created_at timestamp without time zone NOT NULL,
    document_type character varying,
    status character varying,
    submission_id uuid,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ccms_submission_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_submission_histories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    details text,
    from_state character varying,
    request text,
    response text,
    submission_id uuid NOT NULL,
    success boolean,
    to_state character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ccms_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    aasm_state character varying,
    applicant_add_transaction_id character varying,
    applicant_ccms_reference character varying,
    applicant_poll_count integer DEFAULT 0,
    case_add_transaction_id character varying,
    case_ccms_reference character varying,
    case_poll_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    legal_aid_application_id uuid,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cfe_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfe_results (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    legal_aid_application_id uuid,
    result text,
    submission_id uuid,
    type character varying DEFAULT 'CFE::V1::Result'::character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cfe_submission_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfe_submission_histories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    error_backtrace character varying,
    error_message character varying,
    http_method character varying,
    http_response_status integer,
    request_payload text,
    response_payload text,
    submission_id uuid,
    updated_at timestamp without time zone NOT NULL,
    url character varying
);


--
-- Name: cfe_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfe_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    aasm_state character varying,
    assessment_id uuid,
    cfe_result text,
    created_at timestamp without time zone NOT NULL,
    error_message character varying,
    legal_aid_application_id uuid,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: chances_of_successes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chances_of_successes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    application_purpose text,
    created_at timestamp without time zone NOT NULL,
    proceeding_id uuid NOT NULL,
    success_likely boolean,
    success_prospect character varying,
    success_prospect_details text,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: child_care_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.child_care_assessments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    assessed boolean,
    created_at timestamp(6) without time zone NOT NULL,
    details character varying,
    proceeding_id uuid NOT NULL,
    result boolean,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: citizen_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.citizen_access_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    expires_on date NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    token character varying DEFAULT ''::character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: datastore_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datastore_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body text,
    created_at timestamp(6) without time zone NOT NULL,
    headers jsonb,
    legal_aid_application_id uuid NOT NULL,
    status integer,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: debugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debugs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    auth_params character varying,
    browser_details character varying,
    callback_params character varying,
    callback_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    debug_type character varying,
    error_details character varying,
    legal_aid_application_id character varying,
    session text,
    session_id character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: dependants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dependants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    assets_value numeric,
    created_at timestamp without time zone NOT NULL,
    date_of_birth date,
    has_assets_more_than_threshold boolean,
    has_income boolean,
    in_full_time_education boolean,
    legal_aid_application_id uuid NOT NULL,
    monthly_income numeric,
    name character varying,
    number integer,
    relationship character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ccms_document_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying,
    display_on_evidence_upload boolean DEFAULT false NOT NULL,
    file_extension character varying,
    mandatory boolean DEFAULT false NOT NULL,
    name character varying NOT NULL,
    submit_to_ccms boolean DEFAULT false NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: domestic_abuse_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.domestic_abuse_summaries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bail_conditions_set boolean,
    bail_conditions_set_details text,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    police_notified boolean,
    police_notified_details text,
    updated_at timestamp(6) without time zone NOT NULL,
    warning_letter_sent boolean,
    warning_letter_sent_details text
);


--
-- Name: dwp_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dwp_overrides (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    has_evidence_of_benefit boolean,
    legal_aid_application_id uuid NOT NULL,
    passporting_benefit text,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: employment_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employment_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    benefits_in_kind numeric DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    date date NOT NULL,
    employment_id uuid,
    gross numeric DEFAULT 0.0 NOT NULL,
    national_insurance numeric DEFAULT 0.0 NOT NULL,
    net_employment_income numeric DEFAULT 0.0 NOT NULL,
    tax numeric DEFAULT 0.0 NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: employments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid,
    name character varying NOT NULL,
    owner_id uuid,
    owner_type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    browser character varying,
    browser_version character varying,
    contact_email character varying,
    contact_name character varying,
    created_at timestamp without time zone NOT NULL,
    difficulty integer,
    difficulty_reason text,
    done_all_needed boolean,
    done_all_needed_reason text,
    email character varying,
    improvement_suggestion text,
    legal_aid_application_id uuid,
    originating_page character varying,
    os character varying,
    satisfaction integer,
    satisfaction_reason text,
    source character varying,
    time_taken_satisfaction integer,
    time_taken_satisfaction_reason text,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: final_hearings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.final_hearings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    date date,
    details character varying,
    listed boolean NOT NULL,
    proceeding_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    work_type integer
);


--
-- Name: firms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.firms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ccms_id character varying,
    created_at timestamp without time zone NOT NULL,
    name character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: hmrc_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hmrc_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid,
    owner_id uuid,
    owner_type character varying,
    response json,
    submission_id character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying,
    use_case character varying
);


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    details text,
    first_contact_date date,
    legal_aid_application_id uuid,
    occurred_on date,
    told_on date,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: individuals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.individuals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    first_name character varying,
    last_name character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: involved_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.involved_children (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ccms_opponent_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    date_of_birth date,
    full_name character varying,
    legal_aid_application_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: legal_aid_application_transaction_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_aid_application_transaction_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    legal_aid_application_id uuid,
    owner_id uuid,
    owner_type character varying,
    transaction_type_id uuid,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legal_aid_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_aid_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    allowed_document_categories character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    applicant_id uuid,
    applicant_in_receipt_of_housing_benefit boolean,
    application_ref character varying,
    case_cloned boolean,
    client_declaration_confirmed_at timestamp without time zone,
    completed_at timestamp without time zone,
    copy_case boolean,
    copy_case_id uuid,
    created_at timestamp without time zone NOT NULL,
    datastore_id uuid,
    declaration_accepted_at timestamp without time zone,
    discarded_at timestamp without time zone,
    draft boolean,
    dwp_result_confirmed boolean,
    emergency_cost_override boolean,
    emergency_cost_reasons character varying,
    emergency_cost_requested numeric,
    extra_employment_information boolean,
    extra_employment_information_details character varying,
    full_employment_details character varying,
    has_dependants boolean,
    has_offline_accounts boolean,
    has_restrictions boolean,
    in_scope_of_laspo boolean,
    linked_application_completed boolean,
    merits_submitted_at timestamp without time zone,
    no_cash_income boolean,
    no_cash_outgoings boolean,
    no_credit_transaction_types_selected boolean,
    no_debit_transaction_types_selected boolean,
    office_id uuid,
    open_banking_consent boolean,
    open_banking_consent_choice_at timestamp without time zone,
    outstanding_mortgage_amount numeric,
    own_home character varying,
    own_vehicle boolean,
    percentage_home numeric,
    plf_court_order boolean,
    property_value numeric(10,2),
    provider_id uuid,
    provider_received_citizen_consent boolean,
    provider_step character varying,
    provider_step_params json,
    purgeable_on date,
    restrictions_details character varying,
    reviewed text,
    separate_representation_required boolean,
    shared_ownership character varying,
    substantive_application boolean,
    substantive_application_deadline_on date,
    substantive_cost_override boolean,
    substantive_cost_reasons character varying,
    substantive_cost_requested numeric,
    transaction_period_finish_on date,
    transaction_period_start_on date,
    transactions_gathered boolean,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legal_framework_merits_task_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_framework_merits_task_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid,
    serialized_data text,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: legal_framework_submission_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_framework_submission_histories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    error_backtrace character varying,
    error_message character varying,
    http_method character varying,
    http_response_status integer,
    request_payload text,
    response_payload text,
    submission_id uuid,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying
);


--
-- Name: legal_framework_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_framework_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    error_message character varying,
    legal_aid_application_id uuid,
    request_id uuid,
    result text,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: linked_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linked_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    associated_application_id uuid NOT NULL,
    confirm_link boolean,
    created_at timestamp(6) without time zone NOT NULL,
    lead_application_id uuid,
    link_type_code character varying,
    target_application_id uuid,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: malware_scan_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.malware_scan_results (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    file_details json,
    scan_result text,
    scanner_working boolean,
    updated_at timestamp without time zone NOT NULL,
    uploader_id uuid,
    uploader_type character varying,
    virus_found boolean NOT NULL
);


--
-- Name: matter_oppositions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matter_oppositions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    matter_opposed boolean,
    reason text DEFAULT ''::text NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ccms_id character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    firm_id uuid,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: offices_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offices_providers (
    office_id uuid NOT NULL,
    provider_id uuid NOT NULL
);


--
-- Name: opponents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opponents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ccms_opponent_id integer,
    created_at timestamp without time zone NOT NULL,
    exists_in_ccms boolean DEFAULT false,
    legal_aid_application_id uuid NOT NULL,
    opposable_id uuid,
    opposable_type character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: opponents_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opponents_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    has_opponents_application boolean,
    proceeding_id uuid NOT NULL,
    reason_for_applying character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ccms_type_code character varying NOT NULL,
    ccms_type_text character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: other_assets_declarations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.other_assets_declarations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    inherited_assets_value numeric,
    land_value numeric,
    legal_aid_application_id uuid NOT NULL,
    money_owed_value numeric,
    none_selected boolean,
    second_home_mortgage numeric,
    second_home_percentage numeric,
    second_home_value numeric,
    timeshare_property_value numeric,
    trust_value numeric,
    updated_at timestamp without time zone NOT NULL,
    valuable_items_value numeric
);


--
-- Name: parties_mental_capacities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_mental_capacities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    understands_terms_of_court_order boolean,
    understands_terms_of_court_order_details text,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    armed_forces boolean,
    created_at timestamp(6) without time zone NOT NULL,
    date_of_birth date,
    employed boolean,
    extra_employment_information boolean,
    extra_employment_information_details character varying,
    first_name character varying,
    full_employment_details character varying,
    has_national_insurance_number boolean,
    last_name character varying,
    legal_aid_application_id uuid NOT NULL,
    national_insurance_number character varying,
    no_cash_income boolean,
    no_cash_outgoings boolean,
    receives_state_benefits boolean,
    self_employed boolean,
    shared_benefit_with_applicant boolean,
    student_finance boolean,
    student_finance_amount numeric,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    description character varying,
    role character varying
);


--
-- Name: policy_disregards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.policy_disregards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    criminal_injuries_compensation_scheme boolean,
    england_infected_blood_support boolean,
    legal_aid_application_id uuid,
    london_emergencies_trust boolean,
    national_emergencies_trust boolean,
    none_selected boolean,
    updated_at timestamp(6) without time zone NOT NULL,
    vaccine_damage_payments boolean,
    variant_creutzfeldt_jakob_disease boolean,
    we_love_manchester_emergency_fund boolean
);


--
-- Name: proceedings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proceedings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    accepted_emergency_defaults boolean,
    accepted_substantive_defaults boolean,
    category_law_code character varying NOT NULL,
    category_of_law character varying NOT NULL,
    ccms_code character varying NOT NULL,
    ccms_matter_code character varying,
    client_involvement_type_ccms_code character varying,
    client_involvement_type_description character varying,
    created_at timestamp(6) without time zone NOT NULL,
    delegated_functions_cost_limitation numeric NOT NULL,
    description character varying NOT NULL,
    emergency_level_of_service integer,
    emergency_level_of_service_name character varying,
    emergency_level_of_service_stage integer,
    lead_proceeding boolean DEFAULT false NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    matter_type character varying NOT NULL,
    meaning character varying NOT NULL,
    name character varying NOT NULL,
    proceeding_case_id integer,
    related_orders character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    sca_type character varying,
    substantive_cost_limitation numeric NOT NULL,
    substantive_level_of_service integer,
    substantive_level_of_service_name character varying,
    substantive_level_of_service_stage integer,
    updated_at timestamp(6) without time zone NOT NULL,
    used_delegated_functions boolean,
    used_delegated_functions_on date,
    used_delegated_functions_reported_on date
);


--
-- Name: proceeding_case_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proceeding_case_id_seq
    START WITH 55000000
    INCREMENT BY 1
    MINVALUE 55000000
    NO MAXVALUE
    CACHE 100;


--
-- Name: proceeding_case_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proceeding_case_id_seq OWNED BY public.proceedings.proceeding_case_id;


--
-- Name: proceedings_linked_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proceedings_linked_children (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    involved_child_id uuid,
    proceeding_id uuid,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: prohibited_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prohibited_steps (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    details character varying,
    proceeding_id uuid NOT NULL,
    uk_removal boolean,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: provider_dismissed_announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_dismissed_announcements (
    announcement_id uuid NOT NULL,
    provider_id uuid NOT NULL
);


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    auth_provider character varying DEFAULT ''::character varying NOT NULL,
    auth_subject_uid character varying,
    ccms_contact_id integer,
    cookies_enabled boolean,
    cookies_saved_at timestamp(6) without time zone,
    created_at timestamp without time zone NOT NULL,
    current_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    email character varying,
    firm_id uuid,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip inet,
    name character varying,
    office_codes text,
    roles text,
    selected_office_id uuid,
    sign_in_count integer DEFAULT 0 NOT NULL,
    silas_id character varying,
    type character varying,
    updated_at timestamp without time zone NOT NULL,
    username character varying
);


--
-- Name: regular_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regular_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    amount numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying,
    frequency character varying NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    owner_id uuid,
    owner_type character varying,
    transaction_type_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: savings_amounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.savings_amounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    cash numeric,
    created_at timestamp without time zone NOT NULL,
    joint_offline_current_accounts numeric,
    joint_offline_savings_accounts numeric,
    legal_aid_application_id uuid NOT NULL,
    life_assurance_endowment_policy numeric,
    national_savings numeric,
    no_account_selected boolean,
    no_partner_account_selected boolean,
    none_selected boolean,
    offline_current_accounts numeric,
    offline_savings_accounts numeric,
    other_person_account numeric,
    partner_offline_current_accounts numeric,
    partner_offline_savings_accounts numeric,
    peps_unit_trusts_capital_bonds_gov_stocks numeric,
    plc_shares numeric,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: scheduled_mailings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_mailings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    addressee character varying,
    arguments character varying NOT NULL,
    cancelled_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    govuk_message_id character varying,
    legal_aid_application_id uuid,
    mailer_klass character varying NOT NULL,
    mailer_method character varying NOT NULL,
    scheduled_at timestamp without time zone NOT NULL,
    sent_at timestamp without time zone,
    status character varying,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    area_of_law character varying,
    authorisation_status character varying,
    cancelled boolean,
    category_of_law character varying,
    created_at timestamp(6) without time zone NOT NULL,
    devolved_power_status character varying,
    end_date date,
    license_indicator integer,
    office_id uuid NOT NULL,
    start_date date,
    status character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: scope_limitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scope_limitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description character varying NOT NULL,
    hearing_date date,
    limitation_note character varying,
    meaning character varying NOT NULL,
    proceeding_id uuid NOT NULL,
    scope_type integer,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alert_via_sentry boolean DEFAULT true NOT NULL,
    allow_welsh_translation boolean DEFAULT false NOT NULL,
    bank_transaction_filename character varying DEFAULT 'db/sample_data/bank_transactions.csv'::character varying,
    cfe_compare_run_at timestamp(6) without time zone,
    collect_dwp_data boolean DEFAULT true NOT NULL,
    collect_hmrc_data boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    digest_extracted_at timestamp without time zone DEFAULT '1970-01-01 00:00:01'::timestamp without time zone,
    enable_ccms_submission boolean DEFAULT true NOT NULL,
    enable_datastore_submission boolean DEFAULT false NOT NULL,
    manually_review_all_cases boolean DEFAULT true,
    mock_true_layer_data boolean DEFAULT false NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: specific_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.specific_issues (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    details character varying,
    proceeding_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: state_machine_proxies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_machine_proxies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    aasm_state character varying,
    ccms_reason character varying,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid,
    type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: statement_of_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statement_of_cases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    provider_uploader_id uuid,
    statement text,
    typed boolean,
    updated_at timestamp without time zone NOT NULL,
    upload boolean
);


--
-- Name: temp_contract_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_contract_data (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    office_code character varying,
    response json,
    success boolean,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: transaction_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    archived_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    name character varying,
    operation character varying,
    other_income boolean DEFAULT false,
    parent_id character varying,
    sort_order integer,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: true_layer_banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.true_layer_banks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    banks text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: undertakings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.undertakings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    additional_information character varying,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    offered boolean,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: uploaded_evidence_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploaded_evidence_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    provider_uploader_id uuid,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: urgencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.urgencies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    additional_information character varying,
    created_at timestamp(6) without time zone NOT NULL,
    hearing_date date,
    hearing_date_set boolean,
    legal_aid_application_id uuid NOT NULL,
    nature_of_urgency character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: vary_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vary_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    details character varying,
    proceeding_id uuid NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    estimated_value numeric,
    legal_aid_application_id uuid,
    more_than_three_years_old boolean,
    owner character varying,
    payment_remaining numeric,
    updated_at timestamp without time zone NOT NULL,
    used_regularly boolean
);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: proceedings proceeding_case_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proceedings ALTER COLUMN proceeding_case_id SET DEFAULT nextval('public.proceeding_case_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: actor_permissions actor_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor_permissions
    ADD CONSTRAINT actor_permissions_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admin_reports admin_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_reports
    ADD CONSTRAINT admin_reports_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: allegations allegations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allegations
    ADD CONSTRAINT allegations_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: appeals appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT appeals_pkey PRIMARY KEY (id);


--
-- Name: applicants applicants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applicants
    ADD CONSTRAINT applicants_pkey PRIMARY KEY (id);


--
-- Name: application_digests application_digests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_digests
    ADD CONSTRAINT application_digests_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: attempts_to_settles attempts_to_settles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attempts_to_settles
    ADD CONSTRAINT attempts_to_settles_pkey PRIMARY KEY (id);


--
-- Name: bank_account_holders bank_account_holders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_account_holders
    ADD CONSTRAINT bank_account_holders_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: bank_errors bank_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_errors
    ADD CONSTRAINT bank_errors_pkey PRIMARY KEY (id);


--
-- Name: bank_holidays bank_holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_holidays
    ADD CONSTRAINT bank_holidays_pkey PRIMARY KEY (id);


--
-- Name: bank_providers bank_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_providers
    ADD CONSTRAINT bank_providers_pkey PRIMARY KEY (id);


--
-- Name: bank_transactions bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_transactions
    ADD CONSTRAINT bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: benefit_check_results benefit_check_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benefit_check_results
    ADD CONSTRAINT benefit_check_results_pkey PRIMARY KEY (id);


--
-- Name: capital_disregards capital_disregards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capital_disregards
    ADD CONSTRAINT capital_disregards_pkey PRIMARY KEY (id);


--
-- Name: cash_transactions cash_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_transactions
    ADD CONSTRAINT cash_transactions_pkey PRIMARY KEY (id);


--
-- Name: ccms_opponent_ids ccms_opponent_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_opponent_ids
    ADD CONSTRAINT ccms_opponent_ids_pkey PRIMARY KEY (id);


--
-- Name: ccms_submission_documents ccms_submission_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_submission_documents
    ADD CONSTRAINT ccms_submission_documents_pkey PRIMARY KEY (id);


--
-- Name: ccms_submission_histories ccms_submission_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_submission_histories
    ADD CONSTRAINT ccms_submission_histories_pkey PRIMARY KEY (id);


--
-- Name: ccms_submissions ccms_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_submissions
    ADD CONSTRAINT ccms_submissions_pkey PRIMARY KEY (id);


--
-- Name: cfe_results cfe_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfe_results
    ADD CONSTRAINT cfe_results_pkey PRIMARY KEY (id);


--
-- Name: cfe_submission_histories cfe_submission_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfe_submission_histories
    ADD CONSTRAINT cfe_submission_histories_pkey PRIMARY KEY (id);


--
-- Name: cfe_submissions cfe_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfe_submissions
    ADD CONSTRAINT cfe_submissions_pkey PRIMARY KEY (id);


--
-- Name: chances_of_successes chances_of_successes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chances_of_successes
    ADD CONSTRAINT chances_of_successes_pkey PRIMARY KEY (id);


--
-- Name: child_care_assessments child_care_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_care_assessments
    ADD CONSTRAINT child_care_assessments_pkey PRIMARY KEY (id);


--
-- Name: citizen_access_tokens citizen_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citizen_access_tokens
    ADD CONSTRAINT citizen_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: datastore_submissions datastore_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datastore_submissions
    ADD CONSTRAINT datastore_submissions_pkey PRIMARY KEY (id);


--
-- Name: debugs debugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debugs
    ADD CONSTRAINT debugs_pkey PRIMARY KEY (id);


--
-- Name: dependants dependants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependants
    ADD CONSTRAINT dependants_pkey PRIMARY KEY (id);


--
-- Name: document_categories document_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_pkey PRIMARY KEY (id);


--
-- Name: domestic_abuse_summaries domestic_abuse_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domestic_abuse_summaries
    ADD CONSTRAINT domestic_abuse_summaries_pkey PRIMARY KEY (id);


--
-- Name: dwp_overrides dwp_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dwp_overrides
    ADD CONSTRAINT dwp_overrides_pkey PRIMARY KEY (id);


--
-- Name: employment_payments employment_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employment_payments
    ADD CONSTRAINT employment_payments_pkey PRIMARY KEY (id);


--
-- Name: employments employments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employments
    ADD CONSTRAINT employments_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: final_hearings final_hearings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.final_hearings
    ADD CONSTRAINT final_hearings_pkey PRIMARY KEY (id);


--
-- Name: firms firms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firms
    ADD CONSTRAINT firms_pkey PRIMARY KEY (id);


--
-- Name: hmrc_responses hmrc_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmrc_responses
    ADD CONSTRAINT hmrc_responses_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: individuals individuals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.individuals
    ADD CONSTRAINT individuals_pkey PRIMARY KEY (id);


--
-- Name: involved_children involved_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.involved_children
    ADD CONSTRAINT involved_children_pkey PRIMARY KEY (id);


--
-- Name: legal_aid_application_transaction_types legal_aid_application_transaction_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_aid_application_transaction_types
    ADD CONSTRAINT legal_aid_application_transaction_types_pkey PRIMARY KEY (id);


--
-- Name: legal_aid_applications legal_aid_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_aid_applications
    ADD CONSTRAINT legal_aid_applications_pkey PRIMARY KEY (id);


--
-- Name: legal_framework_merits_task_lists legal_framework_merits_task_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_merits_task_lists
    ADD CONSTRAINT legal_framework_merits_task_lists_pkey PRIMARY KEY (id);


--
-- Name: legal_framework_submission_histories legal_framework_submission_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_submission_histories
    ADD CONSTRAINT legal_framework_submission_histories_pkey PRIMARY KEY (id);


--
-- Name: legal_framework_submissions legal_framework_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_submissions
    ADD CONSTRAINT legal_framework_submissions_pkey PRIMARY KEY (id);


--
-- Name: linked_applications linked_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_applications
    ADD CONSTRAINT linked_applications_pkey PRIMARY KEY (id);


--
-- Name: malware_scan_results malware_scan_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.malware_scan_results
    ADD CONSTRAINT malware_scan_results_pkey PRIMARY KEY (id);


--
-- Name: matter_oppositions matter_oppositions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matter_oppositions
    ADD CONSTRAINT matter_oppositions_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: opponents_applications opponents_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opponents_applications
    ADD CONSTRAINT opponents_applications_pkey PRIMARY KEY (id);


--
-- Name: opponents opponents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opponents
    ADD CONSTRAINT opponents_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: other_assets_declarations other_assets_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.other_assets_declarations
    ADD CONSTRAINT other_assets_declarations_pkey PRIMARY KEY (id);


--
-- Name: parties_mental_capacities parties_mental_capacities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_mental_capacities
    ADD CONSTRAINT parties_mental_capacities_pkey PRIMARY KEY (id);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: policy_disregards policy_disregards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policy_disregards
    ADD CONSTRAINT policy_disregards_pkey PRIMARY KEY (id);


--
-- Name: proceedings_linked_children proceedings_linked_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proceedings_linked_children
    ADD CONSTRAINT proceedings_linked_children_pkey PRIMARY KEY (id);


--
-- Name: proceedings proceedings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proceedings
    ADD CONSTRAINT proceedings_pkey PRIMARY KEY (id);


--
-- Name: prohibited_steps prohibited_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prohibited_steps
    ADD CONSTRAINT prohibited_steps_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: regular_transactions regular_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regular_transactions
    ADD CONSTRAINT regular_transactions_pkey PRIMARY KEY (id);


--
-- Name: savings_amounts savings_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings_amounts
    ADD CONSTRAINT savings_amounts_pkey PRIMARY KEY (id);


--
-- Name: scheduled_mailings scheduled_mailings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_mailings
    ADD CONSTRAINT scheduled_mailings_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scope_limitations scope_limitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scope_limitations
    ADD CONSTRAINT scope_limitations_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: specific_issues specific_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specific_issues
    ADD CONSTRAINT specific_issues_pkey PRIMARY KEY (id);


--
-- Name: state_machine_proxies state_machine_proxies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_machine_proxies
    ADD CONSTRAINT state_machine_proxies_pkey PRIMARY KEY (id);


--
-- Name: statement_of_cases statement_of_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statement_of_cases
    ADD CONSTRAINT statement_of_cases_pkey PRIMARY KEY (id);


--
-- Name: temp_contract_data temp_contract_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temp_contract_data
    ADD CONSTRAINT temp_contract_data_pkey PRIMARY KEY (id);


--
-- Name: transaction_types transaction_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_types
    ADD CONSTRAINT transaction_types_pkey PRIMARY KEY (id);


--
-- Name: true_layer_banks true_layer_banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.true_layer_banks
    ADD CONSTRAINT true_layer_banks_pkey PRIMARY KEY (id);


--
-- Name: undertakings undertakings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undertakings
    ADD CONSTRAINT undertakings_pkey PRIMARY KEY (id);


--
-- Name: uploaded_evidence_collections uploaded_evidence_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_evidence_collections
    ADD CONSTRAINT uploaded_evidence_collections_pkey PRIMARY KEY (id);


--
-- Name: urgencies urgencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urgencies
    ADD CONSTRAINT urgencies_pkey PRIMARY KEY (id);


--
-- Name: vary_orders vary_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vary_orders
    ADD CONSTRAINT vary_orders_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: actor_permissions_unqiueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_permissions_unqiueness ON public.actor_permissions USING btree (permittable_type, permittable_id, permission_id);


--
-- Name: cash_transactions_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cash_transactions_unique ON public.cash_transactions USING btree (legal_aid_application_id, owner_id, transaction_type_id, month_number);


--
-- Name: idx_lfa_merits_task_lists_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lfa_merits_task_lists_on_legal_aid_application_id ON public.legal_framework_merits_task_lists USING btree (legal_aid_application_id);


--
-- Name: idx_on_legal_aid_application_id_name_mandatory_f4f47d6261; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_legal_aid_application_id_name_mandatory_f4f47d6261 ON public.capital_disregards USING btree (legal_aid_application_id, name, mandatory);


--
-- Name: idx_on_provider_id_announcement_id_d796f4e801; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_provider_id_announcement_id_d796f4e801 ON public.provider_dismissed_announcements USING btree (provider_id, announcement_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_actor_permissions_on_permittable_type_and_permittable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_actor_permissions_on_permittable_type_and_permittable_id ON public.actor_permissions USING btree (permittable_type, permittable_id);


--
-- Name: index_addresses_on_applicant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_applicant_id ON public.addresses USING btree (applicant_id);


--
-- Name: index_allegations_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_allegations_on_legal_aid_application_id ON public.allegations USING btree (legal_aid_application_id);


--
-- Name: index_appeals_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_appeals_on_legal_aid_application_id ON public.appeals USING btree (legal_aid_application_id);


--
-- Name: index_applicants_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_applicants_on_confirmation_token ON public.applicants USING btree (confirmation_token);


--
-- Name: index_applicants_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_applicants_on_email ON public.applicants USING btree (email);


--
-- Name: index_applicants_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_applicants_on_unlock_token ON public.applicants USING btree (unlock_token);


--
-- Name: index_application_digests_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_application_digests_on_legal_aid_application_id ON public.application_digests USING btree (legal_aid_application_id);


--
-- Name: index_attempts_to_settles_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attempts_to_settles_on_proceeding_id ON public.attempts_to_settles USING btree (proceeding_id);


--
-- Name: index_bank_account_holders_on_bank_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_account_holders_on_bank_provider_id ON public.bank_account_holders USING btree (bank_provider_id);


--
-- Name: index_bank_accounts_on_bank_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_accounts_on_bank_provider_id ON public.bank_accounts USING btree (bank_provider_id);


--
-- Name: index_bank_errors_on_applicant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_errors_on_applicant_id ON public.bank_errors USING btree (applicant_id);


--
-- Name: index_bank_providers_on_applicant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_providers_on_applicant_id ON public.bank_providers USING btree (applicant_id);


--
-- Name: index_bank_providers_on_true_layer_provider_id_and_applicant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bank_providers_on_true_layer_provider_id_and_applicant_id ON public.bank_providers USING btree (true_layer_provider_id, applicant_id);


--
-- Name: index_bank_transactions_on_bank_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_transactions_on_bank_account_id ON public.bank_transactions USING btree (bank_account_id);


--
-- Name: index_bank_transactions_on_transaction_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_transactions_on_transaction_type_id ON public.bank_transactions USING btree (transaction_type_id);


--
-- Name: index_benefit_check_results_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_benefit_check_results_on_legal_aid_application_id ON public.benefit_check_results USING btree (legal_aid_application_id);


--
-- Name: index_capital_disregards_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_capital_disregards_on_legal_aid_application_id ON public.capital_disregards USING btree (legal_aid_application_id);


--
-- Name: index_cash_transactions_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cash_transactions_on_owner ON public.cash_transactions USING btree (owner_type, owner_id);


--
-- Name: index_ccms_submission_histories_on_submission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ccms_submission_histories_on_submission_id ON public.ccms_submission_histories USING btree (submission_id);


--
-- Name: index_ccms_submissions_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ccms_submissions_on_legal_aid_application_id ON public.ccms_submissions USING btree (legal_aid_application_id);


--
-- Name: index_cfe_submissions_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfe_submissions_on_legal_aid_application_id ON public.cfe_submissions USING btree (legal_aid_application_id);


--
-- Name: index_chances_of_successes_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chances_of_successes_on_proceeding_id ON public.chances_of_successes USING btree (proceeding_id);


--
-- Name: index_child_care_assessments_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_care_assessments_on_proceeding_id ON public.child_care_assessments USING btree (proceeding_id);


--
-- Name: index_citizen_access_tokens_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_citizen_access_tokens_on_legal_aid_application_id ON public.citizen_access_tokens USING btree (legal_aid_application_id);


--
-- Name: index_datastore_submissions_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datastore_submissions_on_legal_aid_application_id ON public.datastore_submissions USING btree (legal_aid_application_id);


--
-- Name: index_dependants_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dependants_on_legal_aid_application_id ON public.dependants USING btree (legal_aid_application_id);


--
-- Name: index_domestic_abuse_summaries_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_domestic_abuse_summaries_on_legal_aid_application_id ON public.domestic_abuse_summaries USING btree (legal_aid_application_id);


--
-- Name: index_dwp_overrides_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_dwp_overrides_on_legal_aid_application_id ON public.dwp_overrides USING btree (legal_aid_application_id);


--
-- Name: index_employment_payments_on_employment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employment_payments_on_employment_id ON public.employment_payments USING btree (employment_id);


--
-- Name: index_employments_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employments_on_legal_aid_application_id ON public.employments USING btree (legal_aid_application_id);


--
-- Name: index_employments_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_employments_on_owner ON public.employments USING btree (owner_type, owner_id);


--
-- Name: index_final_hearings_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_final_hearings_on_proceeding_id ON public.final_hearings USING btree (proceeding_id);


--
-- Name: index_hmrc_responses_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hmrc_responses_on_legal_aid_application_id ON public.hmrc_responses USING btree (legal_aid_application_id);


--
-- Name: index_hmrc_responses_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hmrc_responses_on_owner ON public.hmrc_responses USING btree (owner_type, owner_id);


--
-- Name: index_incidents_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incidents_on_legal_aid_application_id ON public.incidents USING btree (legal_aid_application_id);


--
-- Name: index_involved_child_proceeding; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_involved_child_proceeding ON public.proceedings_linked_children USING btree (involved_child_id, proceeding_id);


--
-- Name: index_involved_children_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_involved_children_on_legal_aid_application_id ON public.involved_children USING btree (legal_aid_application_id);


--
-- Name: index_legal_aid_application_transaction_types_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_aid_application_transaction_types_on_owner ON public.legal_aid_application_transaction_types USING btree (owner_type, owner_id);


--
-- Name: index_legal_aid_applications_on_applicant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_aid_applications_on_applicant_id ON public.legal_aid_applications USING btree (applicant_id);


--
-- Name: index_legal_aid_applications_on_application_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_legal_aid_applications_on_application_ref ON public.legal_aid_applications USING btree (application_ref);


--
-- Name: index_legal_aid_applications_on_datastore_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_legal_aid_applications_on_datastore_id ON public.legal_aid_applications USING btree (datastore_id);


--
-- Name: index_legal_aid_applications_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_aid_applications_on_discarded_at ON public.legal_aid_applications USING btree (discarded_at);


--
-- Name: index_legal_aid_applications_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_aid_applications_on_office_id ON public.legal_aid_applications USING btree (office_id);


--
-- Name: index_legal_aid_applications_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_aid_applications_on_provider_id ON public.legal_aid_applications USING btree (provider_id);


--
-- Name: index_legal_framework_submissions_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_framework_submissions_on_legal_aid_application_id ON public.legal_framework_submissions USING btree (legal_aid_application_id);


--
-- Name: index_linked_applications; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_linked_applications ON public.linked_applications USING btree (lead_application_id, associated_application_id);


--
-- Name: index_linked_applications_on_associated_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_linked_applications_on_associated_application_id ON public.linked_applications USING btree (associated_application_id);


--
-- Name: index_linked_applications_on_lead_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_linked_applications_on_lead_application_id ON public.linked_applications USING btree (lead_application_id);


--
-- Name: index_linked_applications_on_target_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_linked_applications_on_target_application_id ON public.linked_applications USING btree (target_application_id);


--
-- Name: index_malware_scan_results_on_uploader_type_and_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_malware_scan_results_on_uploader_type_and_uploader_id ON public.malware_scan_results USING btree (uploader_type, uploader_id);


--
-- Name: index_matter_oppositions_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matter_oppositions_on_legal_aid_application_id ON public.matter_oppositions USING btree (legal_aid_application_id);


--
-- Name: index_offices_on_firm_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_firm_id ON public.offices USING btree (firm_id);


--
-- Name: index_offices_providers_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_providers_on_office_id ON public.offices_providers USING btree (office_id);


--
-- Name: index_offices_providers_on_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_providers_on_provider_id ON public.offices_providers USING btree (provider_id);


--
-- Name: index_opponents_applications_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opponents_applications_on_proceeding_id ON public.opponents_applications USING btree (proceeding_id);


--
-- Name: index_opponents_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opponents_on_legal_aid_application_id ON public.opponents USING btree (legal_aid_application_id);


--
-- Name: index_opponents_on_opposable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_opponents_on_opposable ON public.opponents USING btree (opposable_type, opposable_id);


--
-- Name: index_other_assets_declarations_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_other_assets_declarations_on_legal_aid_application_id ON public.other_assets_declarations USING btree (legal_aid_application_id);


--
-- Name: index_parties_mental_capacities_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_mental_capacities_on_legal_aid_application_id ON public.parties_mental_capacities USING btree (legal_aid_application_id);


--
-- Name: index_partners_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_partners_on_legal_aid_application_id ON public.partners USING btree (legal_aid_application_id);


--
-- Name: index_permissions_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_role ON public.permissions USING btree (role);


--
-- Name: index_policy_disregards_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_policy_disregards_on_legal_aid_application_id ON public.policy_disregards USING btree (legal_aid_application_id);


--
-- Name: index_proceeding_involved_child; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_proceeding_involved_child ON public.proceedings_linked_children USING btree (proceeding_id, involved_child_id);


--
-- Name: index_proceedings_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proceedings_on_legal_aid_application_id ON public.proceedings USING btree (legal_aid_application_id);


--
-- Name: index_proceedings_on_proceeding_case_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_proceedings_on_proceeding_case_id ON public.proceedings USING btree (proceeding_case_id);


--
-- Name: index_prohibited_steps_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prohibited_steps_on_proceeding_id ON public.prohibited_steps USING btree (proceeding_id);


--
-- Name: index_providers_on_auth_subject_uid_and_auth_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_providers_on_auth_subject_uid_and_auth_provider ON public.providers USING btree (auth_subject_uid, auth_provider);


--
-- Name: index_providers_on_firm_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_providers_on_firm_id ON public.providers USING btree (firm_id);


--
-- Name: index_providers_on_selected_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_providers_on_selected_office_id ON public.providers USING btree (selected_office_id);


--
-- Name: index_providers_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_providers_on_type ON public.providers USING btree (type);


--
-- Name: index_providers_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_providers_on_username ON public.providers USING btree (username);


--
-- Name: index_regular_transactions_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_transactions_on_legal_aid_application_id ON public.regular_transactions USING btree (legal_aid_application_id);


--
-- Name: index_regular_transactions_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_transactions_on_owner ON public.regular_transactions USING btree (owner_type, owner_id);


--
-- Name: index_regular_transactions_on_transaction_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_regular_transactions_on_transaction_type_id ON public.regular_transactions USING btree (transaction_type_id);


--
-- Name: index_savings_amounts_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_savings_amounts_on_legal_aid_application_id ON public.savings_amounts USING btree (legal_aid_application_id);


--
-- Name: index_schedules_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schedules_on_office_id ON public.schedules USING btree (office_id);


--
-- Name: index_scope_limitations_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scope_limitations_on_proceeding_id ON public.scope_limitations USING btree (proceeding_id);


--
-- Name: index_specific_issues_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_specific_issues_on_proceeding_id ON public.specific_issues USING btree (proceeding_id);


--
-- Name: index_statement_of_cases_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statement_of_cases_on_legal_aid_application_id ON public.statement_of_cases USING btree (legal_aid_application_id);


--
-- Name: index_statement_of_cases_on_provider_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statement_of_cases_on_provider_uploader_id ON public.statement_of_cases USING btree (provider_uploader_id);


--
-- Name: index_transaction_types_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transaction_types_on_parent_id ON public.transaction_types USING btree (parent_id);


--
-- Name: index_undertakings_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_undertakings_on_legal_aid_application_id ON public.undertakings USING btree (legal_aid_application_id);


--
-- Name: index_uploaded_evidence_collections_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploaded_evidence_collections_on_legal_aid_application_id ON public.uploaded_evidence_collections USING btree (legal_aid_application_id);


--
-- Name: index_uploaded_evidence_collections_on_provider_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploaded_evidence_collections_on_provider_uploader_id ON public.uploaded_evidence_collections USING btree (provider_uploader_id);


--
-- Name: index_urgencies_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_urgencies_on_legal_aid_application_id ON public.urgencies USING btree (legal_aid_application_id);


--
-- Name: index_vary_orders_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vary_orders_on_proceeding_id ON public.vary_orders USING btree (proceeding_id);


--
-- Name: index_vehicles_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_legal_aid_application_id ON public.vehicles USING btree (legal_aid_application_id);


--
-- Name: laa_trans_type_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX laa_trans_type_on_legal_aid_application_id ON public.legal_aid_application_transaction_types USING btree (legal_aid_application_id);


--
-- Name: laa_trans_type_on_transaction_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX laa_trans_type_on_transaction_type_id ON public.legal_aid_application_transaction_types USING btree (transaction_type_id);


--
-- Name: proceeding_work_type_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX proceeding_work_type_unique ON public.final_hearings USING btree (proceeding_id, work_type);


--
-- Name: undertakings fk_rails_01a61af711; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.undertakings
    ADD CONSTRAINT fk_rails_01a61af711 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: matter_oppositions fk_rails_0867a070b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matter_oppositions
    ADD CONSTRAINT fk_rails_0867a070b3 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: datastore_submissions fk_rails_09f29e463b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datastore_submissions
    ADD CONSTRAINT fk_rails_09f29e463b FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: opponents_applications fk_rails_1154dda51b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opponents_applications
    ADD CONSTRAINT fk_rails_1154dda51b FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: offices_providers fk_rails_1164548430; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices_providers
    ADD CONSTRAINT fk_rails_1164548430 FOREIGN KEY (provider_id) REFERENCES public.providers(id);


--
-- Name: savings_amounts fk_rails_14a9c12d36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings_amounts
    ADD CONSTRAINT fk_rails_14a9c12d36 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: hmrc_responses fk_rails_169b937c33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmrc_responses
    ADD CONSTRAINT fk_rails_169b937c33 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: dwp_overrides fk_rails_195e02e5bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dwp_overrides
    ADD CONSTRAINT fk_rails_195e02e5bb FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: final_hearings fk_rails_1983568db1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.final_hearings
    ADD CONSTRAINT fk_rails_1983568db1 FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: scheduled_mailings fk_rails_1a034d34c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_mailings
    ADD CONSTRAINT fk_rails_1a034d34c3 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: capital_disregards fk_rails_22958d9721; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capital_disregards
    ADD CONSTRAINT fk_rails_22958d9721 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: child_care_assessments fk_rails_2e618d7d32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_care_assessments
    ADD CONSTRAINT fk_rails_2e618d7d32 FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: providers fk_rails_3a530dfb8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT fk_rails_3a530dfb8a FOREIGN KEY (firm_id) REFERENCES public.firms(id);


--
-- Name: offices fk_rails_3a71fe28b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT fk_rails_3a71fe28b9 FOREIGN KEY (firm_id) REFERENCES public.firms(id);


--
-- Name: citizen_access_tokens fk_rails_3e3524c9fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citizen_access_tokens
    ADD CONSTRAINT fk_rails_3e3524c9fc FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: offices_providers fk_rails_45287c485e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices_providers
    ADD CONSTRAINT fk_rails_45287c485e FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: legal_aid_applications fk_rails_53181a399a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_aid_applications
    ADD CONSTRAINT fk_rails_53181a399a FOREIGN KEY (provider_id) REFERENCES public.providers(id);


--
-- Name: cfe_submissions fk_rails_5976c6384c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfe_submissions
    ADD CONSTRAINT fk_rails_5976c6384c FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: attempts_to_settles fk_rails_5b5834d2db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attempts_to_settles
    ADD CONSTRAINT fk_rails_5b5834d2db FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: bank_providers fk_rails_5d445bd6ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_providers
    ADD CONSTRAINT fk_rails_5d445bd6ae FOREIGN KEY (applicant_id) REFERENCES public.applicants(id);


--
-- Name: domestic_abuse_summaries fk_rails_5ddf237bea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domestic_abuse_summaries
    ADD CONSTRAINT fk_rails_5ddf237bea FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: bank_errors fk_rails_68a2610735; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_errors
    ADD CONSTRAINT fk_rails_68a2610735 FOREIGN KEY (applicant_id) REFERENCES public.applicants(id);


--
-- Name: parties_mental_capacities fk_rails_70af62c194; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_mental_capacities
    ADD CONSTRAINT fk_rails_70af62c194 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: chances_of_successes fk_rails_7549c96c78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chances_of_successes
    ADD CONSTRAINT fk_rails_7549c96c78 FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id) ON DELETE CASCADE;


--
-- Name: scope_limitations fk_rails_79beb7931b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scope_limitations
    ADD CONSTRAINT fk_rails_79beb7931b FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: linked_applications fk_rails_7e38d4e648; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_applications
    ADD CONSTRAINT fk_rails_7e38d4e648 FOREIGN KEY (lead_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: legal_framework_merits_task_lists fk_rails_7e5016e4d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_merits_task_lists
    ADD CONSTRAINT fk_rails_7e5016e4d1 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: opponents fk_rails_845e90b386; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opponents
    ADD CONSTRAINT fk_rails_845e90b386 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: involved_children fk_rails_84782c3371; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.involved_children
    ADD CONSTRAINT fk_rails_84782c3371 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: uploaded_evidence_collections fk_rails_94f3fcab73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_evidence_collections
    ADD CONSTRAINT fk_rails_94f3fcab73 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: ccms_submission_documents fk_rails_960144ae0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_submission_documents
    ADD CONSTRAINT fk_rails_960144ae0a FOREIGN KEY (submission_id) REFERENCES public.ccms_submissions(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: appeals fk_rails_9a9d4f6f3a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT fk_rails_9a9d4f6f3a FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: bank_account_holders fk_rails_a0f80d0f18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_account_holders
    ADD CONSTRAINT fk_rails_a0f80d0f18 FOREIGN KEY (bank_provider_id) REFERENCES public.bank_providers(id);


--
-- Name: schedules fk_rails_a4e3c64dab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT fk_rails_a4e3c64dab FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: bank_accounts fk_rails_abe5d8e458; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT fk_rails_abe5d8e458 FOREIGN KEY (bank_provider_id) REFERENCES public.bank_providers(id);


--
-- Name: statement_of_cases fk_rails_af27619940; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statement_of_cases
    ADD CONSTRAINT fk_rails_af27619940 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: proceedings fk_rails_afb3918af6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proceedings
    ADD CONSTRAINT fk_rails_afb3918af6 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: legal_aid_applications fk_rails_aff9b8137a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_aid_applications
    ADD CONSTRAINT fk_rails_aff9b8137a FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: dependants fk_rails_b02c1a3b4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependants
    ADD CONSTRAINT fk_rails_b02c1a3b4c FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: vehicles fk_rails_b4353d474e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_rails_b4353d474e FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: ccms_submission_histories fk_rails_b6cb5ce566; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_submission_histories
    ADD CONSTRAINT fk_rails_b6cb5ce566 FOREIGN KEY (submission_id) REFERENCES public.ccms_submissions(id);


--
-- Name: regular_transactions fk_rails_b945fba464; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regular_transactions
    ADD CONSTRAINT fk_rails_b945fba464 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: addresses fk_rails_bdbaa9e97e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_bdbaa9e97e FOREIGN KEY (applicant_id) REFERENCES public.applicants(id);


--
-- Name: legal_aid_applications fk_rails_c2e4722109; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_aid_applications
    ADD CONSTRAINT fk_rails_c2e4722109 FOREIGN KEY (applicant_id) REFERENCES public.applicants(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: allegations fk_rails_c680eb4130; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allegations
    ADD CONSTRAINT fk_rails_c680eb4130 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: linked_applications fk_rails_cb92d5c1e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_applications
    ADD CONSTRAINT fk_rails_cb92d5c1e7 FOREIGN KEY (associated_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: benefit_check_results fk_rails_d026359e92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benefit_check_results
    ADD CONSTRAINT fk_rails_d026359e92 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: employment_payments fk_rails_d20df15de1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employment_payments
    ADD CONSTRAINT fk_rails_d20df15de1 FOREIGN KEY (employment_id) REFERENCES public.employments(id);


--
-- Name: prohibited_steps fk_rails_da8ef3470c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prohibited_steps
    ADD CONSTRAINT fk_rails_da8ef3470c FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: legal_framework_submissions fk_rails_daf85484ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_submissions
    ADD CONSTRAINT fk_rails_daf85484ba FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: employments fk_rails_dca20df915; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employments
    ADD CONSTRAINT fk_rails_dca20df915 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: urgencies fk_rails_ddf6f0b8f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urgencies
    ADD CONSTRAINT fk_rails_ddf6f0b8f8 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: bank_transactions fk_rails_e0117c6727; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_transactions
    ADD CONSTRAINT fk_rails_e0117c6727 FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id);


--
-- Name: policy_disregards fk_rails_e1b3189448; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policy_disregards
    ADD CONSTRAINT fk_rails_e1b3189448 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: ccms_submissions fk_rails_e234f2a7b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ccms_submissions
    ADD CONSTRAINT fk_rails_e234f2a7b7 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: vary_orders fk_rails_e6f9592880; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vary_orders
    ADD CONSTRAINT fk_rails_e6f9592880 FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: regular_transactions fk_rails_e757ed8f88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regular_transactions
    ADD CONSTRAINT fk_rails_e757ed8f88 FOREIGN KEY (transaction_type_id) REFERENCES public.transaction_types(id);


--
-- Name: specific_issues fk_rails_ea988791a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.specific_issues
    ADD CONSTRAINT fk_rails_ea988791a1 FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: providers fk_rails_edeb683bd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT fk_rails_edeb683bd5 FOREIGN KEY (selected_office_id) REFERENCES public.offices(id);


--
-- Name: partners fk_rails_ef25ecdbee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT fk_rails_ef25ecdbee FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: statement_of_cases fk_rails_efb816a921; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statement_of_cases
    ADD CONSTRAINT fk_rails_efb816a921 FOREIGN KEY (provider_uploader_id) REFERENCES public.providers(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260116163956'),
('20260105114917'),
('20251209160131'),
('20251209151347'),
('20251209145538'),
('20251120125313'),
('20251024080229'),
('20251020101525'),
('20251008132454'),
('20250929104707'),
('20250925101154'),
('20250911153550'),
('20250827103452'),
('20250821145938'),
('20250821083605'),
('20250820112750'),
('20250812154747'),
('20250731075330'),
('20250728135041'),
('20250709140406'),
('20250707133138'),
('20250617141529'),
('20250617140126'),
('20250616134142'),
('20250616133014'),
('20250509071703'),
('20250425074840'),
('20250325114131'),
('20250313140248'),
('20250312140551'),
('20250305080311'),
('20250217150948'),
('20250217105318'),
('20250217104841'),
('20250213135157'),
('20250203164133'),
('20250124104720'),
('20250121090656'),
('20250114142619'),
('20250114135742'),
('20241212085816'),
('20241211093840'),
('20241210171604'),
('20241210160206'),
('20241209111158'),
('20241206121926'),
('20241202152952'),
('20241115143002'),
('20241107092712'),
('20241030094958'),
('20241022133251'),
('20241018081039'),
('20241018071246'),
('20241018070508'),
('20241001081701'),
('20240930074635'),
('20240923104047'),
('20240918073446'),
('20240913145848'),
('20240905104607'),
('20240722082922'),
('20240711135846'),
('20240704134837'),
('20240702132532'),
('20240627104142'),
('20240625094124'),
('20240606135347'),
('20240605105731'),
('20240603140432'),
('20240531070655'),
('20240517110634'),
('20240514091845'),
('20240510114941'),
('20240415074736'),
('20240403101554'),
('20240328152722'),
('20240306122233'),
('20240229150804'),
('20240229074123'),
('20240216110009'),
('20240215131834'),
('20240214160228'),
('20240206145546'),
('20240124161717'),
('20231205180352'),
('20231205092447'),
('20231108110820'),
('20231101111302'),
('20231020085303'),
('20231009145448'),
('20231006091714'),
('20231005161440'),
('20231005160623'),
('20231004144844'),
('20231004080150'),
('20230929072452'),
('20230918144429'),
('20230918142519'),
('20230912082919'),
('20230911120457'),
('20230905133536'),
('20230824132946'),
('20230822111710'),
('20230821163930'),
('20230821070336'),
('20230815155824'),
('20230815154938'),
('20230815072458'),
('20230807135356'),
('20230803135557'),
('20230727104111'),
('20230727083729'),
('20230725125636'),
('20230720125540'),
('20230720124309'),
('20230713083234'),
('20230711081546'),
('20230706095142'),
('20230703102937'),
('20230628085216'),
('20230619152614'),
('20230614094521'),
('20230522073818'),
('20230515130906'),
('20230505103331'),
('20230421084400'),
('20230330155942'),
('20230327134642'),
('20230321081156'),
('20230320094303'),
('20230228132829'),
('20230228112837'),
('20230226121859'),
('20230226113130'),
('20230224112243'),
('20230223154933'),
('20230221174503'),
('20230217111318'),
('20230217105228'),
('20230215161035'),
('20230215161023'),
('20230215160839'),
('20230213141824'),
('20230209145917'),
('20230208133125'),
('20230202115351'),
('20230131084513'),
('20221219133711'),
('20221201085138'),
('20221128150745'),
('20221122083958'),
('20221118095617'),
('20221118094938'),
('20221117155146'),
('20221116153344'),
('20221113212453'),
('20221110161139'),
('20221109161647'),
('20221108091755'),
('20221103164239'),
('20221102162032'),
('20221102161808'),
('20221101141154'),
('20221031111422'),
('20221027065931'),
('20221026095914'),
('20221017130541'),
('20221013114916'),
('20220928154516'),
('20220915131126'),
('20220915124637'),
('20220915104106'),
('20220902150227'),
('20220830144657'),
('20220824162240'),
('20220819090020'),
('20220818102535'),
('20220812134746'),
('20220727125202'),
('20220727075551'),
('20220713142408'),
('20220708123323'),
('20220527111338'),
('20220512125715'),
('20220510131202'),
('20220420073516'),
('20220331084008'),
('20220223141651'),
('20220223141619'),
('20220204171301'),
('20220204114732'),
('20220121103950'),
('20211223105917'),
('20211222125827'),
('20211214154807'),
('20211210144834'),
('20211209141633'),
('20211209134144'),
('20211209083010'),
('20211208161719'),
('20211202112509'),
('20211126133758'),
('20211112174848'),
('20211105083833'),
('20211104141141'),
('20211103151811'),
('20211103112548'),
('20211103105546'),
('20211102101801'),
('20211102100659'),
('20211026175246'),
('20211025135348'),
('20211020093729'),
('20211015111515'),
('20211008094831'),
('20211008094818'),
('20211004135707'),
('20210929152348'),
('20210913110123'),
('20210913102726'),
('20210901160225'),
('20210805072930'),
('20210720115125'),
('20210712112003'),
('20210624130422'),
('20210624124911'),
('20210621100811'),
('20210616092032'),
('20210602114709'),
('20210602110352'),
('20210524143755'),
('20210520071320'),
('20210518114357'),
('20210518095337'),
('20210429174354'),
('20210423180431'),
('20210421094326'),
('20210420092148'),
('20210409102038'),
('20210408162032'),
('20210407081304'),
('20210401155950'),
('20210401124219'),
('20210401124208'),
('20210324140533'),
('20210323153440'),
('20210323113558'),
('20210322122007'),
('20210319110509'),
('20210312110904'),
('20210309111908'),
('20210305145638'),
('20210305123318'),
('20210303231303'),
('20210302142433'),
('20210223134124'),
('20210222105725'),
('20210218165806'),
('20210201130345'),
('20210115155032'),
('20210115142908'),
('20210115142828'),
('20210112103855'),
('20210106155819'),
('20201215170558'),
('20201215120821'),
('20201214114039'),
('20201214114038'),
('20201210161115'),
('20201130151951'),
('20201127134906'),
('20201125195145'),
('20201125154924'),
('20201119125243'),
('20201112101449'),
('20201105112815'),
('20201102133306'),
('20201029080226'),
('20201026115759'),
('20201023220052'),
('20201023142248'),
('20201022121901'),
('20201020100508'),
('20201006122951'),
('20201005152150'),
('20200921143900'),
('20200917082925'),
('20200903165732'),
('20200813132316'),
('20200803154318'),
('20200729140115'),
('20200728081000'),
('20200724083605'),
('20200723102331'),
('20200709135901'),
('20200709112844'),
('20200708102815'),
('20200702122054'),
('20200625135809'),
('20200619123658'),
('20200616135325'),
('20200611123802'),
('20200610213903'),
('20200501103020'),
('20200501083631'),
('20200501010350'),
('20200410144915'),
('20200408135701'),
('20200327171336'),
('20200327115101'),
('20200327115015'),
('20200319152301'),
('20200310162254'),
('20200225140642'),
('20200221145049'),
('20200210162352'),
('20200207133614'),
('20200117163347'),
('20200108162334'),
('20200106113041'),
('20200106094725'),
('20191206104140'),
('20191121143142'),
('20191120104919'),
('20191118142348'),
('20191114193807'),
('20191114152212'),
('20191114151820'),
('20191025151150'),
('20191025135756'),
('20191025135501'),
('20191025134729'),
('20191018174252'),
('20191011142505'),
('20191007141353'),
('20190925105003'),
('20190925095224'),
('20190918102038'),
('20190913092309'),
('20190911150223'),
('20190909101523'),
('20190909095604'),
('20190904151326'),
('20190903092600'),
('20190828131723'),
('20190828131221'),
('20190827131229'),
('20190827122038'),
('20190823093923'),
('20190820154405'),
('20190812135413'),
('20190808094323'),
('20190806115955'),
('20190729100602'),
('20190729100046'),
('20190725130416'),
('20190725130335'),
('20190725093333'),
('20190723142637'),
('20190723142558'),
('20190723142529'),
('20190723083236'),
('20190716081338'),
('20190712133912'),
('20190711135901'),
('20190708151000'),
('20190705150936'),
('20190704160038'),
('20190704131448'),
('20190704130740'),
('20190702144049'),
('20190701120930'),
('20190628122520'),
('20190628120413'),
('20190627143244'),
('20190627074728'),
('20190617103359'),
('20190617093116'),
('20190617075535'),
('20190611134522'),
('20190611120953'),
('20190529164413'),
('20190529090545'),
('20190524143312'),
('20190524142923'),
('20190523115648'),
('20190516094442'),
('20190515141352'),
('20190514212618'),
('20190514142921'),
('20190501123416'),
('20190425143403'),
('20190425131605'),
('20190424181011'),
('20190424092935'),
('20190417130107'),
('20190405151933'),
('20190403151300'),
('20190329154206'),
('20190328155542'),
('20190326093632'),
('20190319145411'),
('20190315133344'),
('20190315113315'),
('20190313174812'),
('20190307104610'),
('20190305152510'),
('20190301141732'),
('20190301131852'),
('20190222134743'),
('20190219150642'),
('20190219134900'),
('20190219134617'),
('20190214171720'),
('20190214170843'),
('20190214143628'),
('20190208101554'),
('20190205134535'),
('20190130110634'),
('20190129120515'),
('20190128101016'),
('20190128091816'),
('20190124140446'),
('20190124135128'),
('20190124113350'),
('20190123151514'),
('20190123151412'),
('20190123111544'),
('20190122115534'),
('20190110104254'),
('20190109114728'),
('20190102151638'),
('20181214143356'),
('20181211125447'),
('20181210152857'),
('20181207162311'),
('20181207162049'),
('20181206142708'),
('20181206132736'),
('20181206100314'),
('20181205144814'),
('20181205130016'),
('20181205111854'),
('20181129140032'),
('20181126110330'),
('20181123192102'),
('20181120160942'),
('20181120154510'),
('20181113153145'),
('20181109095753'),
('20181108115540'),
('20181107110620'),
('20181107093419'),
('20181101115246'),
('20181101105424'),
('20181030114511'),
('20181018165537'),
('20181018165405'),
('20181018165257'),
('20181017202608'),
('20181011143410'),
('20180929123828'),
('20180917084624'),
('20180913103146'),
('20180913101947'),
('20180911143012'),
('20180829150801'),
('20180829144026'),
('20180821122427'),
('20180821121644'),
('20180820112730'),
('20180807211758');

