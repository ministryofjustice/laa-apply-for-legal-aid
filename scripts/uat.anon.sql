--
-- PostgreSQL database dump
--

-- Dumped from database version 11.10
-- Dumped by pg_dump version 13.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    record_id uuid NOT NULL,
    record_type character varying NOT NULL,
    blob_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
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
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    permittable_type character varying,
    permittable_id uuid,
    permission_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    address_line_one character varying,
    address_line_two character varying,
    city character varying,
    county character varying,
    postcode character varying,
    applicant_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organisation character varying,
    lookup_used boolean DEFAULT false NOT NULL,
    lookup_id character varying
);


--
-- Name: admin_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_reports (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    username character varying DEFAULT ''::character varying NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    failed_attempts integer DEFAULT 0 NOT NULL,
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: applicants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applicants (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    first_name character varying,
    date_of_birth date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_name character varying,
    email character varying,
    national_insurance_number character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    true_layer_secure_data_id character varying,
    remember_created_at timestamp without time zone,
    remember_token character varying,
    employed boolean
);


--
-- Name: application_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_digests (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    firm_name character varying NOT NULL,
    provider_username character varying NOT NULL,
    date_started date NOT NULL,
    date_submitted date,
    days_to_submission integer,
    use_ccms boolean DEFAULT false,
    matter_types character varying NOT NULL,
    proceedings character varying NOT NULL,
    passported boolean DEFAULT false,
    df_used boolean DEFAULT false,
    earliest_df_date date,
    df_reported_date date,
    working_days_to_report_df integer,
    working_days_to_submit_df integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: application_proceeding_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_proceeding_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    proceeding_type_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    proceeding_case_id integer,
    lead_proceeding boolean DEFAULT false NOT NULL,
    used_delegated_functions_on date,
    used_delegated_functions_reported_on date
);


--
-- Name: application_proceeding_types_linked_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_proceeding_types_linked_children (
    involved_child_id uuid NOT NULL,
    application_proceeding_type_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: application_proceeding_types_scope_limitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_proceeding_types_scope_limitations (
    application_proceeding_type_id uuid NOT NULL,
    scope_limitation_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    type character varying
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
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    attachment_type character varying,
    pdf_attachment_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_name character varying,
    original_filename text
);


--
-- Name: attempts_to_settles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attempts_to_settles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    attempts_made text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    application_proceeding_type_id uuid NOT NULL,
    proceeding_id uuid
);


--
-- Name: bank_account_holders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_account_holders (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bank_provider_id uuid NOT NULL,
    true_layer_response json,
    full_name character varying,
    addresses json,
    date_of_birth date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_accounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bank_provider_id uuid NOT NULL,
    true_layer_response json,
    true_layer_balance_response json,
    true_layer_id character varying,
    name character varying,
    currency character varying,
    account_number character varying,
    sort_code character varying,
    balance numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_type character varying
);


--
-- Name: bank_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_errors (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    applicant_id uuid NOT NULL,
    bank_name character varying,
    error text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_holidays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_holidays (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    dates text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_providers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    applicant_id uuid NOT NULL,
    true_layer_response json,
    credentials_id character varying,
    token character varying,
    token_expires_at timestamp without time zone,
    name character varying,
    true_layer_provider_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_transactions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bank_account_id uuid NOT NULL,
    true_layer_response json,
    true_layer_id character varying,
    description character varying,
    amount numeric,
    currency character varying,
    operation character varying,
    merchant character varying,
    happened_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    transaction_type_id uuid,
    meta_data character varying,
    running_balance numeric,
    flags json
);


--
-- Name: benefit_check_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.benefit_check_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    result character varying,
    dwp_ref character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cash_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cash_transactions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id character varying,
    amount numeric,
    transaction_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    month_number integer,
    transaction_type_id uuid
);


--
-- Name: ccms_opponent_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_opponent_ids (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    serial_id integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ccms_submission_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_submission_documents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    submission_id uuid,
    status character varying,
    document_type character varying,
    ccms_document_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_id uuid
);


--
-- Name: ccms_submission_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_submission_histories (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    submission_id uuid NOT NULL,
    from_state character varying,
    to_state character varying,
    success boolean,
    details text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    request text,
    response text
);


--
-- Name: ccms_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ccms_submissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    applicant_ccms_reference character varying,
    case_ccms_reference character varying,
    aasm_state character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    applicant_add_transaction_id character varying,
    applicant_poll_count integer DEFAULT 0,
    case_add_transaction_id character varying,
    case_poll_count integer DEFAULT 0
);


--
-- Name: cfe_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfe_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    submission_id uuid,
    result text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying DEFAULT 'CFE::V1::Result'::character varying
);


--
-- Name: cfe_submission_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfe_submission_histories (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    submission_id uuid,
    url character varying,
    http_method character varying,
    request_payload text,
    http_response_status integer,
    response_payload text,
    error_message character varying,
    error_backtrace character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cfe_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfe_submissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    assessment_id uuid,
    aasm_state character varying,
    error_message character varying,
    cfe_result text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: chances_of_successes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chances_of_successes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    application_purpose text,
    success_prospect character varying,
    success_prospect_details text,
    success_likely boolean,
    application_proceeding_type_id uuid NOT NULL,
    proceeding_id uuid
);


--
-- Name: data_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_migrations (
    version character varying NOT NULL
);


--
-- Name: debugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debugs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    debug_type character varying,
    legal_aid_application_id character varying,
    session_id character varying,
    session text,
    auth_params character varying,
    callback_params character varying,
    callback_url character varying,
    error_details character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    browser_details character varying
);


--
-- Name: default_cost_limitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.default_cost_limitations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    proceeding_type_id uuid NOT NULL,
    start_date date NOT NULL,
    cost_type character varying NOT NULL,
    value numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: dependants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dependants (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    number integer,
    name character varying,
    date_of_birth date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    relationship character varying,
    monthly_income numeric,
    has_income boolean,
    in_full_time_education boolean,
    has_assets_more_than_threshold boolean,
    assets_value numeric
);


--
-- Name: dwp_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dwp_overrides (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    passporting_benefit text,
    has_evidence_of_benefit boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    done_all_needed boolean,
    satisfaction integer,
    improvement_suggestion text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    os character varying,
    browser character varying,
    browser_version character varying,
    source character varying,
    difficulty integer,
    email character varying,
    originating_page character varying,
    legal_aid_application_id uuid
);


--
-- Name: firms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.firms (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ccms_id character varying,
    name character varying
);


--
-- Name: gateway_evidences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gateway_evidences (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    provider_uploader_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hmrc_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hmrc_responses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    submission_id character varying,
    use_case character varying,
    response json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid,
    url character varying
);


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    occurred_on date,
    details text,
    legal_aid_application_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    told_on date
);


--
-- Name: involved_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.involved_children (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    full_name character varying,
    date_of_birth date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ccms_opponent_id integer
);


--
-- Name: irregular_incomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.irregular_incomes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id character varying,
    income_type character varying,
    frequency character varying,
    amount numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: legal_aid_application_transaction_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_aid_application_transaction_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    transaction_type_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legal_aid_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_aid_applications (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    application_ref character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    applicant_id uuid,
    has_offline_accounts boolean,
    open_banking_consent boolean,
    open_banking_consent_choice_at timestamp without time zone,
    own_home character varying,
    property_value numeric(10,2),
    shared_ownership character varying,
    outstanding_mortgage_amount numeric,
    percentage_home numeric,
    provider_step character varying,
    provider_id uuid,
    draft boolean,
    transaction_period_start_on date,
    transaction_period_finish_on date,
    transactions_gathered boolean,
    completed_at timestamp without time zone,
    applicant_means_answers json,
    declaration_accepted_at timestamp without time zone,
    provider_step_params json,
    own_vehicle boolean,
    substantive_application_deadline_on date,
    substantive_application boolean,
    has_dependants boolean,
    office_id uuid,
    has_restrictions boolean,
    restrictions_details character varying,
    no_credit_transaction_types_selected boolean,
    no_debit_transaction_types_selected boolean,
    provider_received_citizen_consent boolean,
    student_finance boolean,
    discarded_at timestamp without time zone,
    merits_submitted_at timestamp without time zone,
    in_scope_of_laspo boolean,
    emergency_cost_override boolean,
    emergency_cost_requested numeric,
    emergency_cost_reasons character varying,
    no_cash_income boolean,
    no_cash_outgoings boolean,
    purgeable_on date
);


--
-- Name: legal_framework_merits_task_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_framework_merits_task_lists (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    serialized_data text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: legal_framework_submission_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_framework_submission_histories (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    submission_id uuid,
    url character varying,
    http_method character varying,
    request_payload text,
    http_response_status integer,
    response_payload text,
    error_message character varying,
    error_backtrace character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: legal_framework_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_framework_submissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    request_id uuid,
    error_message character varying,
    result text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: malware_scan_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.malware_scan_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    uploader_type character varying,
    uploader_id uuid,
    virus_found boolean NOT NULL,
    scan_result text,
    file_details json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    scanner_working boolean
);


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offices (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ccms_id character varying,
    code character varying,
    firm_id uuid
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
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    understands_terms_of_court_order boolean,
    understands_terms_of_court_order_details text,
    warning_letter_sent boolean,
    warning_letter_sent_details text,
    police_notified boolean,
    police_notified_details text,
    bail_conditions_set boolean,
    bail_conditions_set_details text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    full_name character varying,
    ccms_opponent_id integer
);


--
-- Name: other_assets_declarations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.other_assets_declarations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    second_home_value numeric,
    second_home_mortgage numeric,
    second_home_percentage numeric,
    timeshare_property_value numeric,
    land_value numeric,
    valuable_items_value numeric,
    inherited_assets_value numeric,
    money_owed_value numeric,
    trust_value numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    none_selected boolean
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    role character varying,
    description character varying
);


--
-- Name: policy_disregards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.policy_disregards (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    england_infected_blood_support boolean,
    vaccine_damage_payments boolean,
    variant_creutzfeldt_jakob_disease boolean,
    criminal_injuries_compensation_scheme boolean,
    national_emergencies_trust boolean,
    we_love_manchester_emergency_fund boolean,
    london_emergencies_trust boolean,
    none_selected boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    legal_aid_application_id uuid
);


--
-- Name: proceeding_type_scope_limitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proceeding_type_scope_limitations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    proceeding_type_id uuid,
    scope_limitation_id uuid,
    substantive_default boolean,
    delegated_functions_default boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: proceeding_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proceeding_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    code character varying,
    ccms_code character varying,
    meaning character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ccms_category_law character varying,
    ccms_category_law_code character varying,
    ccms_matter character varying,
    ccms_matter_code character varying,
    involvement_type_applicant boolean,
    additional_search_terms character varying,
    default_service_level_id uuid,
    textsearchable tsvector,
    name character varying
);


--
-- Name: proceedings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proceedings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    proceeding_case_id integer,
    lead_proceeding boolean DEFAULT false NOT NULL,
    ccms_code character varying NOT NULL,
    meaning character varying NOT NULL,
    description character varying NOT NULL,
    substantive_cost_limitation numeric NOT NULL,
    delegated_functions_cost_limitation numeric NOT NULL,
    substantive_scope_limitation_code character varying NOT NULL,
    substantive_scope_limitation_meaning character varying NOT NULL,
    substantive_scope_limitation_description character varying NOT NULL,
    delegated_functions_scope_limitation_code character varying NOT NULL,
    delegated_functions_scope_limitation_meaning character varying NOT NULL,
    delegated_functions_scope_limitation_description character varying NOT NULL,
    used_delegated_functions_on date,
    used_delegated_functions_reported_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL,
    matter_type character varying NOT NULL,
    category_of_law character varying NOT NULL,
    category_law_code character varying NOT NULL,
    ccms_matter_code character varying
);


--
-- Name: proceedings_linked_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proceedings_linked_children (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    proceeding_id uuid,
    involved_child_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.providers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    username character varying NOT NULL,
    type character varying,
    roles text,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    office_codes text,
    firm_id uuid,
    selected_office_id uuid,
    name character varying,
    email character varying,
    portal_enabled boolean DEFAULT true,
    contact_id integer,
    invalid_login_details character varying
);


--
-- Name: savings_amounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.savings_amounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    offline_current_accounts numeric,
    cash numeric,
    other_person_account numeric,
    national_savings numeric,
    plc_shares numeric,
    peps_unit_trusts_capital_bonds_gov_stocks numeric,
    life_assurance_endowment_policy numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    none_selected boolean,
    offline_savings_accounts numeric,
    no_account_selected boolean
);


--
-- Name: scheduled_mailings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_mailings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    mailer_klass character varying NOT NULL,
    mailer_method character varying NOT NULL,
    arguments character varying NOT NULL,
    scheduled_at timestamp without time zone NOT NULL,
    sent_at timestamp without time zone,
    cancelled_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying,
    addressee character varying,
    govuk_message_id character varying
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
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    code character varying,
    meaning character varying,
    description character varying,
    substantive boolean DEFAULT false,
    delegated_functions boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: secure_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secure_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: service_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_levels (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    service_level_number integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mock_true_layer_data boolean DEFAULT false NOT NULL,
    manually_review_all_cases boolean DEFAULT true,
    bank_transaction_filename character varying DEFAULT 'db/sample_data/bank_transactions.csv'::character varying,
    allow_welsh_translation boolean DEFAULT false NOT NULL,
    enable_ccms_submission boolean DEFAULT true NOT NULL,
    alert_via_sentry boolean DEFAULT true NOT NULL,
    digest_extracted_at timestamp without time zone DEFAULT '1970-01-01 00:00:01'::timestamp without time zone,
    enable_employed_journey boolean DEFAULT false NOT NULL
);


--
-- Name: state_machine_proxies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_machine_proxies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid,
    type character varying,
    aasm_state character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ccms_reason character varying
);


--
-- Name: statement_of_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statement_of_cases (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legal_aid_application_id uuid NOT NULL,
    statement text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider_uploader_id uuid
);


--
-- Name: transaction_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    operation character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sort_order integer,
    archived_at timestamp without time zone,
    other_income boolean DEFAULT false,
    parent_id character varying
);


--
-- Name: true_layer_banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.true_layer_banks (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    banks text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    estimated_value numeric,
    payment_remaining numeric,
    purchased_on date,
    used_regularly boolean,
    legal_aid_application_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    more_than_three_years_old boolean
);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_attachments (id, name, record_id, record_type, blob_id, created_at) FROM stdin;
0cd6b6ef-e0f5-46ef-ba43-f7b3be8741e6	document	9ec2c014-0176-4346-91ae-65207d6a52e3	Attachment	aada768b-2509-423a-8171-c9df98a56da6	2021-11-30 16:57:23.593469
c4f3fadd-405d-438f-a524-5d89effb76dd	document	98604005-7d29-4659-9a0d-3c40b7020916	Attachment	fd5aef2a-4555-4b47-8497-b41252f4f193	2021-11-30 16:57:24.437296
d7bfa01f-920a-4ae4-b332-eff75743c047	document	08b980d4-bd61-4938-8dae-5009aed9cc6b	Attachment	beea6761-9d61-44de-bb4f-452e3ee3f9d3	2021-11-30 17:39:37.782454
b99f5702-317a-46b8-9b05-39176405a1cf	document	00842915-7223-4984-86cd-d7e02f64c8e9	Attachment	1a3afb0d-c401-4162-8106-59f175cafb1f	2021-11-30 17:39:38.506776
d965ac40-ffd7-4852-b8ae-7a2555f61088	submitted_applications	bcc4a95f-c60d-4218-a05f-63958b1b2be1	AdminReport	f62ba037-fe77-4afb-a218-0fef624dcc40	2021-12-01 20:00:54.800404
abfd653d-2779-49df-89fc-aa421c8c3a39	non_passported_applications	bcc4a95f-c60d-4218-a05f-63958b1b2be1	AdminReport	b4c0c398-4431-46ef-83fe-f54040994f97	2021-12-01 20:01:02.717289
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, byte_size, checksum, created_at, service_name) FROM stdin;
ac29f2b4-5af4-49ef-afea-b55e3cf76279	xroluacqa16sk9v0du6szix925ri	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	1513	ButxZHkkOIvxAAEaLGBGcQ==	2021-11-19 20:00:38.098658	amazon
e3a9e662-520e-474e-a1fb-ba6f66838921	5vqngk1ga0c4fucpunv909xlp1fa	non_passported_applications_report	text/csv	{"identified":true,"analyzed":true}	91	+wVwxkuVobWWjqMkmRm7Qw==	2021-11-19 20:00:46.092846	amazon
a71258eb-c3c4-4d1c-b96c-82dae902ed9f	j73wk04b4drwfkqttjb0556s7vr5	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	1513	ButxZHkkOIvxAAEaLGBGcQ==	2021-11-20 20:00:38.834978	amazon
40f05552-abc7-4ac5-badc-a04e8329e447	6qap0oh6zbjl6thz2ow7yq49l862	non_passported_applications_report	text/csv	{"identified":true,"analyzed":true}	91	+wVwxkuVobWWjqMkmRm7Qw==	2021-11-20 20:00:46.658986	amazon
6566f660-8c3a-49e4-8c8e-969c0afa62df	isfqv16s3o4gmu71h8jrgk6x5re2	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	1513	ButxZHkkOIvxAAEaLGBGcQ==	2021-11-21 20:00:46.803429	amazon
13d524d0-737e-4660-a508-19d927129351	i9kase1svuobp4doue15ja5i11xh	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	1513	ButxZHkkOIvxAAEaLGBGcQ==	2021-11-22 20:00:42.018565	amazon
99bf2293-ce6a-43c7-b16e-f38e8f691ddd	32glin7w87p9r5cfv56msgccfvkf	non_passported_applications_report	text/csv	{"identified":true,"analyzed":true}	91	+wVwxkuVobWWjqMkmRm7Qw==	2021-11-22 20:00:49.792312	amazon
36348032-08f0-49ef-9f39-8fef03004248	g492mujff0nl1cb29vx2877i91dl	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	1513	ButxZHkkOIvxAAEaLGBGcQ==	2021-11-23 20:00:39.998265	amazon
221af6eb-92bd-4d06-9730-f77d0fe9b4af	3d7i732fl29pp17sbz9h5jtt804l	non_passported_applications_report	text/csv	{"identified":true,"analyzed":true}	91	+wVwxkuVobWWjqMkmRm7Qw==	2021-11-23 20:00:48.090864	amazon
bc377f57-9d68-4963-90c1-f7bfe3e0c59e	08xbswqxa0w6kzrpbex89y24oxia	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	1513	ButxZHkkOIvxAAEaLGBGcQ==	2021-11-25 20:00:52.282998	amazon
70d07e14-f89d-46ba-b64d-d021bbff6ccf	vr9nhm1oba6yauae700rlbgi0gwl	non_passported_applications_report	text/csv	{"identified":true,"analyzed":true}	91	+wVwxkuVobWWjqMkmRm7Qw==	2021-11-25 20:00:59.969896	amazon
aada768b-2509-423a-8171-c9df98a56da6	8k7mlcnlvdjqxa94fr0k99vxul9f	merits_report.pdf	application/pdf	{"identified":true,"analyzed":true}	23321	dqmft4Vjtz5JFKywuvjMcg==	2021-11-30 16:57:23.591281	amazon
fd5aef2a-4555-4b47-8497-b41252f4f193	qoefem2bpjixyr14bxg3fpcylybi	means_report.pdf	application/pdf	{"identified":true,"analyzed":true}	25271	HyqkzD5uCc77XztxyasVZA==	2021-11-30 16:57:24.435188	amazon
beea6761-9d61-44de-bb4f-452e3ee3f9d3	4sp587aol3dwdt1fptt8p1dh774b	merits_report.pdf	application/pdf	{"identified":true,"analyzed":true}	22728	MMouJOY7llTCGfi8S1yxdg==	2021-11-30 17:39:37.719775	amazon
1a3afb0d-c401-4162-8106-59f175cafb1f	mi9x7mk35ui6ubb3dfreyg3tl3fn	means_report.pdf	application/pdf	{"identified":true,"analyzed":true}	25147	b0ZsUn76BqzmMOT3eBjkeA==	2021-11-30 17:39:38.504676	amazon
f62ba037-fe77-4afb-a218-0fef624dcc40	kbebj5g2ce5cnwfbddjtmpkt2km2	submitted_applications_report	text/csv	{"identified":true,"analyzed":true}	2321	7V4jAfulwRJGPK4rMYfZMg==	2021-12-01 20:00:54.797688	amazon
b4c0c398-4431-46ef-83fe-f54040994f97	6br0k2zuq5214fivdmdhwopsyu1h	non_passported_applications_report	text/csv	{"identified":true,"analyzed":true}	91	+wVwxkuVobWWjqMkmRm7Qw==	2021-12-01 20:01:02.715698	amazon
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
\.


--
-- Data for Name: actor_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.actor_permissions (id, permittable_type, permittable_id, permission_id, created_at, updated_at) FROM stdin;
e93c631a-8c67-4315-974d-ffcbea36767a	Firm	089b56d1-ac17-4b88-9ba5-3ac5d93b02cc	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.45507	2021-11-19 14:20:43.45507
64298775-abe8-4f98-8f05-f1ac2aa98112	Firm	6759bf9c-bd38-4d47-a3a3-70e129cc1313	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.525318	2021-11-19 14:20:43.525318
bb92113a-7314-4fea-8cd1-85e7af59c453	Firm	e8400967-3132-4349-bf1f-09e4a3536693	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.559529	2021-11-19 14:20:43.559529
9ead8fa7-43cc-48be-99c7-c980f076f2df	Firm	df03f1e9-f320-48f5-b874-d2744778be9a	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.604089	2021-11-19 14:20:43.604089
45aa3780-2904-482b-bcc9-bccf0771c73b	Firm	41e3a512-0212-4f63-8e61-6f562538e572	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.64246	2021-11-19 14:20:43.64246
04eb1afa-a089-474c-be70-006e30113ba0	Firm	db82bef2-344e-4415-bd82-82142db3746b	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.680463	2021-11-19 14:20:43.680463
51c3f744-d064-4f2b-b0cc-fedef37a4544	Firm	9547a213-a284-4084-92a1-267d69ceba91	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.739909	2021-11-19 14:20:43.739909
3a0edeea-cea1-4661-8396-599be86d1ed2	Firm	33603414-b491-4115-be44-b20a0387a8be	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.773858	2021-11-19 14:20:43.773858
5e7c9c39-bdf8-44ca-8807-06457089a086	Firm	73d33890-8f61-4cfa-9047-e2d572949707	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.80682	2021-11-19 14:20:43.80682
6f7ab938-12b0-4522-b784-655d0174f32f	Firm	f2cc38bb-e623-4412-979f-7861cf3ca2f9	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.837102	2021-11-19 14:20:43.837102
fcd902a5-d42f-4508-893b-6589bb7dbd11	Firm	fdfbd521-1e36-44bb-bc2b-d0835f0dea66	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.920478	2021-11-19 14:20:43.920478
88a9f979-872e-4232-b44f-2e915c6358a1	Firm	a6dcda91-7e51-4ba6-86c7-2696cab7c6b2	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.953503	2021-11-19 14:20:43.953503
53682118-c883-4d0d-b7a8-14b6826a1e8e	Firm	78c02d96-62be-4bfb-b86d-6cf290457cbf	43c8ada8-9d87-4cd7-b74f-7d502730dee4	2021-11-19 14:20:43.982827	2021-11-19 14:20:43.982827
4f6a226e-7487-4134-988a-2cbefae0fc84	Firm	089b56d1-ac17-4b88-9ba5-3ac5d93b02cc	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.010962	2021-11-19 14:20:44.010962
224623ac-30b4-4bb8-8d62-7ae64b342936	Firm	6759bf9c-bd38-4d47-a3a3-70e129cc1313	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.019864	2021-11-19 14:20:44.019864
bf2efc7c-596f-4828-b8be-b1db221ec5e4	Firm	e8400967-3132-4349-bf1f-09e4a3536693	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.02854	2021-11-19 14:20:44.02854
81cd1ca3-3940-4d0a-abac-57e0e98c8045	Firm	df03f1e9-f320-48f5-b874-d2744778be9a	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.03676	2021-11-19 14:20:44.03676
f4ea244e-443d-425e-b5a4-44557cf05b01	Firm	41e3a512-0212-4f63-8e61-6f562538e572	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.045276	2021-11-19 14:20:44.045276
8261b696-309e-4904-bd1e-bfbe08d8006e	Firm	db82bef2-344e-4415-bd82-82142db3746b	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.053146	2021-11-19 14:20:44.053146
584e84c9-38dd-4360-88ad-3ec661482758	Firm	9547a213-a284-4084-92a1-267d69ceba91	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.06095	2021-11-19 14:20:44.06095
bdd29e67-ac05-4161-8a4a-40fb1f915e32	Firm	33603414-b491-4115-be44-b20a0387a8be	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.06857	2021-11-19 14:20:44.06857
e5089a0c-ad29-4983-bb1b-4c114f2b0eba	Firm	73d33890-8f61-4cfa-9047-e2d572949707	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.076264	2021-11-19 14:20:44.076264
e8a46038-25a2-44d7-93ea-f2015b8ae4a1	Firm	f2cc38bb-e623-4412-979f-7861cf3ca2f9	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.083856	2021-11-19 14:20:44.083856
c88a8103-0a7d-4718-9d6c-630bc90c512b	Firm	fdfbd521-1e36-44bb-bc2b-d0835f0dea66	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.091561	2021-11-19 14:20:44.091561
289c095a-4910-4c8d-911e-6da13c18f709	Firm	a6dcda91-7e51-4ba6-86c7-2696cab7c6b2	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.099072	2021-11-19 14:20:44.099072
85cebcaf-c8e8-416e-96cc-ec521bac8a10	Firm	78c02d96-62be-4bfb-b86d-6cf290457cbf	bfd407a2-88a7-4967-8037-1bba8a7eb067	2021-11-19 14:20:44.106725	2021-11-19 14:20:44.106725
\.


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.addresses (id, address_line_one, address_line_two, city, county, postcode, applicant_id, created_at, updated_at, organisation, lookup_used, lookup_id) FROM stdin;
7eb0b6af-6d82-410c-822c-1242cae8d456	4183 Hane Manor	\N	Denesikfort	Lloydborough	56456	ea027fd1-0132-4bc4-9ff3-4620245acbbd	2021-11-29 14:27:42.193076	2021-11-29 14:27:44.665238	\N	t	2190532
1c586bdc-7d4c-4b7a-bcc4-f38c0be39bcc	520 Littel Parks	\N	McCulloughland	West Dennyshire	34153-3312	98aa089f-577e-4c91-b62b-82bd9004e130	2021-11-30 16:55:45.009999	2021-11-30 16:55:47.021717	\N	t	51083189
c9ac4e65-a1ac-4fa0-abd0-3f53c99c3fba	27458 Rowe Walk	\N	West Collinmouth	South Jacquie	51010-7808	d1d0179e-d769-4bf5-999f-78a8573e73d2	2021-11-30 17:37:42.182922	2021-11-30 17:37:44.090252	\N	t	51083189
\.


--
-- Data for Name: admin_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_reports (id, created_at, updated_at) FROM stdin;
bcc4a95f-c60d-4218-a05f-63958b1b2be1	2021-11-19 20:00:37.185621	2021-12-01 20:01:02.718739
\.


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_users (id, username, email, encrypted_password, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, failed_attempts, locked_at, created_at, updated_at) FROM stdin;
4066bc18-5307-4f30-9214-7dbfc6e3ed14	stacee	kirby_wiegand@wolff-stroman.com	$2a$11$PNGJbBRrpjaV1WO6q57qaOh53sk/UvvcQDm0OA70Ma0JWQxdpgRRG	2	2021-12-01 08:27:42.949769	2021-11-30 17:58:04.112747	81.134.202.29	81.134.202.29	0	\N	2021-11-19 14:20:31.623887	2021-12-01 08:27:42.950113
\.


--
-- Data for Name: applicants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.applicants (id, first_name, date_of_birth, created_at, updated_at, last_name, email, national_insurance_number, confirmation_token, confirmed_at, confirmation_sent_at, failed_attempts, unlock_token, locked_at, true_layer_secure_data_id, remember_created_at, remember_token, employed) FROM stdin;
ea027fd1-0132-4bc4-9ff3-4620245acbbd	Torri	1958-09-15	2021-11-29 14:27:39.622447	2021-11-29 14:27:39.622447	Labadie	providencia_bechtelar@rath.info	SE155949C	\N	\N	\N	0	\N	\N	\N	\N	\N	\N
98aa089f-577e-4c91-b62b-82bd9004e130	Jenniffer	1978-04-06	2021-11-30 16:55:39.133086	2021-11-30 16:55:39.133086	Kessler	matt_mraz@turcotte-stamm.co	XY588811C	\N	\N	\N	0	\N	\N	\N	\N	\N	\N
d1d0179e-d769-4bf5-999f-78a8573e73d2	Emory	1967-01-26	2021-11-30 17:37:39.430436	2021-11-30 17:38:35.078846	Hilll	arlie@cartwright.org	KB468693F	\N	\N	\N	0	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: application_digests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_digests (id, legal_aid_application_id, firm_name, provider_username, date_started, date_submitted, days_to_submission, use_ccms, matter_types, proceedings, passported, df_used, earliest_df_date, df_reported_date, working_days_to_report_df, working_days_to_submit_df, created_at, updated_at) FROM stdin;
0ac32eb0-de12-45fa-abc4-a12c8e5bb8ad	bf37635d-8cf5-4a8a-8e59-76480b91d2bc	David Gray LLP	MARTIN.RONAN@DAVIDGRAY.CO.UK	2021-11-29	\N	\N	f	Domestic Abuse	DA004	f	t	2021-07-31	2021-11-29	85	\N	2021-11-30 02:00:47.397182	2021-11-30 02:00:47.397182
7055015c-cefb-45b3-ad25-41017084bd3a	db61619d-b102-4781-aaaa-fce80d065aeb	Test & Co	test1	2021-11-30	2021-11-30	1	f	Domestic Abuse	DA004	t	t	2021-11-01	2021-11-30	22	\N	2021-12-01 02:00:47.907743	2021-12-01 02:00:47.907743
86350f47-8381-487a-8f06-7dd2fa4ed0aa	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	David Gray LLP	MARTIN.RONAN@DAVIDGRAY.CO.UK	2021-11-30	2021-11-30	1	f	Domestic Abuse	DA004	t	t	2021-11-30	2021-11-30	1	\N	2021-12-01 02:00:48.089846	2021-12-01 02:00:48.089846
\.


--
-- Data for Name: application_proceeding_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_proceeding_types (id, legal_aid_application_id, proceeding_type_id, created_at, updated_at, proceeding_case_id, lead_proceeding, used_delegated_functions_on, used_delegated_functions_reported_on) FROM stdin;
570cb01f-cc0c-49aa-9590-27b867dd0881	bf37635d-8cf5-4a8a-8e59-76480b91d2bc	c24c47cb-8e99-4061-8931-b6faa96a8cd3	2021-11-29 14:27:50.859912	2021-11-29 14:28:42.426328	55000001	t	2021-07-31	2021-11-29
ea23e24a-52c4-48f0-9848-7ceabc0cad07	db61619d-b102-4781-aaaa-fce80d065aeb	c24c47cb-8e99-4061-8931-b6faa96a8cd3	2021-11-30 16:55:59.920704	2021-11-30 16:56:09.757134	55000002	t	2021-11-01	2021-11-30
207939d3-3b7a-4993-b347-1bf8a7dce97f	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	c24c47cb-8e99-4061-8931-b6faa96a8cd3	2021-11-30 17:37:49.422205	2021-11-30 17:37:59.989522	55000003	t	2021-11-30	2021-11-30
\.


--
-- Data for Name: application_proceeding_types_linked_children; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_proceeding_types_linked_children (involved_child_id, application_proceeding_type_id, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: application_proceeding_types_scope_limitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_proceeding_types_scope_limitations (application_proceeding_type_id, scope_limitation_id, id, created_at, updated_at, type) FROM stdin;
570cb01f-cc0c-49aa-9590-27b867dd0881	88b81660-1261-4a8a-857e-316a177f8d0f	d406897f-0357-4add-981b-a09b4a7db466	2021-11-29 14:27:50.981636	2021-11-29 14:27:50.981636	AssignedSubstantiveScopeLimitation
570cb01f-cc0c-49aa-9590-27b867dd0881	fd47c785-5d3e-4f26-881e-4133f3ae4d88	9935afac-739e-4ae9-90a9-80cf9806a793	2021-11-29 14:28:42.461504	2021-11-29 14:28:42.461504	AssignedDfScopeLimitation
ea23e24a-52c4-48f0-9848-7ceabc0cad07	88b81660-1261-4a8a-857e-316a177f8d0f	dbfd60b6-18a0-4291-a8a5-b56102299a2b	2021-11-30 16:56:00.059017	2021-11-30 16:56:00.059017	AssignedSubstantiveScopeLimitation
ea23e24a-52c4-48f0-9848-7ceabc0cad07	fd47c785-5d3e-4f26-881e-4133f3ae4d88	b0d344b3-c9d5-4e41-b366-1b12cc79017b	2021-11-30 16:56:09.792784	2021-11-30 16:56:09.792784	AssignedDfScopeLimitation
207939d3-3b7a-4993-b347-1bf8a7dce97f	88b81660-1261-4a8a-857e-316a177f8d0f	bc6f2bf6-b8a4-4fdd-b419-14419b683449	2021-11-30 17:37:49.47279	2021-11-30 17:37:49.47279	AssignedSubstantiveScopeLimitation
207939d3-3b7a-4993-b347-1bf8a7dce97f	fd47c785-5d3e-4f26-881e-4133f3ae4d88	1905235b-72d9-484e-a16f-f352ca84264e	2021-11-30 17:38:00.023263	2021-11-30 17:38:00.023263	AssignedDfScopeLimitation
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	production	2021-11-19 14:20:12.274618	2021-11-19 14:20:12.274618
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attachments (id, legal_aid_application_id, attachment_type, pdf_attachment_id, created_at, updated_at, attachment_name, original_filename) FROM stdin;
9ec2c014-0176-4346-91ae-65207d6a52e3	db61619d-b102-4781-aaaa-fce80d065aeb	merits_report	\N	2021-11-30 16:57:21.793365	2021-11-30 16:57:23.595493	merits_report.pdf	\N
98604005-7d29-4659-9a0d-3c40b7020916	db61619d-b102-4781-aaaa-fce80d065aeb	means_report	\N	2021-11-30 16:57:23.720392	2021-11-30 16:57:24.43917	means_report.pdf	\N
08b980d4-bd61-4938-8dae-5009aed9cc6b	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	merits_report	\N	2021-11-30 17:39:36.536038	2021-11-30 17:39:37.784809	merits_report.pdf	\N
00842915-7223-4984-86cd-d7e02f64c8e9	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	means_report	\N	2021-11-30 17:39:37.922916	2021-11-30 17:39:38.508637	means_report.pdf	\N
\.


--
-- Data for Name: attempts_to_settles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attempts_to_settles (id, attempts_made, created_at, updated_at, application_proceeding_type_id, proceeding_id) FROM stdin;
\.


--
-- Data for Name: bank_account_holders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_account_holders (id, bank_provider_id, true_layer_response, full_name, addresses, date_of_birth, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: bank_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_accounts (id, bank_provider_id, true_layer_response, true_layer_balance_response, true_layer_id, name, currency, account_number, sort_code, balance, created_at, updated_at, account_type) FROM stdin;
\.


--
-- Data for Name: bank_errors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_errors (id, applicant_id, bank_name, error, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: bank_holidays; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_holidays (id, dates, created_at, updated_at) FROM stdin;
0ff7b7b6-2186-4804-be35-c333e72dd6ad	---\n- '2016-01-01'\n- '2016-03-25'\n- '2016-03-28'\n- '2016-05-02'\n- '2016-05-30'\n- '2016-08-29'\n- '2016-12-26'\n- '2016-12-27'\n- '2017-01-02'\n- '2017-04-14'\n- '2017-04-17'\n- '2017-05-01'\n- '2017-05-29'\n- '2017-08-28'\n- '2017-12-25'\n- '2017-12-26'\n- '2018-01-01'\n- '2018-03-30'\n- '2018-04-02'\n- '2018-05-07'\n- '2018-05-28'\n- '2018-08-27'\n- '2018-12-25'\n- '2018-12-26'\n- '2019-01-01'\n- '2019-04-19'\n- '2019-04-22'\n- '2019-05-06'\n- '2019-05-27'\n- '2019-08-26'\n- '2019-12-25'\n- '2019-12-26'\n- '2020-01-01'\n- '2020-04-10'\n- '2020-04-13'\n- '2020-05-08'\n- '2020-05-25'\n- '2020-08-31'\n- '2020-12-25'\n- '2020-12-28'\n- '2021-01-01'\n- '2021-04-02'\n- '2021-04-05'\n- '2021-05-03'\n- '2021-05-31'\n- '2021-08-30'\n- '2021-12-27'\n- '2021-12-28'\n- '2022-01-03'\n- '2022-04-15'\n- '2022-04-18'\n- '2022-05-02'\n- '2022-06-02'\n- '2022-06-03'\n- '2022-08-29'\n- '2022-12-26'\n- '2022-12-27'\n	2021-11-29 14:28:42.511861	2021-11-29 14:28:42.511861
\.


--
-- Data for Name: bank_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_providers (id, applicant_id, true_layer_response, credentials_id, token, token_expires_at, name, true_layer_provider_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: bank_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_transactions (id, bank_account_id, true_layer_response, true_layer_id, description, amount, currency, operation, merchant, happened_at, created_at, updated_at, transaction_type_id, meta_data, running_balance, flags) FROM stdin;
\.


--
-- Data for Name: benefit_check_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.benefit_check_results (id, legal_aid_application_id, result, dwp_ref, created_at, updated_at) FROM stdin;
80bc6ca6-99a5-44ab-9ce6-57d916106e37	db61619d-b102-4781-aaaa-fce80d065aeb	Yes	T1638291390806	2021-11-30 16:56:30.830382	2021-11-30 16:56:30.834493
dc43b882-6a07-4d2a-bbc9-d895df1adc28	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	Yes	T1638293917112	2021-11-30 17:38:05.552674	2021-11-30 17:38:37.129602
\.


--
-- Data for Name: cash_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cash_transactions (id, legal_aid_application_id, amount, transaction_date, created_at, updated_at, month_number, transaction_type_id) FROM stdin;
\.


--
-- Data for Name: ccms_opponent_ids; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ccms_opponent_ids (id, serial_id, created_at, updated_at) FROM stdin;
1d514e79-5c13-46f3-9d93-6629c9a76b57	88000001	2021-11-30 17:40:13.327903	2021-11-30 17:40:13.327903
\.


--
-- Data for Name: ccms_submission_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ccms_submission_documents (id, submission_id, status, document_type, ccms_document_id, created_at, updated_at, attachment_id) FROM stdin;
bced7a65-6fa5-4bf6-8057-3978eb2f5e54	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	uploaded	merits_report	22888686	2021-11-30 17:40:11.691002	2021-11-30 17:40:40.566646	08b980d4-bd61-4938-8dae-5009aed9cc6b
2a38315b-04e6-4a28-91a1-4472688b09cd	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	uploaded	means_report	22888688	2021-11-30 17:40:11.782351	2021-11-30 17:40:40.996238	00842915-7223-4984-86cd-d7e02f64c8e9
\.


--
-- Data for Name: ccms_submission_histories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ccms_submission_histories (id, submission_id, from_state, to_state, success, details, created_at, updated_at, request, response) FROM stdin;
f57cc965-baf1-4fc7-8317-627a1749a26b	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	initialised	case_ref_obtained	t	\N	2021-11-30 16:57:22.451785	2021-11-30 16:57:22.451785	\N	\N
4cc07523-d871-4ce5-86eb-016fc94fe0ae	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	case_ref_obtained	case_ref_obtained	t	\N	2021-11-30 16:57:25.911524	2021-11-30 16:57:25.911524	\N	\N
7b2f45f4-3cb3-49ae-8ea2-0f9f3377254d	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	case_ref_obtained	applicant_submitted	t	\N	2021-11-30 16:57:26.22171	2021-11-30 16:57:26.22171	\N	\N
536536b3-eba1-46eb-acc2-5b32a6b2a636	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 16:58:09.106955	2021-11-30 16:58:09.106955	\N	\N
4fb60a8e-3ef6-4751-aa77-b6ff769c0bbd	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 17:01:01.752438	2021-11-30 17:01:01.752438	\N	\N
904afd84-9892-403d-99c1-f82f3aab1764	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 17:06:19.946476	2021-11-30 17:06:19.946476	\N	\N
9b1bc31c-3e67-4ece-9006-7baf72716c82	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 17:39:23.437198	2021-11-30 17:39:23.437198	\N	\N
cfc5d91d-0310-4cf5-a6bd-6638e56ae3e9	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	initialised	case_ref_obtained	t	\N	2021-11-30 17:39:36.967822	2021-11-30 17:39:36.967822	\N	\N
a5776f1e-505c-4479-8674-3d5def2c4f42	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_ref_obtained	case_ref_obtained	t	\N	2021-11-30 17:39:45.850382	2021-11-30 17:39:45.850382	\N	\N
fcd4f47b-b997-4cb7-b071-e9ff8c5f939b	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_ref_obtained	applicant_submitted	t	\N	2021-11-30 17:39:46.094996	2021-11-30 17:39:46.094996	\N	\N
1cf6b6f8-42a0-4290-b8fd-96c667811819	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	applicant_submitted	applicant_submitted	t	\N	2021-11-30 17:39:46.951552	2021-11-30 17:39:46.951552	\N	\N
9f38c90c-5325-4df0-8621-674816cda8f9	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	applicant_submitted	applicant_ref_obtained	t	\N	2021-11-30 17:40:11.555136	2021-11-30 17:40:11.555136	\N	\N
b3e33474-94b5-495e-929e-fbf3dd58c638	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	applicant_ref_obtained	document_ids_obtained	t	\N	2021-11-30 17:40:12.544412	2021-11-30 17:40:12.544412	\N	\N
0ca9822d-05ba-43d6-a235-2745a0629b07	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	applicant_ref_obtained	document_ids_obtained	t	\N	2021-11-30 17:40:13.153157	2021-11-30 17:40:13.153157	\N	\N
99367fc3-bfd8-40f2-9769-ba6bf8bc2290	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	document_ids_obtained	case_submitted	t	\N	2021-11-30 17:40:13.986516	2021-11-30 17:40:13.986516	\N	\N
8cf11d11-e02b-4fa0-859b-24c66d70ec26	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_submitted	case_submitted	t	\N	2021-11-30 17:40:14.582798	2021-11-30 17:40:14.582798	\N	\N
e1d729b1-8d21-4b47-bca5-f50730351df7	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_submitted	case_created	t	\N	2021-11-30 17:40:40.030312	2021-11-30 17:40:40.030312	\N	\N
4e246eaf-bc9d-4e45-a021-052a80dda93e	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_created	uploaded	t	\N	2021-11-30 17:40:40.579759	2021-11-30 17:40:40.579759	\N	\N
368d7ac0-9439-4625-af27-9df951162827	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_created	uploaded	t	\N	2021-11-30 17:40:41.009584	2021-11-30 17:40:41.009584	\N	\N
6c7ad215-9180-4584-857b-62af743936c4	7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	case_created	completed	t	\N	2021-11-30 17:40:41.033895	2021-11-30 17:40:41.033895	\N	\N
0d0d55b5-cae8-4cfd-8f8d-c4488fde86ab	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 18:20:33.851167	2021-11-30 18:20:33.851167	\N	\N
cfcb6ca8-adaf-47fa-b540-9a13f0abd145	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 19:29:18.086818	2021-11-30 19:29:18.086818	\N	\N
f4f89fcf-6db0-444e-b076-350a5510bd14	dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	applicant_submitted	applicant_submitted	t	\N	2021-11-30 21:19:04.44896	2021-11-30 21:19:04.44896	\N	\N
\.


--
-- Data for Name: ccms_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ccms_submissions (id, legal_aid_application_id, applicant_ccms_reference, case_ccms_reference, aasm_state, created_at, updated_at, applicant_add_transaction_id, applicant_poll_count, case_add_transaction_id, case_poll_count) FROM stdin;
7274ee17-1f2e-45a9-9faf-e35f77f2eb2d	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	63072047	300001339394	completed	2021-11-30 17:39:36.592387	2021-11-30 17:40:41.025535	202111301739458566004005881	2	202111301740132774289268328	2
dd8ffb6f-9d92-4f5b-b6e4-f7a766273fd2	db61619d-b102-4781-aaaa-fce80d065aeb	\N	300001339374	applicant_submitted	2021-11-30 16:57:21.898372	2021-11-30 21:19:02.596723	202111301657259188036576292	7	\N	0
\.


--
-- Data for Name: cfe_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cfe_results (id, legal_aid_application_id, submission_id, result, created_at, updated_at, type) FROM stdin;
c6185a1b-77bb-49d8-9f76-cd5df509ed46	db61619d-b102-4781-aaaa-fce80d065aeb	0d7e35b4-5cea-44ca-9697-f15df20e2841	\N	2021-11-30 16:56:55.621338	2021-11-30 16:56:55.621338	CFE::V4::Result
7d5fe266-f4b2-452e-ab1c-b9c5b2517406	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	\N	2021-11-30 17:38:59.755395	2021-11-30 17:38:59.755395	CFE::V4::Result
\.


--
-- Data for Name: cfe_submission_histories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cfe_submission_histories (id, submission_id, url, http_method, request_payload, http_response_status, response_payload, error_message, error_backtrace, created_at, updated_at) FROM stdin;
70583732-3458-41b1-96b3-b59fe9a4b196	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments	POST	\N	200	\N	\N	\N	2021-11-30 16:56:54.722419	2021-11-30 16:56:54.722419
5c8a7388-e8fa-4c62-9c37-d84bfb0b8d96	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/4b4580de-d580-473d-b9a5-b40258413b57/applicant	POST	\N	200	\N	\N	\N	2021-11-30 16:56:54.859516	2021-11-30 16:56:54.859516
828306ef-4071-4360-a7a6-fcdef11d438d	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/4b4580de-d580-473d-b9a5-b40258413b57/capitals	POST	\N	200	\N	\N	\N	2021-11-30 16:56:54.913357	2021-11-30 16:56:54.913357
34fda693-4e4b-4c52-b26b-45363639489b	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/4b4580de-d580-473d-b9a5-b40258413b57/vehicles	POST	\N	200	\N	\N	\N	2021-11-30 16:56:54.98812	2021-11-30 16:56:54.98812
d886a724-ff0e-4703-a3cc-d89ded36d1d3	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/4b4580de-d580-473d-b9a5-b40258413b57/properties	POST	\N	200	\N	\N	\N	2021-11-30 16:56:55.108383	2021-11-30 16:56:55.108383
4b247a6b-0518-434a-8d4a-28f0a467298e	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/4b4580de-d580-473d-b9a5-b40258413b57/explicit_remarks	POST	\N	200	\N	\N	\N	2021-11-30 16:56:55.153369	2021-11-30 16:56:55.153369
b1fa3e3a-7514-465d-b358-0cc8fb5ecb0f	0d7e35b4-5cea-44ca-9697-f15df20e2841	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/4b4580de-d580-473d-b9a5-b40258413b57	GET	\N	200	\N	\N	\N	2021-11-30 16:56:55.595274	2021-11-30 16:56:55.595274
2e5c2f21-5778-4f00-8cd2-0e99fdfad61d	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments	POST	\N	200	\N	\N	\N	2021-11-30 17:38:59.347594	2021-11-30 17:38:59.347594
f68feba1-318a-43fe-948d-9279c2b83b1a	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/09d7579b-59ae-4543-add3-a1704eba4f1f/applicant	POST	\N	200	\N	\N	\N	2021-11-30 17:38:59.437689	2021-11-30 17:38:59.437689
7c258a53-1909-4975-8399-5d5956bfe028	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/09d7579b-59ae-4543-add3-a1704eba4f1f/capitals	POST	\N	200	\N	\N	\N	2021-11-30 17:38:59.485832	2021-11-30 17:38:59.485832
059c72c6-33ea-4bcd-855d-9107c8073ef0	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/09d7579b-59ae-4543-add3-a1704eba4f1f/vehicles	POST	\N	200	\N	\N	\N	2021-11-30 17:38:59.525667	2021-11-30 17:38:59.525667
7bd15b10-f5c4-4da5-9a90-a4f0c5566262	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/09d7579b-59ae-4543-add3-a1704eba4f1f/properties	POST	\N	200	\N	\N	\N	2021-11-30 17:38:59.585637	2021-11-30 17:38:59.585637
99569c2e-76f2-4873-9ed8-6d7f24d581ef	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/09d7579b-59ae-4543-add3-a1704eba4f1f/explicit_remarks	POST	\N	200	\N	\N	\N	2021-11-30 17:38:59.627294	2021-11-30 17:38:59.627294
41834efb-7b0c-4ace-8589-56b3fb860fb2	5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	https://check-financial-eligibility-staging.apps.live-1.cloud-platform.service.justice.gov.uk/assessments/09d7579b-59ae-4543-add3-a1704eba4f1f	GET	\N	200	\N	\N	\N	2021-11-30 17:38:59.746765	2021-11-30 17:38:59.746765
\.


--
-- Data for Name: cfe_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cfe_submissions (id, legal_aid_application_id, assessment_id, aasm_state, error_message, cfe_result, created_at, updated_at) FROM stdin;
0d7e35b4-5cea-44ca-9697-f15df20e2841	db61619d-b102-4781-aaaa-fce80d065aeb	4b4580de-d580-473d-b9a5-b40258413b57	results_obtained	\N	\N	2021-11-30 16:56:54.303632	2021-11-30 16:56:55.624902
5b5f97b7-fac6-4020-8b30-a7fe23d0f41c	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	09d7579b-59ae-4543-add3-a1704eba4f1f	results_obtained	\N	\N	2021-11-30 17:38:59.244557	2021-11-30 17:38:59.758995
\.


--
-- Data for Name: chances_of_successes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chances_of_successes (id, created_at, updated_at, application_purpose, success_prospect, success_prospect_details, success_likely, application_proceeding_type_id, proceeding_id) FROM stdin;
05964a65-91a1-489a-aeba-964452fb0d39	2021-11-30 16:57:18.279791	2021-11-30 16:57:18.279791	\N	likely	\N	t	ea23e24a-52c4-48f0-9848-7ceabc0cad07	eeff8c6b-1b52-40c4-937a-60f0f739d15d
b5f1503a-ad14-4a9e-a175-6e70ea260f67	2021-11-30 17:39:31.393127	2021-11-30 17:39:31.393127	\N	likely	\N	t	207939d3-3b7a-4993-b347-1bf8a7dce97f	d8ba9ef5-6ee8-4bb6-8f77-a2959a1bbee6
\.


--
-- Data for Name: data_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.data_migrations (version) FROM stdin;
20211020133241
20211022112450
20211022112819
20211103105816
20211112125241
20211125142125
\.


--
-- Data for Name: debugs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.debugs (id, debug_type, legal_aid_application_id, session_id, session, auth_params, callback_params, callback_url, error_details, created_at, updated_at, browser_details) FROM stdin;
\.


--
-- Data for Name: default_cost_limitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.default_cost_limitations (id, proceeding_type_id, start_date, cost_type, value, created_at, updated_at) FROM stdin;
9e90fc4c-e510-40cd-8d89-9855f2251e63	37ddb25c-3b7c-4392-a283-523e7d663f1c	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.188484	2021-11-19 14:20:42.188484
16d2a5a7-8810-40dc-8b03-52fdcf4a5bea	37ddb25c-3b7c-4392-a283-523e7d663f1c	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.195108	2021-11-19 14:20:42.195108
26da3305-d16c-4643-a664-78abadd86a8f	37ddb25c-3b7c-4392-a283-523e7d663f1c	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.201548	2021-11-19 14:20:42.201548
46d2e5b1-c942-4771-84fb-acf2c21af833	640df225-6c25-4129-b042-8b390f287075	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.208042	2021-11-19 14:20:42.208042
d816a94b-a828-4622-ab9f-61965b5e8f4d	640df225-6c25-4129-b042-8b390f287075	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.214379	2021-11-19 14:20:42.214379
07135050-74a6-46ec-860f-9e5ff83f8519	640df225-6c25-4129-b042-8b390f287075	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.220493	2021-11-19 14:20:42.220493
aa107e04-95a4-4530-8ed3-529e47579ada	35565bdb-a828-4b6f-a01a-971df6eb20dc	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.226788	2021-11-19 14:20:42.226788
ff0440b1-a26c-4f4c-893a-faab5a7d8659	35565bdb-a828-4b6f-a01a-971df6eb20dc	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.233279	2021-11-19 14:20:42.233279
91bff04c-d68f-4990-b41e-174c2c23d2b8	35565bdb-a828-4b6f-a01a-971df6eb20dc	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.239807	2021-11-19 14:20:42.239807
7eaf6c71-42ce-4a24-9760-9e452211e111	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.245884	2021-11-19 14:20:42.245884
3ad1df43-ccc4-471b-abb3-cabd9259c2eb	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.252421	2021-11-19 14:20:42.252421
af6e59fa-f11b-4598-80dd-be5906e49e4d	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.259056	2021-11-19 14:20:42.259056
45b29f80-0037-4ceb-b2c8-8080a4698f19	c24c47cb-8e99-4061-8931-b6faa96a8cd3	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.265757	2021-11-19 14:20:42.265757
c3b759c5-9616-43eb-b1ff-f225e99712e1	c24c47cb-8e99-4061-8931-b6faa96a8cd3	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.272305	2021-11-19 14:20:42.272305
0c31babf-8d81-418a-957c-7402b2f84466	c24c47cb-8e99-4061-8931-b6faa96a8cd3	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.279133	2021-11-19 14:20:42.279133
2438bb29-8679-4879-9aae-45a2d09def63	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.285579	2021-11-19 14:20:42.285579
a89ad38a-5e00-4837-8bfc-90afa3198ab3	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.291985	2021-11-19 14:20:42.291985
c06cf814-e075-4de9-843f-78cd06e1d4d9	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.298416	2021-11-19 14:20:42.298416
4f68c9f6-4b3d-434f-abe0-a5a393183a55	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.304753	2021-11-19 14:20:42.304753
eae81680-dce5-4542-9031-78fcb2fc7798	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.310844	2021-11-19 14:20:42.310844
e1dccce4-02ba-4ae5-8bc9-e7621e4a1829	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.317022	2021-11-19 14:20:42.317022
ef63aab2-c6aa-4968-84e0-4425a94db767	3d978e94-71a9-4a14-a4c4-7ee066f854fd	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.323432	2021-11-19 14:20:42.323432
f06b7de2-59a3-4e60-9d6d-a6babfcf9381	3d978e94-71a9-4a14-a4c4-7ee066f854fd	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.329837	2021-11-19 14:20:42.329837
422629aa-b95a-4bdb-8168-7eb4677fdfa7	3d978e94-71a9-4a14-a4c4-7ee066f854fd	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.335996	2021-11-19 14:20:42.335996
246742eb-dabb-47f2-a009-73f539bfd024	45aabe02-1b37-4060-a565-bd4a4362a1e2	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.342368	2021-11-19 14:20:42.342368
19e86487-ecef-4899-ba13-932bc5864cc6	45aabe02-1b37-4060-a565-bd4a4362a1e2	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.348802	2021-11-19 14:20:42.348802
d21235dd-d60e-4969-beba-96ff49c1abea	45aabe02-1b37-4060-a565-bd4a4362a1e2	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.355147	2021-11-19 14:20:42.355147
d5c9f94d-4eaa-4cf2-b338-24235dfc0553	b7113cdf-0802-4b48-b7bb-411589bee4eb	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.361284	2021-11-19 14:20:42.361284
284426b0-37a3-4efb-bcad-e57459e1af4f	b7113cdf-0802-4b48-b7bb-411589bee4eb	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.367443	2021-11-19 14:20:42.367443
1480d7f0-3347-4314-ad76-c2d5c90b3dd7	b7113cdf-0802-4b48-b7bb-411589bee4eb	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.373703	2021-11-19 14:20:42.373703
4720a968-cfdf-4405-9487-3c2979a835cc	87018071-71a5-48d9-8279-26b6924d5abd	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.379969	2021-11-19 14:20:42.379969
7e5b807c-c126-481b-a6f5-e8ef6194a66e	87018071-71a5-48d9-8279-26b6924d5abd	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.386368	2021-11-19 14:20:42.386368
d383db9f-470a-4f35-9545-77eefbb51dfe	87018071-71a5-48d9-8279-26b6924d5abd	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.392515	2021-11-19 14:20:42.392515
0d3fe24c-344b-42ca-8f04-0588a760d9fa	de0807f0-b036-4825-94ba-555a8abc14d0	1970-01-01	substantive	25000.0	2021-11-19 14:20:42.398766	2021-11-19 14:20:42.398766
f90e9e43-0495-451d-8aaa-123cc1ab678d	de0807f0-b036-4825-94ba-555a8abc14d0	1970-01-01	delegated_functions	1350.0	2021-11-19 14:20:42.405116	2021-11-19 14:20:42.405116
807b824c-bc81-4c8d-932c-5e28849961ea	de0807f0-b036-4825-94ba-555a8abc14d0	2021-09-13	delegated_functions	2250.0	2021-11-19 14:20:42.412915	2021-11-19 14:20:42.412915
\.


--
-- Data for Name: dependants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dependants (id, legal_aid_application_id, number, name, date_of_birth, created_at, updated_at, relationship, monthly_income, has_income, in_full_time_education, has_assets_more_than_threshold, assets_value) FROM stdin;
\.


--
-- Data for Name: dwp_overrides; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dwp_overrides (id, legal_aid_application_id, passporting_benefit, has_evidence_of_benefit, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: feedbacks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feedbacks (id, done_all_needed, satisfaction, improvement_suggestion, created_at, updated_at, os, browser, browser_version, source, difficulty, email, originating_page, legal_aid_application_id) FROM stdin;
\.


--
-- Data for Name: firms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.firms (id, created_at, updated_at, ccms_id, name) FROM stdin;
089b56d1-ac17-4b88-9ba5-3ac5d93b02cc	2021-11-19 14:20:43.426533	2021-11-19 14:20:43.426533	823	Cummings-Miller
6759bf9c-bd38-4d47-a3a3-70e129cc1313	2021-11-19 14:20:43.516669	2021-11-19 14:20:43.516669	910	O'Kon Group
e8400967-3132-4349-bf1f-09e4a3536693	2021-11-19 14:20:43.545703	2021-11-19 14:20:43.545703	1137	Jacobson, Zboncak and Schaden
df03f1e9-f320-48f5-b874-d2744778be9a	2021-11-19 14:20:43.58998	2021-11-19 14:20:43.58998	824	Kilback, Reilly and Cole
41e3a512-0212-4f63-8e61-6f562538e572	2021-11-19 14:20:43.630416	2021-11-19 14:20:43.630416	825	Shields-Bednar
db82bef2-344e-4415-bd82-82142db3746b	2021-11-19 14:20:43.666613	2021-11-19 14:20:43.666613	805	Greenholt LLC
9547a213-a284-4084-92a1-267d69ceba91	2021-11-19 14:20:43.727897	2021-11-19 14:20:43.727897	806	Dietrich, Daugherty and Ryan
33603414-b491-4115-be44-b20a0387a8be	2021-11-19 14:20:43.763579	2021-11-19 14:20:43.763579	555	Jast-Wilderman
73d33890-8f61-4cfa-9047-e2d572949707	2021-11-19 14:20:43.796413	2021-11-19 14:20:43.796413	808	Flatley, Kiehn and Padberg
f2cc38bb-e623-4412-979f-7861cf3ca2f9	2021-11-19 14:20:43.8286	2021-11-19 14:20:43.8286	19148	Volkman, Greenfelder and Mann
fdfbd521-1e36-44bb-bc2b-d0835f0dea66	2021-11-19 14:20:43.902142	2021-11-19 14:20:43.902142	807	Gibson-Bartoletti
a6dcda91-7e51-4ba6-86c7-2696cab7c6b2	2021-11-19 14:20:43.944657	2021-11-19 14:20:43.944657	19537	Lind LLC
78c02d96-62be-4bfb-b86d-6cf290457cbf	2021-11-19 14:20:43.973673	2021-11-19 14:20:43.973673	33230	Gorczany, Quitzon and Bashirian
\.


--
-- Data for Name: gateway_evidences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.gateway_evidences (id, legal_aid_application_id, provider_uploader_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: hmrc_responses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hmrc_responses (id, submission_id, use_case, response, created_at, updated_at, legal_aid_application_id, url) FROM stdin;
\.


--
-- Data for Name: incidents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.incidents (id, occurred_on, details, legal_aid_application_id, created_at, updated_at, told_on) FROM stdin;
c1578df4-d673-43a3-b9ca-cebe626e418f	2003-04-01	Ex culpa deleniti quisquam.	db61619d-b102-4781-aaaa-fce80d065aeb	2021-11-30 16:57:08.22545	2021-11-30 16:57:08.22545	2013-03-12
0e9adb71-4ecc-4e95-9f3f-24b781b4e8a1	2021-01-01	Et possimus unde alias.	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	2021-11-30 17:39:13.515616	2021-11-30 17:39:13.515616	2021-01-01
\.


--
-- Data for Name: involved_children; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.involved_children (id, legal_aid_application_id, full_name, date_of_birth, created_at, updated_at, ccms_opponent_id) FROM stdin;
\.


--
-- Data for Name: irregular_incomes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.irregular_incomes (id, legal_aid_application_id, income_type, frequency, amount, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: legal_aid_application_transaction_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.legal_aid_application_transaction_types (id, legal_aid_application_id, transaction_type_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: legal_aid_applications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.legal_aid_applications (id, application_ref, created_at, updated_at, applicant_id, has_offline_accounts, open_banking_consent, open_banking_consent_choice_at, own_home, property_value, shared_ownership, outstanding_mortgage_amount, percentage_home, provider_step, provider_id, draft, transaction_period_start_on, transaction_period_finish_on, transactions_gathered, completed_at, applicant_means_answers, declaration_accepted_at, provider_step_params, own_vehicle, substantive_application_deadline_on, substantive_application, has_dependants, office_id, has_restrictions, restrictions_details, no_credit_transaction_types_selected, no_debit_transaction_types_selected, provider_received_citizen_consent, student_finance, discarded_at, merits_submitted_at, in_scope_of_laspo, emergency_cost_override, emergency_cost_requested, emergency_cost_reasons, no_cash_income, no_cash_outgoings, purgeable_on) FROM stdin;
db61619d-b102-4781-aaaa-fce80d065aeb	L-6M7-MWD	2021-11-30 16:55:39.170134	2021-11-30 16:57:21.483271	98aa089f-577e-4c91-b62b-82bd9004e130	\N	\N	\N	no	\N	\N	\N	\N	end_of_applications	31f3206c-2ae4-4b1f-9f3c-59a495861758	f	\N	\N	\N	\N	\N	\N	{"locale":"en"}	f	2021-11-29	t	\N	ae18ef37-4a88-46a3-a43a-8d58fea33b43	\N	\N	\N	\N	\N	\N	\N	2021-11-30 16:57:21.308159	\N	f	\N	\N	\N	\N	\N
bf37635d-8cf5-4a8a-8e59-76480b91d2bc	L-WVM-M51	2021-11-29 14:27:39.657903	2021-11-29 14:28:42.594127	ea027fd1-0132-4bc4-9ff3-4620245acbbd	\N	\N	\N	\N	\N	\N	\N	\N	confirm_multiple_delegated_functions	db9e082e-9f15-4a6b-b7a8-fcad3c160bce	f	\N	\N	\N	\N	\N	\N	{"locale":"en"}	\N	2021-08-31	\N	\N	bab2665d-4b70-45a8-87f7-2b3f30880dba	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
f6ab5c93-48e2-48ee-87bb-e1d0a4124799	L-UJ3-X0M	2021-11-30 17:37:39.436635	2021-11-30 17:39:36.622265	d1d0179e-d769-4bf5-999f-78a8573e73d2	\N	\N	\N	no	\N	\N	\N	\N	end_of_applications	db9e082e-9f15-4a6b-b7a8-fcad3c160bce	f	\N	\N	\N	\N	\N	\N	{"locale":"en"}	f	2021-12-30	t	\N	bab2665d-4b70-45a8-87f7-2b3f30880dba	\N	\N	\N	\N	\N	\N	\N	2021-11-30 17:39:36.529617	\N	f	\N	\N	\N	\N	\N
\.


--
-- Data for Name: legal_framework_merits_task_lists; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.legal_framework_merits_task_lists (id, legal_aid_application_id, serialized_data, created_at, updated_at) FROM stdin;
dd44d30d-be36-47f8-9048-62e9d3c4ceba	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 794fb8e2-b9e6-4937-9efe-67c9533474a2\n  :success: true\n  :application:\n    :tasks:\n      :latest_incident_details: &1 []\n      :opponent_details: &2 []\n      :statement_of_case: &3 []\n  :proceeding_types:\n  - :ccms_code: DA004\n    :tasks:\n      :chances_of_success: &4 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :latest_incident_details\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_details\n    dependencies: *2\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :statement_of_case\n    dependencies: *3\n    state: :complete\n  :proceedings:\n    :DA004:\n      :name: Non-molestation order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :chances_of_success\n        dependencies: *4\n        state: :complete\n	2021-11-30 17:39:01.908788	2021-11-30 17:39:31.388862
a5e91593-ff23-4447-811d-895ccad32d11	db61619d-b102-4781-aaaa-fce80d065aeb	--- !ruby/object:LegalFramework::SerializableMeritsTaskList\nlfa_response:\n  :request_id: 11706418-5167-4fd9-a3ed-85b05a34c73e\n  :success: true\n  :application:\n    :tasks:\n      :latest_incident_details: &1 []\n      :opponent_details: &2 []\n      :statement_of_case: &3 []\n  :proceeding_types:\n  - :ccms_code: DA004\n    :tasks:\n      :chances_of_success: &4 []\ntasks:\n  :application:\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :latest_incident_details\n    dependencies: *1\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :opponent_details\n    dependencies: *2\n    state: :complete\n  - !ruby/object:LegalFramework::SerializableMeritsTask\n    name: :statement_of_case\n    dependencies: *3\n    state: :complete\n  :proceedings:\n    :DA004:\n      :name: Non-molestation order\n      :tasks:\n      - !ruby/object:LegalFramework::SerializableMeritsTask\n        name: :chances_of_success\n        dependencies: *4\n        state: :complete\n	2021-11-30 16:56:57.789169	2021-11-30 16:57:18.275951
\.


--
-- Data for Name: legal_framework_submission_histories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.legal_framework_submission_histories (id, submission_id, url, http_method, request_payload, http_response_status, response_payload, error_message, error_backtrace, created_at, updated_at) FROM stdin;
9b637b7c-0749-41e8-8f4f-e0f5f11ea574	11706418-5167-4fd9-a3ed-85b05a34c73e	https://legal-framework-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk/merits_tasks	POST	{"request_id":"11706418-5167-4fd9-a3ed-85b05a34c73e","proceeding_types":["DA004"]}	200	{"request_id":"11706418-5167-4fd9-a3ed-85b05a34c73e","success":true,"application":{"tasks":{"latest_incident_details":[],"opponent_details":[],"statement_of_case":[]}},"proceeding_types":[{"ccms_code":"DA004","tasks":{"chances_of_success":[]}}]}	\N	\N	2021-11-30 16:56:57.595995	2021-11-30 16:56:57.595995
e37fe002-254d-483a-a55e-e62d8910041b	794fb8e2-b9e6-4937-9efe-67c9533474a2	https://legal-framework-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk/merits_tasks	POST	{"request_id":"794fb8e2-b9e6-4937-9efe-67c9533474a2","proceeding_types":["DA004"]}	200	{"request_id":"794fb8e2-b9e6-4937-9efe-67c9533474a2","success":true,"application":{"tasks":{"latest_incident_details":[],"opponent_details":[],"statement_of_case":[]}},"proceeding_types":[{"ccms_code":"DA004","tasks":{"chances_of_success":[]}}]}	\N	\N	2021-11-30 17:39:01.897768	2021-11-30 17:39:01.897768
\.


--
-- Data for Name: legal_framework_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.legal_framework_submissions (id, legal_aid_application_id, request_id, error_message, result, created_at, updated_at) FROM stdin;
11706418-5167-4fd9-a3ed-85b05a34c73e	db61619d-b102-4781-aaaa-fce80d065aeb	\N	\N	\N	2021-11-30 16:56:57.396917	2021-11-30 16:56:57.396917
794fb8e2-b9e6-4937-9efe-67c9533474a2	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	\N	\N	\N	2021-11-30 17:39:01.834504	2021-11-30 17:39:01.834504
\.


--
-- Data for Name: malware_scan_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.malware_scan_results (id, uploader_type, uploader_id, virus_found, scan_result, file_details, created_at, updated_at, scanner_working) FROM stdin;
\.


--
-- Data for Name: offices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.offices (id, created_at, updated_at, ccms_id, code, firm_id) FROM stdin;
ae18ef37-4a88-46a3-a43a-8d58fea33b43	2021-11-19 14:20:43.449273	2021-11-19 14:20:43.449273		5A422X	089b56d1-ac17-4b88-9ba5-3ac5d93b02cc
bef662c2-26ea-4725-969a-c832fa4af95f	2021-11-19 14:20:43.451358	2021-11-19 14:20:43.451358		7W620Z	089b56d1-ac17-4b88-9ba5-3ac5d93b02cc
40d7c8f7-9196-4e2a-99f3-362ac0d0561a	2021-11-19 14:20:43.453174	2021-11-19 14:20:43.453174		6O576R	089b56d1-ac17-4b88-9ba5-3ac5d93b02cc
27590ee4-954e-4c9a-8536-397373c3b441	2021-11-19 14:20:43.523468	2021-11-19 14:20:43.523468		6N769P	6759bf9c-bd38-4d47-a3a3-70e129cc1313
a591fddc-a192-4b7c-b8ff-d5597ab274e5	2021-11-19 14:20:43.552362	2021-11-19 14:20:43.552362	1	8V394G	e8400967-3132-4349-bf1f-09e4a3536693
8adc5e4b-ab56-43c5-b458-ff2f92e59b01	2021-11-19 14:20:43.554126	2021-11-19 14:20:43.554126	2	2N073J	e8400967-3132-4349-bf1f-09e4a3536693
243d04ef-a2ef-4aa6-85c8-156aef2572cc	2021-11-19 14:20:43.556083	2021-11-19 14:20:43.556083	3	4R077E	e8400967-3132-4349-bf1f-09e4a3536693
bdac1d22-a46b-4930-a881-ac28edadeac1	2021-11-19 14:20:43.557798	2021-11-19 14:20:43.557798	4	7W756K	e8400967-3132-4349-bf1f-09e4a3536693
06d0924b-a2a1-4cb7-88bf-553f080e3b29	2021-11-19 14:20:43.597006	2021-11-19 14:20:43.597006	5	8L691V	df03f1e9-f320-48f5-b874-d2744778be9a
a19856c1-5695-4061-bc77-df212a6e30e7	2021-11-19 14:20:43.598767	2021-11-19 14:20:43.598767	6	4E542F	df03f1e9-f320-48f5-b874-d2744778be9a
97fb64ee-10a9-4620-8576-e9eb09225732	2021-11-19 14:20:43.600505	2021-11-19 14:20:43.600505	7	6U676C	df03f1e9-f320-48f5-b874-d2744778be9a
01ef2f5c-515b-4e49-98d5-97ec783dc899	2021-11-19 14:20:43.602331	2021-11-19 14:20:43.602331	8	1D108N	df03f1e9-f320-48f5-b874-d2744778be9a
83b7651e-13c6-436e-a067-a6c8946edcad	2021-11-19 14:20:43.637088	2021-11-19 14:20:43.637088	9	9N452A	41e3a512-0212-4f63-8e61-6f562538e572
537cd332-0cb6-45d1-a567-9e7925e93c48	2021-11-19 14:20:43.638827	2021-11-19 14:20:43.638827	10	4T234X	41e3a512-0212-4f63-8e61-6f562538e572
7e3c2255-09dd-46b4-b972-13a4b3ee2496	2021-11-19 14:20:43.640541	2021-11-19 14:20:43.640541	11	3N339K	41e3a512-0212-4f63-8e61-6f562538e572
1de8a736-35f1-4158-b70d-69967b172a06	2021-11-19 14:20:43.673367	2021-11-19 14:20:43.673367	12	3K976A	db82bef2-344e-4415-bd82-82142db3746b
31899cef-f09a-4d1e-b06d-555b83fb92ca	2021-11-19 14:20:43.675104	2021-11-19 14:20:43.675104	13	0R684Z	db82bef2-344e-4415-bd82-82142db3746b
81c3a590-1251-46f8-9707-6acf6d70f352	2021-11-19 14:20:43.676856	2021-11-19 14:20:43.676856	14	9Q655P	db82bef2-344e-4415-bd82-82142db3746b
86c8cfdd-dc12-4c6d-8041-9ed900ea03a5	2021-11-19 14:20:43.678571	2021-11-19 14:20:43.678571	15	6I365E	db82bef2-344e-4415-bd82-82142db3746b
87361259-aaf5-459a-a161-d5636487cbaf	2021-11-19 14:20:43.734489	2021-11-19 14:20:43.734489	16	2T557O	9547a213-a284-4084-92a1-267d69ceba91
ffba32c0-70a3-4324-a687-3bc2f57cfe85	2021-11-19 14:20:43.73622	2021-11-19 14:20:43.73622	17	7W503E	9547a213-a284-4084-92a1-267d69ceba91
491dbeaa-59f0-4df4-bf8a-2ea6802d1f62	2021-11-19 14:20:43.737936	2021-11-19 14:20:43.737936	18	6F671I	9547a213-a284-4084-92a1-267d69ceba91
408611fc-652b-4b2e-98d3-6b402adad2bc	2021-11-19 14:20:43.770335	2021-11-19 14:20:43.770335	19	7J573D	33603414-b491-4115-be44-b20a0387a8be
3a04efb6-5791-4c78-b9e9-0e31e8360389	2021-11-19 14:20:43.77209	2021-11-19 14:20:43.77209	20	8F135T	33603414-b491-4115-be44-b20a0387a8be
8e7d6baf-24db-459c-bb90-a64fa6a60491	2021-11-19 14:20:43.803201	2021-11-19 14:20:43.803201	21	0N159T	73d33890-8f61-4cfa-9047-e2d572949707
9a053eb3-a0b6-4477-a8a8-a0e3b6096d1b	2021-11-19 14:20:43.805055	2021-11-19 14:20:43.805055	22	2Q958W	73d33890-8f61-4cfa-9047-e2d572949707
bab2665d-4b70-45a8-87f7-2b3f30880dba	2021-11-19 14:20:43.835331	2021-11-19 14:20:43.835331	137570	4K495T	f2cc38bb-e623-4412-979f-7861cf3ca2f9
b396e136-41a4-4694-8a63-3fdc72b73bd5	2021-11-19 14:20:43.916844	2021-11-19 14:20:43.916844	21	5G539S	fdfbd521-1e36-44bb-bc2b-d0835f0dea66
16d80951-a2cd-4f13-bd48-c095d4385bab	2021-11-19 14:20:43.918707	2021-11-19 14:20:43.918707	22	1M283X	fdfbd521-1e36-44bb-bc2b-d0835f0dea66
c75160b6-2f69-4d03-a0bb-994a55e15ed0	2021-11-19 14:20:43.951751	2021-11-19 14:20:43.951751	85605	5G918E	a6dcda91-7e51-4ba6-86c7-2696cab7c6b2
36016e24-b147-4da9-81c3-754c6ba9dee5	2021-11-19 14:20:43.98087	2021-11-19 14:20:43.98087	85981	5W077Y	78c02d96-62be-4bfb-b86d-6cf290457cbf
\.


--
-- Data for Name: offices_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.offices_providers (office_id, provider_id) FROM stdin;
ae18ef37-4a88-46a3-a43a-8d58fea33b43	31f3206c-2ae4-4b1f-9f3c-59a495861758
bef662c2-26ea-4725-969a-c832fa4af95f	31f3206c-2ae4-4b1f-9f3c-59a495861758
40d7c8f7-9196-4e2a-99f3-362ac0d0561a	31f3206c-2ae4-4b1f-9f3c-59a495861758
27590ee4-954e-4c9a-8536-397373c3b441	23bd6022-4a49-426e-96e9-eba84b090460
a591fddc-a192-4b7c-b8ff-d5597ab274e5	db645e85-ace9-4978-abff-30725b7c0a62
8adc5e4b-ab56-43c5-b458-ff2f92e59b01	db645e85-ace9-4978-abff-30725b7c0a62
243d04ef-a2ef-4aa6-85c8-156aef2572cc	db645e85-ace9-4978-abff-30725b7c0a62
bdac1d22-a46b-4930-a881-ac28edadeac1	db645e85-ace9-4978-abff-30725b7c0a62
06d0924b-a2a1-4cb7-88bf-553f080e3b29	161bf278-bf86-4563-a455-92910213863a
a19856c1-5695-4061-bc77-df212a6e30e7	161bf278-bf86-4563-a455-92910213863a
97fb64ee-10a9-4620-8576-e9eb09225732	161bf278-bf86-4563-a455-92910213863a
01ef2f5c-515b-4e49-98d5-97ec783dc899	161bf278-bf86-4563-a455-92910213863a
83b7651e-13c6-436e-a067-a6c8946edcad	89287f59-38bc-49fa-a490-3d44a90af43d
537cd332-0cb6-45d1-a567-9e7925e93c48	89287f59-38bc-49fa-a490-3d44a90af43d
7e3c2255-09dd-46b4-b972-13a4b3ee2496	89287f59-38bc-49fa-a490-3d44a90af43d
1de8a736-35f1-4158-b70d-69967b172a06	3d2be5cf-2b9b-4714-84ac-fa7727111095
31899cef-f09a-4d1e-b06d-555b83fb92ca	3d2be5cf-2b9b-4714-84ac-fa7727111095
81c3a590-1251-46f8-9707-6acf6d70f352	3d2be5cf-2b9b-4714-84ac-fa7727111095
86c8cfdd-dc12-4c6d-8041-9ed900ea03a5	3d2be5cf-2b9b-4714-84ac-fa7727111095
1de8a736-35f1-4158-b70d-69967b172a06	70c8c6e1-1871-4ea9-8097-b4d6ef668da8
31899cef-f09a-4d1e-b06d-555b83fb92ca	70c8c6e1-1871-4ea9-8097-b4d6ef668da8
81c3a590-1251-46f8-9707-6acf6d70f352	70c8c6e1-1871-4ea9-8097-b4d6ef668da8
86c8cfdd-dc12-4c6d-8041-9ed900ea03a5	70c8c6e1-1871-4ea9-8097-b4d6ef668da8
87361259-aaf5-459a-a161-d5636487cbaf	f4935a07-f370-49dc-bdbb-013928204d00
ffba32c0-70a3-4324-a687-3bc2f57cfe85	f4935a07-f370-49dc-bdbb-013928204d00
491dbeaa-59f0-4df4-bf8a-2ea6802d1f62	f4935a07-f370-49dc-bdbb-013928204d00
408611fc-652b-4b2e-98d3-6b402adad2bc	f2d6c0fe-560c-4830-8803-acff053875d5
3a04efb6-5791-4c78-b9e9-0e31e8360389	f2d6c0fe-560c-4830-8803-acff053875d5
8e7d6baf-24db-459c-bb90-a64fa6a60491	0ba322d0-ef1c-42c5-98e1-a0b45cff7415
9a053eb3-a0b6-4477-a8a8-a0e3b6096d1b	0ba322d0-ef1c-42c5-98e1-a0b45cff7415
bab2665d-4b70-45a8-87f7-2b3f30880dba	db9e082e-9f15-4a6b-b7a8-fcad3c160bce
b396e136-41a4-4694-8a63-3fdc72b73bd5	7d0547aa-56f5-4940-b871-558def68c2bd
16d80951-a2cd-4f13-bd48-c095d4385bab	7d0547aa-56f5-4940-b871-558def68c2bd
c75160b6-2f69-4d03-a0bb-994a55e15ed0	19c3acc9-2d61-4bea-96ba-2c23606b7521
36016e24-b147-4da9-81c3-754c6ba9dee5	bb130757-b8db-4d09-88a9-43a10e47d17b
\.


--
-- Data for Name: opponents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.opponents (id, legal_aid_application_id, understands_terms_of_court_order, understands_terms_of_court_order_details, warning_letter_sent, warning_letter_sent_details, police_notified, police_notified_details, bail_conditions_set, bail_conditions_set_details, created_at, updated_at, full_name, ccms_opponent_id) FROM stdin;
f4fa6b7c-9f87-49f8-a710-c42c0e28f4fa	db61619d-b102-4781-aaaa-fce80d065aeb	t	Recusandae perspiciatis libero est.	f	Vel velit vitae magni.	t	Et optio a ut.	f	Autem quo optio minima.	2021-11-30 16:57:11.094381	2021-11-30 16:57:11.094381	Dallas Swift	\N
21e7ca8e-24d1-4d1e-9a47-f1cb69c7964c	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	t	Est molestias dolorem quas.	t	Eum aut optio rem.	f	Sed illo modi sunt.	f	Exercitationem quidem quo dolor.	2021-11-30 17:39:24.600459	2021-11-30 17:40:13.332015	Sen. Lisha Macejkovic	88000001
\.


--
-- Data for Name: other_assets_declarations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.other_assets_declarations (id, legal_aid_application_id, second_home_value, second_home_mortgage, second_home_percentage, timeshare_property_value, land_value, valuable_items_value, inherited_assets_value, money_owed_value, trust_value, created_at, updated_at, none_selected) FROM stdin;
b1433c4e-463c-4786-b698-cc6314158792	db61619d-b102-4781-aaaa-fce80d065aeb	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-11-30 16:56:48.000685	2021-11-30 16:56:49.85835	t
d37ca47d-f136-48c5-af9d-d9421a97a4e8	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	\N	\N	\N	\N	\N	\N	\N	\N	\N	2021-11-30 17:38:52.08959	2021-11-30 17:38:54.935823	t
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, role, description) FROM stdin;
43c8ada8-9d87-4cd7-b74f-7d502730dee4	application.passported.*	Can create, edit, delete passported applications
bfd407a2-88a7-4967-8037-1bba8a7eb067	application.non_passported.*	Can create, edit, delete non-passported applications
c61cf23d-4d1a-4351-b712-e8d4a6d04e4d	application.non_passported.employment.*	Can create, edit, delete employment applications
\.


--
-- Data for Name: policy_disregards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.policy_disregards (id, england_infected_blood_support, vaccine_damage_payments, variant_creutzfeldt_jakob_disease, criminal_injuries_compensation_scheme, national_emergencies_trust, we_love_manchester_emergency_fund, london_emergencies_trust, none_selected, created_at, updated_at, legal_aid_application_id) FROM stdin;
d51e9ca4-ac9b-4a0a-a1d0-93e32ff6dbfc	\N	\N	\N	\N	\N	\N	\N	t	2021-11-30 16:56:49.952411	2021-11-30 16:56:52.130988	db61619d-b102-4781-aaaa-fce80d065aeb
b0c55231-7b0a-4d54-8aa8-f537a45376ea	\N	\N	\N	\N	\N	\N	\N	t	2021-11-30 17:38:55.136613	2021-11-30 17:38:56.966763	f6ab5c93-48e2-48ee-87bb-e1d0a4124799
\.


--
-- Data for Name: proceeding_type_scope_limitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proceeding_type_scope_limitations (id, proceeding_type_id, scope_limitation_id, substantive_default, delegated_functions_default, created_at, updated_at) FROM stdin;
84c8102b-56ba-471a-aa36-00186d8047ac	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:42.557334	2021-11-19 14:20:42.557334
7c663402-762d-4ca3-a6b8-d6159610135b	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	88b81660-1261-4a8a-857e-316a177f8d0f	f	f	2021-11-19 14:20:42.56804	2021-11-19 14:20:42.56804
5c178d55-cddb-49ef-9676-09fba8576077	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:42.577706	2021-11-19 14:20:42.577706
c2fbcb00-4e64-483f-a795-cbef3071c226	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:42.58747	2021-11-19 14:20:42.58747
46b99c18-1f70-4f50-8e24-f0d1a9a54e87	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:42.597002	2021-11-19 14:20:42.597002
3684c35f-bbbe-4790-a934-3ab118df4696	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:42.606563	2021-11-19 14:20:42.606563
28326e6e-44e9-43e4-a5d0-fc5e8610efe8	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:42.616283	2021-11-19 14:20:42.616283
3d41f2eb-c354-400f-a73a-ebfcbe48dd96	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:42.625948	2021-11-19 14:20:42.625948
2f6c6159-123e-4b75-9efb-12b272db14cd	10fc656c-4b28-4b3e-8c99-4bd6eed893a5	914184d4-1f44-42d6-b071-5e3e603f7cfd	t	f	2021-11-19 14:20:42.635423	2021-11-19 14:20:42.635423
a9465c7a-8c44-4896-8487-45d3ef59f20b	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:42.644818	2021-11-19 14:20:42.644818
bf1f1966-7706-4e35-b3d7-ebae58b4eaf5	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	88b81660-1261-4a8a-857e-316a177f8d0f	t	f	2021-11-19 14:20:42.654271	2021-11-19 14:20:42.654271
5cb62d9e-5b96-46d7-845b-1fa0e3460548	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:42.663835	2021-11-19 14:20:42.663835
507bf076-0302-4470-ab75-a622cee8013d	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:42.673703	2021-11-19 14:20:42.673703
9f82b408-52df-4406-8eda-9aef57af515a	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:42.683427	2021-11-19 14:20:42.683427
f7b1aaae-75c2-49da-8a4d-f199ddb903ec	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:42.693033	2021-11-19 14:20:42.693033
40e68336-9b5e-4b7e-bb7c-ad45c08fea73	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:42.713868	2021-11-19 14:20:42.713868
48cb9f79-e2e0-4721-ae7b-872d8f4bb954	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:42.723437	2021-11-19 14:20:42.723437
ea9ee83f-36c6-45d1-84cb-3e1cda31f2d8	b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:42.734255	2021-11-19 14:20:42.734255
53d4a48b-1c49-43fe-818a-ba58a95238c3	35565bdb-a828-4b6f-a01a-971df6eb20dc	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:42.744637	2021-11-19 14:20:42.744637
93946406-88e0-4fdf-bb9a-e0c2c6b2d681	35565bdb-a828-4b6f-a01a-971df6eb20dc	88b81660-1261-4a8a-857e-316a177f8d0f	t	f	2021-11-19 14:20:42.75417	2021-11-19 14:20:42.75417
d422ea03-8454-4fa9-8e6f-f62185dd9f24	35565bdb-a828-4b6f-a01a-971df6eb20dc	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:42.764084	2021-11-19 14:20:42.764084
a308a740-68de-4e4c-8ff3-2f9099ff83c5	35565bdb-a828-4b6f-a01a-971df6eb20dc	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:42.773543	2021-11-19 14:20:42.773543
1d94e70e-6a05-4b48-8e99-3bb4555a2074	35565bdb-a828-4b6f-a01a-971df6eb20dc	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:42.78346	2021-11-19 14:20:42.78346
b77ab65c-3fd3-4548-b767-1dbd8d8a6a12	35565bdb-a828-4b6f-a01a-971df6eb20dc	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:42.793026	2021-11-19 14:20:42.793026
46b1a1ad-e6e6-4fa7-be09-4b15539bee22	35565bdb-a828-4b6f-a01a-971df6eb20dc	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:42.802926	2021-11-19 14:20:42.802926
dd3a5a74-a6c6-4129-8d32-b40f0faa84f2	35565bdb-a828-4b6f-a01a-971df6eb20dc	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:42.812445	2021-11-19 14:20:42.812445
b260e427-4396-46a6-a629-3f321e97db40	35565bdb-a828-4b6f-a01a-971df6eb20dc	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:42.822385	2021-11-19 14:20:42.822385
f558a7ab-1044-4fa3-8f0f-41460547174c	35565bdb-a828-4b6f-a01a-971df6eb20dc	914184d4-1f44-42d6-b071-5e3e603f7cfd	f	f	2021-11-19 14:20:42.832086	2021-11-19 14:20:42.832086
75af4313-a1b2-47ce-8706-4a8c129407a8	c24c47cb-8e99-4061-8931-b6faa96a8cd3	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:42.841683	2021-11-19 14:20:42.841683
e3ba187b-c4e3-47d8-ba1a-4468cfd246b6	c24c47cb-8e99-4061-8931-b6faa96a8cd3	88b81660-1261-4a8a-857e-316a177f8d0f	t	f	2021-11-19 14:20:42.851243	2021-11-19 14:20:42.851243
635a444f-f17c-4fdc-b770-3dca3079a124	c24c47cb-8e99-4061-8931-b6faa96a8cd3	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:42.860864	2021-11-19 14:20:42.860864
254f4566-0166-4f0e-b4d4-2f2b01fceae1	c24c47cb-8e99-4061-8931-b6faa96a8cd3	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:42.870463	2021-11-19 14:20:42.870463
d6232833-3845-41e0-9760-7bb7d3da3a3d	c24c47cb-8e99-4061-8931-b6faa96a8cd3	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:42.880232	2021-11-19 14:20:42.880232
c7557c24-322e-4f8c-a0bf-980eb15ae9bb	c24c47cb-8e99-4061-8931-b6faa96a8cd3	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:42.889924	2021-11-19 14:20:42.889924
fb3c89e5-4244-4da7-b890-04ae39f002cf	c24c47cb-8e99-4061-8931-b6faa96a8cd3	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:42.899839	2021-11-19 14:20:42.899839
9c794926-591f-4526-acd0-4b16f0b8239e	c24c47cb-8e99-4061-8931-b6faa96a8cd3	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:42.909194	2021-11-19 14:20:42.909194
250a2b88-7a7c-4b64-84c9-9066205316cd	c24c47cb-8e99-4061-8931-b6faa96a8cd3	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:42.919105	2021-11-19 14:20:42.919105
e20b4f39-a016-4973-9d3d-df7913456280	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:42.928669	2021-11-19 14:20:42.928669
9536ad5c-ae32-467d-ac9b-23698e1abdaa	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	88b81660-1261-4a8a-857e-316a177f8d0f	t	f	2021-11-19 14:20:42.938717	2021-11-19 14:20:42.938717
8ee7a531-7e50-4cb0-9033-866dd74807b2	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:42.948239	2021-11-19 14:20:42.948239
f6c6269b-cd19-43e0-9e76-811a9a220097	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:42.95792	2021-11-19 14:20:42.95792
24747416-55ba-4591-baa1-f8d9cc6d2406	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:42.967632	2021-11-19 14:20:42.967632
ed273bd0-1532-4b59-886c-f60c5ee7aee6	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:42.977895	2021-11-19 14:20:42.977895
be2232aa-0b3d-47ba-b3e9-4da48e8e7cfa	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:42.987516	2021-11-19 14:20:42.987516
c1dc3b00-f818-44c2-9a9f-cc0cdc903464	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:42.997236	2021-11-19 14:20:42.997236
68d28ef2-d398-4b8e-be95-6c65856794d5	8da3deff-3c4b-4d99-aefb-e7e061e03e8e	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:43.006862	2021-11-19 14:20:43.006862
53a58656-13bf-4c84-b60a-a69e77651394	37ddb25c-3b7c-4392-a283-523e7d663f1c	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:43.016695	2021-11-19 14:20:43.016695
6828929d-3666-4a5c-abad-b2290357cc3a	37ddb25c-3b7c-4392-a283-523e7d663f1c	88b81660-1261-4a8a-857e-316a177f8d0f	t	f	2021-11-19 14:20:43.026459	2021-11-19 14:20:43.026459
84d2bd3d-0e02-404c-a31c-1ba36dfb7f87	37ddb25c-3b7c-4392-a283-523e7d663f1c	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:43.036208	2021-11-19 14:20:43.036208
80bf6e6d-e0e9-4928-afcd-0befce4b2cae	37ddb25c-3b7c-4392-a283-523e7d663f1c	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:43.04573	2021-11-19 14:20:43.04573
7fb972fb-805b-4c8d-939a-1fd615a0cfb2	37ddb25c-3b7c-4392-a283-523e7d663f1c	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.055396	2021-11-19 14:20:43.055396
8df734ed-336b-41c4-a8e9-6562122c44d9	37ddb25c-3b7c-4392-a283-523e7d663f1c	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:43.065026	2021-11-19 14:20:43.065026
691663f8-1319-48f2-a041-b861e2e6c426	37ddb25c-3b7c-4392-a283-523e7d663f1c	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:43.075783	2021-11-19 14:20:43.075783
c4c89263-5a31-449f-ad2f-4f7eff74b4f6	37ddb25c-3b7c-4392-a283-523e7d663f1c	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:43.085492	2021-11-19 14:20:43.085492
7e9fbce7-8b21-49c9-b7ba-17c76ac0ddb3	37ddb25c-3b7c-4392-a283-523e7d663f1c	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:43.095376	2021-11-19 14:20:43.095376
c18d838b-1a5b-4212-a378-c684f7c1a273	640df225-6c25-4129-b042-8b390f287075	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:43.104962	2021-11-19 14:20:43.104962
9c4b4b6f-71ed-4d87-a0ba-63d46bbb2b17	640df225-6c25-4129-b042-8b390f287075	88b81660-1261-4a8a-857e-316a177f8d0f	t	f	2021-11-19 14:20:43.114336	2021-11-19 14:20:43.114336
2e740d95-fafd-4b3f-9899-0b1b684288b4	640df225-6c25-4129-b042-8b390f287075	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:43.124031	2021-11-19 14:20:43.124031
0ddef85a-2382-4e28-8f29-4935bdad425e	640df225-6c25-4129-b042-8b390f287075	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:43.133413	2021-11-19 14:20:43.133413
99e4350f-b194-4ef0-941d-66e1f7ec3fe0	640df225-6c25-4129-b042-8b390f287075	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.143157	2021-11-19 14:20:43.143157
9dc75512-ff1d-433c-b337-4e0e8c97151e	640df225-6c25-4129-b042-8b390f287075	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:43.152643	2021-11-19 14:20:43.152643
d1c8a578-2484-4736-ba7b-7862162934e0	640df225-6c25-4129-b042-8b390f287075	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:43.162808	2021-11-19 14:20:43.162808
7da86554-a687-4e5b-acce-0b9bc35efa6c	640df225-6c25-4129-b042-8b390f287075	2fe525fe-4e54-4634-a595-6c32be0de7cf	f	f	2021-11-19 14:20:43.172361	2021-11-19 14:20:43.172361
3779e3ff-d1d4-4fd9-a8e9-ed3a601fcc3a	640df225-6c25-4129-b042-8b390f287075	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:43.181845	2021-11-19 14:20:43.181845
d1eb99be-db8e-46cd-9065-d6cda65e7c9f	3d978e94-71a9-4a14-a4c4-7ee066f854fd	6e16fb95-c80f-460d-a654-27a3bb29144c	f	f	2021-11-19 14:20:43.19159	2021-11-19 14:20:43.19159
ed83f18d-f520-4ad9-b747-0943a0988580	3d978e94-71a9-4a14-a4c4-7ee066f854fd	88b81660-1261-4a8a-857e-316a177f8d0f	f	f	2021-11-19 14:20:43.201385	2021-11-19 14:20:43.201385
fc5076f2-77cc-419b-899b-5a9ee90f99b7	3d978e94-71a9-4a14-a4c4-7ee066f854fd	08087b36-fb3d-48e1-8016-23e02371f4ee	f	f	2021-11-19 14:20:43.210764	2021-11-19 14:20:43.210764
996b9206-23a9-4d5b-84c2-2d17ca62249a	3d978e94-71a9-4a14-a4c4-7ee066f854fd	f17397a3-7a5d-4ca1-ba5d-59d0d30151db	f	f	2021-11-19 14:20:43.220469	2021-11-19 14:20:43.220469
000acc61-6d01-4d50-b3d8-1af6ce573afd	3d978e94-71a9-4a14-a4c4-7ee066f854fd	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.229993	2021-11-19 14:20:43.229993
d450dd95-08da-449f-aa47-80421e0c51be	3d978e94-71a9-4a14-a4c4-7ee066f854fd	4b0eacd0-5a90-42d9-b0a1-569946f311d3	f	f	2021-11-19 14:20:43.239591	2021-11-19 14:20:43.239591
8b9f24aa-0c23-4dcf-896d-a24080fc943a	3d978e94-71a9-4a14-a4c4-7ee066f854fd	39809e9f-9ab2-4320-a9c1-b55e7bde63fd	f	f	2021-11-19 14:20:43.249161	2021-11-19 14:20:43.249161
7a4049b7-debd-4655-a5be-ddad08639a0c	3d978e94-71a9-4a14-a4c4-7ee066f854fd	ddf744f2-58dd-4ddd-9e64-0b62154fc6bc	f	f	2021-11-19 14:20:43.258862	2021-11-19 14:20:43.258862
4adf64dc-8233-4072-8422-a5e390c63c06	3d978e94-71a9-4a14-a4c4-7ee066f854fd	ba5a8865-a3bc-4f3e-bb50-fd504bfab9bc	f	f	2021-11-19 14:20:43.268287	2021-11-19 14:20:43.268287
2eb786e5-6c06-4794-838b-2827261070b0	3d978e94-71a9-4a14-a4c4-7ee066f854fd	8f714715-06d5-4a5c-ab7a-ee01c76fe681	t	f	2021-11-19 14:20:43.278144	2021-11-19 14:20:43.278144
2de524ae-f742-45ae-a7db-a56b7ec65ca0	3d978e94-71a9-4a14-a4c4-7ee066f854fd	87d1119e-150d-4a69-b325-90529d4bdd90	f	f	2021-11-19 14:20:43.28771	2021-11-19 14:20:43.28771
45749c44-8c51-4682-8dd6-5b421746af54	3d978e94-71a9-4a14-a4c4-7ee066f854fd	4ee77412-13b9-4490-a184-b892d54ccf9b	f	f	2021-11-19 14:20:43.297221	2021-11-19 14:20:43.297221
d95bd23a-f589-4f40-8e64-e87c8f4950e7	3d978e94-71a9-4a14-a4c4-7ee066f854fd	c53c0b46-c667-401b-898c-ebf466e2af01	f	f	2021-11-19 14:20:43.306672	2021-11-19 14:20:43.306672
ae9a6f4b-d55c-4354-a50f-c2ca62ae41e4	45aabe02-1b37-4060-a565-bd4a4362a1e2	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.316554	2021-11-19 14:20:43.316554
77d4d371-5376-4502-bddc-01beb42ef82d	45aabe02-1b37-4060-a565-bd4a4362a1e2	935309cc-326c-4fec-9f37-0547c618788d	t	f	2021-11-19 14:20:43.326076	2021-11-19 14:20:43.326076
a6d088a9-85b9-444c-a1fe-0e767aeec2bf	b7113cdf-0802-4b48-b7bb-411589bee4eb	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.335896	2021-11-19 14:20:43.335896
d7770fe3-e29b-4f6f-8585-ca779cb3a66f	b7113cdf-0802-4b48-b7bb-411589bee4eb	935309cc-326c-4fec-9f37-0547c618788d	t	f	2021-11-19 14:20:43.345545	2021-11-19 14:20:43.345545
32c9884d-3011-4904-abf9-1719f4f918e6	87018071-71a5-48d9-8279-26b6924d5abd	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.359511	2021-11-19 14:20:43.359511
109e7579-120c-4644-b18c-0013fed6684b	87018071-71a5-48d9-8279-26b6924d5abd	935309cc-326c-4fec-9f37-0547c618788d	t	f	2021-11-19 14:20:43.369184	2021-11-19 14:20:43.369184
8ea1789a-2bcd-4919-aae3-74d3eca47261	de0807f0-b036-4825-94ba-555a8abc14d0	fd47c785-5d3e-4f26-881e-4133f3ae4d88	f	t	2021-11-19 14:20:43.379359	2021-11-19 14:20:43.379359
02ded2aa-c432-43c8-b9c0-ce52a1babadc	de0807f0-b036-4825-94ba-555a8abc14d0	935309cc-326c-4fec-9f37-0547c618788d	t	f	2021-11-19 14:20:43.388754	2021-11-19 14:20:43.388754
\.


--
-- Data for Name: proceeding_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proceeding_types (id, code, ccms_code, meaning, description, created_at, updated_at, ccms_category_law, ccms_category_law_code, ccms_matter, ccms_matter_code, involvement_type_applicant, additional_search_terms, default_service_level_id, textsearchable, name) FROM stdin;
37ddb25c-3b7c-4392-a283-523e7d663f1c	PR0200	DA006	Extend, variation or discharge - Part IV 	to be represented on an application to extend, vary or discharge an order under Part IV Family Law Act 1996. 	2021-11-19 14:20:42.080134	2021-11-19 14:20:42.080134	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'1996':30 'abuse':9C 'act':29 'an':15,22 'application':16 'be':12 'discharge':4A,21 'domestic':8C 'extend':1A,18 'family':7B,27 'iv':6A,26 'law':28 'on':14 'or':3A,20 'order':23 'part':5A,25 'pr0200':10 'represented':13 'to':11,17 'under':24 'variation':2A 'vary':19	extend_variation_or_discharge_part_iv
b40f35fc-b06e-4fd6-9a16-9a56f0c9fe8c	PR0217	DA002	Variation or discharge under section 5 protection from harassment act 1997	to be represented on an application to vary or discharge an order under section 5 Protection from Harassment Act 1997 where the parties are associated persons (as defined by Part IV Family Law Act 1996).	2021-11-19 14:20:42.129772	2021-11-19 14:20:42.129772	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'1996':50 '1997':11A,35 '5':6A,30 'abuse':14C 'act':10A,34,49 'an':20,26 'application':21 'are':39 'as':42 'associated':40 'be':17 'by':44 'defined':43 'discharge':3A,25 'domestic':13C 'family':12B,47 'from':8A,32 'harassment':9A,33 'iv':46 'law':48 'on':19 'or':2A,24 'order':27 'part':45 'parties':38 'persons':41 'pr0217':15 'protection':7A,31 'represented':18 'section':5A,29 'the':37 'to':16,22 'under':4A,28 'variation':1A 'vary':23 'where':36	variation_or_discharge_under_section_protection_from_harassment_act
35565bdb-a828-4b6f-a01a-971df6eb20dc	PR0206	DA003	Harassment - injunction	to be represented in an action for an injunction under section 3 Protection from Harassment Act 1997.	2021-11-19 14:20:42.097292	2021-11-19 14:20:42.097292	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'1997':23 '3':18 'abuse':5C 'act':22 'action':12 'an':11,14 'be':8 'domestic':4C 'family':3B 'for':13 'from':20 'harassment':1A,21 'in':10 'injunction':2A,15 'pr0206':6 'protection':19 'represented':9 'section':17 'to':7 'under':16	harassment_injunction
10fc656c-4b28-4b3e-8c99-4bd6eed893a5	PR0208	DA001	Inherent jurisdiction high court injunction	to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.	2021-11-19 14:20:42.105465	2021-11-19 14:20:42.105465	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'abuse':8C 'an':14,17 'application':15 'be':11 'court':4A,28 'declaration':21 'domestic':7C 'family':6B 'for':16 'high':3A 'inherent':1A,24 'injunction':5A,18 'jurisdiction':2A,25 'of':26 'on':13 'or':20 'order':19 'pr0208':9 'represented':12 'the':23,27 'to':10 'under':22	inherent_jurisdiction_high_court_injunction
3d978e94-71a9-4a14-a4c4-7ee066f854fd	PR0220	DA020	FGM Protection Order	To be represented on an application for a Female Genital Mutilation Protection Order under the Female Genital Mutilation Act.	2021-11-19 14:20:42.138466	2021-11-19 14:20:42.138466	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'a':15 'abuse':6C 'act':26 'an':12 'application':13 'be':9 'domestic':5C 'family':4B 'female':16,23 'fgm':1A 'for':14 'genital':17,24 'mutilation':18,25 'on':11 'order':3A,20 'pr0220':7 'protection':2A,19 'represented':10 'the':22 'to':8 'under':21	fgm_protection_order
45aabe02-1b37-4060-a565-bd4a4362a1e2	PH0001	SE003	Prohibited steps order	to be represented on an application for a prohibited steps order.	2021-11-19 14:20:42.147406	2021-11-19 14:20:42.147406	Family	MAT	Section 8 orders	KSEC8	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'8':6C 'a':16 'an':13 'application':14 'be':10 'family':4B 'for':15 'on':12 'order':3A,19 'orders':7C 'ph0001':8 'prohibited':1A,17 'represented':11 'section':5C 'steps':2A,18 'to':9	prohibited_steps_order_s8
b7113cdf-0802-4b48-b7bb-411589bee4eb	PH0002	SE004	Specific issue order	to be represented on an application for a specific issue order.	2021-11-19 14:20:42.155635	2021-11-19 14:20:42.155635	Family	MAT	Section 8 orders	KSEC8	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'8':6C 'a':16 'an':13 'application':14 'be':10 'family':4B 'for':15 'issue':2A,18 'on':12 'order':3A,19 'orders':7C 'ph0002':8 'represented':11 'section':5C 'specific':1A,17 'to':9	specified_issue_order_s8
87018071-71a5-48d9-8279-26b6924d5abd	PH0003	SE013	Child arrangements order (contact)	to be represented on an application for a child arrangements order-who the child(ren) spend time with	2021-11-19 14:20:42.16419	2021-11-19 14:20:42.16419	Family	MAT	Section 8 orders	KSEC8	t	cao	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'8':7C 'a':17 'an':14 'application':15 'arrangements':2A,19 'be':11 'cao':29 'child':1A,18,24 'contact':4A 'family':5B 'for':16 'on':13 'order':3A,21 'order-who':20 'orders':8C 'ph0003':9 'ren':25 'represented':12 'section':6C 'spend':26 'the':23 'time':27 'to':10 'who':22 'with':28	child_arrangements_order_contact
640df225-6c25-4129-b042-8b390f287075	PR0203	DA007	Forced marriage protection order	to be represented on an application for a forced marriage protection order	2021-11-19 14:20:42.089287	2021-11-19 14:20:42.089287	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'a':16 'abuse':7C 'an':13 'application':14 'be':10 'domestic':6C 'family':5B 'for':15 'forced':1A,17 'marriage':2A,18 'on':12 'order':4A,20 'pr0203':8 'protection':3A,19 'represented':11 'to':9	forced_marriage_protection_order
c24c47cb-8e99-4061-8931-b6faa96a8cd3	PR0211	DA004	Non-molestation order	to be represented on an application for a non-molestation order.	2021-11-19 14:20:42.113461	2021-11-19 14:20:42.113461	Family	MAT	Domestic Abuse	MINJN	t	harassment,injunction	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'a':16 'abuse':7C 'an':13 'application':14 'be':10 'domestic':6C 'family':5B 'for':15 'harassment':21 'injunction':22 'molestation':3A,19 'non':2A,18 'non-molestation':1A,17 'on':12 'order':4A,20 'pr0211':8 'represented':11 'to':9	nonmolestation_order
8da3deff-3c4b-4d99-aefb-e7e061e03e8e	PR0214	DA005	Occupation order	to be represented on an application for an occupation order.	2021-11-19 14:20:42.121689	2021-11-19 14:20:42.121689	Family	MAT	Domestic Abuse	MINJN	t	\N	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'abuse':5C 'an':11,14 'application':12 'be':8 'domestic':4C 'family':3B 'for':13 'occupation':1A,15 'on':10 'order':2A,16 'pr0214':6 'represented':9 'to':7	occupation_order
de0807f0-b036-4825-94ba-555a8abc14d0	PH0004	SE014	Child arrangements order (residence)	to be represented on an application for a child arrangements order –where the child(ren) will live	2021-11-19 14:20:42.172574	2021-11-19 14:20:42.172574	Family	MAT	Section 8 orders	KSEC8	t	cao	5d686ef7-47b9-47ac-9ab6-5946b08e106e	'8':7C 'a':17 'an':14 'application':15 'arrangements':2A,19 'be':11 'cao':27 'child':1A,18,23 'family':5B 'for':16 'live':26 'on':13 'order':3A,20 'orders':8C 'ph0004':9 'ren':24 'represented':12 'residence':4A 'section':6C 'the':22 'to':10 'where':21 'will':25	child_arrangements_order_residence
\.


--
-- Data for Name: proceedings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proceedings (id, legal_aid_application_id, proceeding_case_id, lead_proceeding, ccms_code, meaning, description, substantive_cost_limitation, delegated_functions_cost_limitation, substantive_scope_limitation_code, substantive_scope_limitation_meaning, substantive_scope_limitation_description, delegated_functions_scope_limitation_code, delegated_functions_scope_limitation_meaning, delegated_functions_scope_limitation_description, used_delegated_functions_on, used_delegated_functions_reported_on, created_at, updated_at, name, matter_type, category_of_law, category_law_code, ccms_matter_code) FROM stdin;
3c4a4130-c3dc-44da-adf0-c2fc3ae8cc48	bf37635d-8cf5-4a8a-8e59-76480b91d2bc	55000001	t	DA004	Non-molestation order	to be represented on an application for a non-molestation order.	25000.0	2250.0	AA019	Injunction FLA-to final hearing	As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).	CV117	Interim order inc. return date	Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.	2021-07-31	2021-11-29	2021-11-29 14:27:50.931389	2021-11-29 14:28:42.443613	nonmolestation_order	Domestic Abuse	Family	MAT	MINJN
d8ba9ef5-6ee8-4bb6-8f77-a2959a1bbee6	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	55000003	t	DA004	Non-molestation order	to be represented on an application for a non-molestation order.	25000.0	2250.0	AA019	Injunction FLA-to final hearing	As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).	CV117	Interim order inc. return date	Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.	2021-11-30	2021-11-30	2021-11-30 17:37:49.437796	2021-11-30 17:38:00.008125	nonmolestation_order	Domestic Abuse	Family	MAT	MINJN
eeff8c6b-1b52-40c4-937a-60f0f739d15d	db61619d-b102-4781-aaaa-fce80d065aeb	55000002	t	DA004	Non-molestation order	to be represented on an application for a non-molestation order.	25000.0	2250.0	AA019	Injunction FLA-to final hearing	As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).	CV117	Interim order inc. return date	Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.	2021-11-01	2021-11-30	2021-11-30 16:56:00.006263	2021-11-30 16:56:09.774716	nonmolestation_order	Domestic Abuse	Family	MAT	MINJN
\.


--
-- Data for Name: proceedings_linked_children; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proceedings_linked_children (id, proceeding_id, involved_child_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.providers (id, username, type, roles, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at, office_codes, firm_id, selected_office_id, name, email, portal_enabled, contact_id, invalid_login_details) FROM stdin;
23bd6022-4a49-426e-96e9-eba84b090460	jeramy_nader_791	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.533492	2021-11-19 14:20:43.533492	\N	6759bf9c-bd38-4d47-a3a3-70e129cc1313	\N	Freddy Wilderman	sona_labadie@jones.co	t	101	\N
db645e85-ace9-4978-abff-30725b7c0a62	gale.roob_897	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.568646	2021-11-19 14:20:43.568646	\N	e8400967-3132-4349-bf1f-09e4a3536693	\N	Isaac Douglas	brigida.reynolds@mcdermott.io	t	102	\N
161bf278-bf86-4563-a455-92910213863a	jamar_johns_947	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.613474	2021-11-19 14:20:43.613474	\N	df03f1e9-f320-48f5-b874-d2744778be9a	\N	Pres. Brain Keebler	damien@mraz.org	t	103	\N
89287f59-38bc-49fa-a490-3d44a90af43d	erin_gutmann_715	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.651455	2021-11-19 14:20:43.651455	\N	41e3a512-0212-4f63-8e61-6f562538e572	\N	Charley White	pedro.botsford@hintz.com	t	104	\N
3d2be5cf-2b9b-4714-84ac-fa7727111095	reed_mclaughlin_958	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.689381	2021-11-19 14:20:43.689381	\N	db82bef2-344e-4415-bd82-82142db3746b	\N	Miss Mose Muller	faustino@gerlach-waters.biz	t	105	\N
70c8c6e1-1871-4ea9-8097-b4d6ef668da8	mariano_654	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.711102	2021-11-19 14:20:43.711102	\N	db82bef2-344e-4415-bd82-82142db3746b	\N	Jacalyn Walter Esq.	dione.kautzer@hauck.org	t	106	\N
f4935a07-f370-49dc-bdbb-013928204d00	marina_352	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.748917	2021-11-19 14:20:43.748917	\N	9547a213-a284-4084-92a1-267d69ceba91	\N	Delfina Stroman	hildegarde_kub@padberg.info	t	107	\N
f2d6c0fe-560c-4830-8803-acff053875d5	harrison_694	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.782615	2021-11-19 14:20:43.782615	\N	33603414-b491-4115-be44-b20a0387a8be	\N	June Toy	rafael@mcclure.io	t	108	\N
7d0547aa-56f5-4940-b871-558def68c2bd	willia_schaefer_380	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.929837	2021-11-19 14:20:43.929837	\N	fdfbd521-1e36-44bb-bc2b-d0835f0dea66	\N	Terence Beatty	ali@wiegand-ritchie.io	t	107	\N
19c3acc9-2d61-4bea-96ba-2c23606b7521	elias_293	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.961762	2021-11-19 14:20:43.961762	\N	a6dcda91-7e51-4ba6-86c7-2696cab7c6b2	\N	Phillip Grady	rolf@mclaughlin-damore.io	t	2453773	\N
bb130757-b8db-4d09-88a9-43a10e47d17b	russell_117	\N	\N	0	\N	\N	\N	\N	2021-11-19 14:20:43.991544	2021-11-19 14:20:43.991544	\N	78c02d96-62be-4bfb-b86d-6cf290457cbf	\N	Rolf Bode	min.ryan@huels.info	t	954474	\N
0ba322d0-ef1c-42c5-98e1-a0b45cff7415	malia_keebler_984	\N	\N	1	2021-11-29 10:46:03.925057	2021-11-29 10:46:03.925057	35.176.93.186	35.176.93.186	2021-11-19 14:20:43.815454	2021-11-29 10:46:03.925234	\N	73d33890-8f61-4cfa-9047-e2d572949707	\N	Clarence Okuneva V	roosevelt.stoltenberg@mraz.co	t	109	\N
db9e082e-9f15-4a6b-b7a8-fcad3c160bce	tyree.langworth_180	\N	\N	2	2021-11-30 17:37:07.284938	2021-11-29 14:27:23.642706	81.134.202.29	81.134.202.29	2021-11-19 14:20:43.889517	2021-11-30 17:37:07.285142	\N	f2cc38bb-e623-4412-979f-7861cf3ca2f9	bab2665d-4b70-45a8-87f7-2b3f30880dba	Amb. Felton Bayer	lavonia.medhurst@larson-lynch.biz	t	494000	\N
31f3206c-2ae4-4b1f-9f3c-59a495861758	brunilda_822	\N	\N	2	2021-12-01 08:27:16.90824	2021-11-30 16:55:05.425723	82.29.235.75	81.134.202.29	2021-11-19 14:20:43.499292	2021-12-01 08:27:16.908466	\N	089b56d1-ac17-4b88-9ba5-3ac5d93b02cc	ae18ef37-4a88-46a3-a43a-8d58fea33b43	Deandre Trantow	jesse_rempel@deckow.biz	t	100	\N
\.


--
-- Data for Name: savings_amounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.savings_amounts (id, legal_aid_application_id, offline_current_accounts, cash, other_person_account, national_savings, plc_shares, peps_unit_trusts_capital_bonds_gov_stocks, life_assurance_endowment_policy, created_at, updated_at, none_selected, offline_savings_accounts, no_account_selected) FROM stdin;
622f7608-6223-43f3-bd32-0ce78fb76273	db61619d-b102-4781-aaaa-fce80d065aeb	\N	\N	\N	\N	\N	\N	\N	2021-11-30 16:56:45.606064	2021-11-30 16:56:47.788849	t	\N	t
5fa16d66-e38d-46a8-a685-8abebd85705d	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	\N	\N	\N	\N	\N	\N	\N	2021-11-30 17:38:49.542025	2021-11-30 17:38:51.9403	t	\N	t
\.


--
-- Data for Name: scheduled_mailings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scheduled_mailings (id, legal_aid_application_id, mailer_klass, mailer_method, arguments, scheduled_at, sent_at, cancelled_at, created_at, updated_at, status, addressee, govuk_message_id) FROM stdin;
105dbc7c-e51d-418d-86a0-6f8e3d160124	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	SubmitApplicationReminderMailer	notify_provider	{}	2021-12-21 09:00:00	\N	\N	2021-11-30 17:38:00.059982	2021-11-30 17:38:00.059982	waiting	emilio_emmerich@gleason.biz	\N
4b40dd3c-41f7-4e47-b462-92b89b90ec55	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	SubmitApplicationReminderMailer	notify_provider	{}	2021-12-30 09:00:00	\N	\N	2021-11-30 17:38:00.064918	2021-11-30 17:38:00.064918	waiting	clifford_steuber@tromp-rippin.org	\N
8ecf759e-3108-44c6-b75b-1d8de3c2476e	db61619d-b102-4781-aaaa-fce80d065aeb	SubmissionConfirmationMailer	notify	{}	2021-11-30 16:57:21.498902	2021-11-30 16:58:37.0846	\N	2021-11-30 16:57:21.590962	2021-12-01 07:16:10.929283	temporary-failure	earlene@crooks.com	349e5470-5a8d-478d-8972-2e4c24728c56
c8a5ab57-3f11-482f-b097-b16f3f1189e2	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	SubmissionConfirmationMailer	notify	{}	2021-11-30 17:39:36.533711	2021-11-30 17:39:36.662938	\N	2021-11-30 17:39:36.534117	2021-12-01 08:11:32.001937	temporary-failure	leora@keeling.org	da4fe9c0-b523-4796-bdaf-944cd909892d
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version) FROM stdin;
20180807211758
20180820112730
20180821121644
20180821122427
20180829144026
20180829150801
20180911143012
20180913101947
20180913103146
20180917084624
20180929123828
20181011143410
20181017202608
20181018165257
20181018165405
20181018165537
20181030114511
20181101105424
20181101115246
20181107093419
20181107110620
20181108115540
20181109095753
20181113153145
20181120154510
20181120160942
20181123192102
20181126110330
20181129140032
20181205111854
20181205130016
20181205144814
20181206100314
20181206132736
20181206142708
20181207162049
20181207162311
20181210152857
20181211125447
20181214143356
20190102151638
20190109114728
20190110104254
20190122115534
20190123111544
20190123151412
20190123151514
20190124113350
20190124135128
20190124140446
20190128091816
20190128101016
20190129120515
20190130110634
20190205134535
20190208101554
20190214143628
20190214170843
20190214171720
20190219134617
20190219134900
20190219150642
20190222134743
20190301131852
20190301141732
20190305152510
20190307104610
20190313174812
20190315113315
20190315133344
20190319145411
20190326093632
20190328155542
20190329154206
20190403151300
20190405151933
20190417130107
20190424092935
20190424181011
20190425131605
20190425143403
20190501123416
20190514142921
20190514212618
20190515141352
20190516094442
20190523115648
20190524142923
20190524143312
20190529090545
20190529164413
20190611120953
20190611134522
20190617075535
20190617093116
20190617103359
20190627074728
20190627143244
20190628120413
20190628122520
20190701120930
20190702144049
20190704130740
20190704131448
20190704160038
20190705091659
20190705150936
20190708151000
20190711135901
20190712133912
20190716081338
20190723083236
20190723142529
20190723142558
20190723142637
20190725093333
20190725130335
20190725130416
20190729100046
20190729100602
20190806115955
20190808094323
20190812135413
20190820154405
20190823093923
20190827122038
20190827131229
20190828131221
20190828131723
20190828133153
20190903092600
20190904151326
20190909095604
20190909101523
20190911150223
20190913092309
20190918102038
20190925095224
20190925105003
20191007141353
20191011142505
20191018174252
20191025134729
20191025135501
20191025135756
20191025151150
20191114151820
20191114152212
20191114193807
20191118142348
20191120104919
20191121143142
20191206104140
20200106094725
20200106113041
20200108162334
20200117163347
20200207133614
20200210162352
20200221145049
20200225140642
20200310162254
20200319152301
20200327115015
20200327115101
20200327171336
20200408135701
20200410144915
20200501010350
20200501083631
20200501103020
20200610213903
20200611123802
20200616135325
20200619123658
20200625135809
20200702122054
20200708102815
20200709112844
20200709135901
20200723102331
20200724083605
20200728081000
20200729140115
20200803154318
20200813132316
20200903165732
20200917082925
20200921143900
20201005152150
20201006122951
20201020100508
20201022121901
20201023142248
20201023220052
20201026115759
20201029080226
20201102133306
20201105112815
20201112101449
20201119125243
20201125154924
20201125195145
20201127134906
20201130151951
20201210161115
20201214114038
20201214114039
20201215120821
20201215170558
20210106155819
20210112103855
20210115142828
20210115142908
20210115155032
20210126151112
20210201130345
20210218165806
20210222105725
20210223134124
20210226133024
20210302142433
20210303231303
20210305123318
20210305145638
20210309111908
20210312110904
20210315164353
20210319110509
20210322122007
20210323113558
20210323153440
20210324140533
20210401124208
20210401124219
20210401155950
20210407081304
20210407120727
20210408162032
20210409102038
20210420092148
20210421094326
20210423180431
20210429174354
20210518095337
20210518114357
20210520071320
20210524143755
20210601084320
20210602110352
20210602114709
20210616092032
20210621100811
20210624124911
20210624130422
20210712112003
20210720115125
20210805072930
20210901160225
20210913102726
20210913110123
20210929152348
20211004135707
20211008094818
20211008094831
20211015111515
20211020093729
20211025135348
20211026175246
20211102100659
20211102101801
20211103105546
20211103112548
20211103151811
20211104141141
20211105083833
20211112174848
\.


--
-- Data for Name: scope_limitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scope_limitations (id, code, meaning, description, substantive, delegated_functions, created_at, updated_at) FROM stdin;
08087b36-fb3d-48e1-8016-23e02371f4ee	AA009	Warrant of arrest FLA	As to an order under Part IV Family Law Act 1996 limited to an application for the issue of a warrant of arrest.	t	t	2021-11-19 14:20:42.434092	2021-11-19 14:20:42.434092
88b81660-1261-4a8a-857e-316a177f8d0f	AA019	Injunction FLA-to final hearing	As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).	t	f	2021-11-19 14:20:42.441009	2021-11-19 14:20:42.441009
ddf744f2-58dd-4ddd-9e64-0b62154fc6bc	AA028	Interim Order (Emergency only) FGM	As to an application under the Female Genital Mutilation Act 2003 limited to all steps necessary to apply for an interim order where application is made without notice to include representation on the return date.	t	t	2021-11-19 14:20:42.447274	2021-11-19 14:20:42.447274
ba5a8865-a3bc-4f3e-bb50-fd504bfab9bc	AA029	Hearing (Emergency only) FGM	As to application under the Female Genital Mutilation Act 2003 limited to all steps up to and including the hearing on [date]	t	t	2021-11-19 14:20:42.45397	2021-11-19 14:20:42.45397
8f714715-06d5-4a5c-ab7a-ee01c76fe681	AA030	Injunction-FGM-to final hearing	As to proceedings under the Female Genital Mutilation Act 2003 limited to all steps up to and including obtaining and service a final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).	t	f	2021-11-19 14:20:42.460227	2021-11-19 14:20:42.460227
87d1119e-150d-4a69-b325-90529d4bdd90	AA031	Vary/dscg/rvke FGM Protection Order	As to an order under Female Genital Mutilation Act 2003 limited to an application to extend/vary or discharge.	t	t	2021-11-19 14:20:42.466525	2021-11-19 14:20:42.466525
4ee77412-13b9-4490-a184-b892d54ccf9b	AA032	Overseas applicant-FGMPO	Limited where the applicant is overseas, to their return to the jurisdiction and thereafter a solicitor's report.	t	t	2021-11-19 14:20:42.472885	2021-11-19 14:20:42.472885
c53c0b46-c667-401b-898c-ebf466e2af01	CV027	Hearing/Adjournment	Limited to all steps (including any adjournment thereof) up to and including the hearing on [date]	t	t	2021-11-19 14:20:42.478874	2021-11-19 14:20:42.478874
f17397a3-7a5d-4ca1-ba5d-59d0d30151db	CV079	Counsel's Opinion	Limited to obtaining external Counsel's Opinion or the opinion of an external solicitor with higher court advocacy rights on the information already available.	t	t	2021-11-19 14:20:42.485038	2021-11-19 14:20:42.485038
fd47c785-5d3e-4f26-881e-4133f3ae4d88	CV117	Interim order inc. return date	Limited to all steps necessary to apply for an interim order; where application is made without notice to include representation on the return date.	t	t	2021-11-19 14:20:42.491149	2021-11-19 14:20:42.491149
6e16fb95-c80f-460d-a654-27a3bb29144c	CV118	Hearing	Limited to all steps up to and including the hearing on [see additional limitation notes]	t	t	2021-11-19 14:20:42.497926	2021-11-19 14:20:42.497926
4b0eacd0-5a90-42d9-b0a1-569946f311d3	CV128	Counsel's opinion-merits, quantum, and cost benefit	Limited to obtaining counsel's opinion or the opinion of an external solicitor with higher court advocacy rights particularly in regard to the merits, quantum, and cost benefit of the action.	t	t	2021-11-19 14:20:42.504194	2021-11-19 14:20:42.504194
39809e9f-9ab2-4320-a9c1-b55e7bde63fd	CV129	Counsel's opinion-merits	Limited to obtaining counsel's opinion or the opinion of an external solicitor with higher court advocacy rights particularly in regard to the merits of the case.	t	t	2021-11-19 14:20:42.510355	2021-11-19 14:20:42.510355
2fe525fe-4e54-4634-a595-6c32be0de7cf	FM054	Overseas applicant (forced marriage)	Limited where the applicant is overseas, to their return to the jurisdiction and thereafter a solicitor's report	t	t	2021-11-19 14:20:42.516762	2021-11-19 14:20:42.516762
914184d4-1f44-42d6-b071-5e3e603f7cfd	FM062	Final hearing	Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order.	t	f	2021-11-19 14:20:42.523459	2021-11-19 14:20:42.523459
935309cc-326c-4fec-9f37-0547c618788d	FM059	FHH Children	Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement. To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.	t	f	2021-11-19 14:20:42.529804	2021-11-19 14:20:42.529804
\.


--
-- Data for Name: secure_data; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.secure_data (id, data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: service_levels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_levels (id, service_level_number, name, created_at, updated_at) FROM stdin;
5d686ef7-47b9-47ac-9ab6-5946b08e106e	3	Full representation	2021-11-19 14:20:20.916289	2021-11-19 14:20:20.916289
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.settings (id, created_at, updated_at, mock_true_layer_data, manually_review_all_cases, bank_transaction_filename, allow_welsh_translation, enable_ccms_submission, alert_via_sentry, digest_extracted_at, enable_employed_journey) FROM stdin;
57959b2c-6596-4c64-9aee-dd7b0f381977	2021-11-20 02:00:43.43233	2021-12-02 02:00:40.409378	f	t	db/sample_data/bank_transactions.csv	f	t	t	2021-12-02 02:00:40.107772	f
\.


--
-- Data for Name: state_machine_proxies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.state_machine_proxies (id, legal_aid_application_id, type, aasm_state, created_at, updated_at, ccms_reason) FROM stdin;
30a8c628-f7b8-451d-bf44-50a6201b7b77	bf37635d-8cf5-4a8a-8e59-76480b91d2bc	PassportedStateMachine	entering_applicant_details	2021-11-29 14:27:39.681709	2021-11-29 14:27:42.257536	\N
316ddd32-0ca5-4f94-8cd2-2d11e1f4c3ce	db61619d-b102-4781-aaaa-fce80d065aeb	PassportedStateMachine	submitting_assessment	2021-11-30 16:55:39.194661	2021-11-30 16:57:24.549818	\N
d015d4d2-4678-4d1f-8e59-ca8da735adc2	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	PassportedStateMachine	assessment_submitted	2021-11-30 17:37:39.444395	2021-11-30 17:40:41.020915	\N
\.


--
-- Data for Name: statement_of_cases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.statement_of_cases (id, legal_aid_application_id, statement, created_at, updated_at, provider_uploader_id) FROM stdin;
62bf0528-405a-437a-b4ef-9d4759f3b999	db61619d-b102-4781-aaaa-fce80d065aeb	Quibusdam odit iusto minus.	2021-11-30 16:57:14.776373	2021-11-30 16:57:14.776373	31f3206c-2ae4-4b1f-9f3c-59a495861758
2a028826-7e87-4ad0-92e3-836710395e07	f6ab5c93-48e2-48ee-87bb-e1d0a4124799	Necessitatibus est voluptas perferendis.	2021-11-30 17:39:27.684644	2021-11-30 17:39:27.684644	db9e082e-9f15-4a6b-b7a8-fcad3c160bce
\.


--
-- Data for Name: transaction_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction_types (id, name, operation, created_at, updated_at, sort_order, archived_at, other_income, parent_id) FROM stdin;
c8d58f54-57ca-48e8-8f72-eabca71b8c5a	benefits	credit	2021-11-19 14:20:16.481948	2021-11-19 14:20:16.481948	0	\N	f	\N
eba35e10-d48c-4558-8cf9-75df81260a3d	rent_or_mortgage	debit	2021-11-19 14:20:16.507326	2021-11-19 14:20:16.507326	1000	\N	f	\N
061aaf43-1a43-48e9-b3ee-4816ea681d81	child_care	debit	2021-11-19 14:20:16.510757	2021-11-19 14:20:16.510757	1010	\N	f	\N
58936c74-9c4a-43c7-9a1a-82233c624330	maintenance_out	debit	2021-11-19 14:20:16.514228	2021-11-19 14:20:16.514228	1020	\N	f	\N
b8754820-4277-4a0f-bb56-702020e68a64	legal_aid	debit	2021-11-19 14:20:16.517754	2021-11-19 14:20:16.517754	1030	\N	f	\N
87e41273-e598-44d2-8358-5d00decf0838	friends_or_family	credit	2021-11-19 14:20:16.489859	2021-11-19 14:20:16.489859	20	\N	t	\N
5bd13921-35cf-48b5-a5d3-773a599cf47f	maintenance_in	credit	2021-11-19 14:20:16.493327	2021-11-19 14:20:16.493327	30	\N	t	\N
4d387d23-8b05-4547-99c5-62f1e5818cd2	property_or_lodger	credit	2021-11-19 14:20:16.496774	2021-11-19 14:20:16.496774	40	\N	t	\N
72a594db-c1b1-4085-b59e-0f12f919d5a4	private_pension	credit	2021-11-19 14:20:16.503718	2021-11-19 14:20:23.940513	60	2021-11-19 14:20:23.938459	f	\N
e52f41cd-aac2-4de9-b0f9-1ce75d09ccc8	pension	credit	2021-11-19 14:20:23.925794	2021-11-19 14:20:23.948806	60	\N	t	\N
95a0757b-2938-4252-88e1-b4d4f8a1269c	student_loan	credit	2021-11-19 14:20:16.500222	2021-12-02 13:44:06.316943	50	2021-12-02 13:44:06.316735	t	\N
920215dd-f006-40ce-bcf7-02f61b26cf20	excluded_benefits	credit	2021-11-19 14:20:16.486032	2021-12-02 13:44:06.327046	10	\N	f	c8d58f54-57ca-48e8-8f72-eabca71b8c5a
\.


--
-- Data for Name: true_layer_banks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.true_layer_banks (id, banks, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicles (id, estimated_value, payment_remaining, purchased_on, used_regularly, legal_aid_application_id, created_at, updated_at, more_than_three_years_old) FROM stdin;
\.


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 1, false);


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
-- Name: application_proceeding_types_linked_children application_proceeding_types_involved_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_proceeding_types_linked_children
    ADD CONSTRAINT application_proceeding_types_involved_children_pkey PRIMARY KEY (id);


--
-- Name: application_proceeding_types application_proceeding_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_proceeding_types
    ADD CONSTRAINT application_proceeding_types_pkey PRIMARY KEY (id);


--
-- Name: application_proceeding_types_scope_limitations application_proceeding_types_scope_limitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_proceeding_types_scope_limitations
    ADD CONSTRAINT application_proceeding_types_scope_limitations_pkey PRIMARY KEY (id);


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
-- Name: data_migrations data_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_migrations
    ADD CONSTRAINT data_migrations_pkey PRIMARY KEY (version);


--
-- Name: debugs debugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debugs
    ADD CONSTRAINT debugs_pkey PRIMARY KEY (id);


--
-- Name: default_cost_limitations default_cost_limitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_cost_limitations
    ADD CONSTRAINT default_cost_limitations_pkey PRIMARY KEY (id);


--
-- Name: dependants dependants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependants
    ADD CONSTRAINT dependants_pkey PRIMARY KEY (id);


--
-- Name: dwp_overrides dwp_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dwp_overrides
    ADD CONSTRAINT dwp_overrides_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: firms firms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firms
    ADD CONSTRAINT firms_pkey PRIMARY KEY (id);


--
-- Name: gateway_evidences gateway_evidences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gateway_evidences
    ADD CONSTRAINT gateway_evidences_pkey PRIMARY KEY (id);


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
-- Name: involved_children involved_children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.involved_children
    ADD CONSTRAINT involved_children_pkey PRIMARY KEY (id);


--
-- Name: irregular_incomes irregular_incomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.irregular_incomes
    ADD CONSTRAINT irregular_incomes_pkey PRIMARY KEY (id);


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
-- Name: malware_scan_results malware_scan_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.malware_scan_results
    ADD CONSTRAINT malware_scan_results_pkey PRIMARY KEY (id);


--
-- Name: chances_of_successes merits_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chances_of_successes
    ADD CONSTRAINT merits_assessments_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: other_assets_declarations other_assets_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.other_assets_declarations
    ADD CONSTRAINT other_assets_declarations_pkey PRIMARY KEY (id);


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
-- Name: proceeding_type_scope_limitations proceeding_type_scope_limitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proceeding_type_scope_limitations
    ADD CONSTRAINT proceeding_type_scope_limitations_pkey PRIMARY KEY (id);


--
-- Name: proceeding_types proceeding_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proceeding_types
    ADD CONSTRAINT proceeding_types_pkey PRIMARY KEY (id);


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
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: opponents respondents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opponents
    ADD CONSTRAINT respondents_pkey PRIMARY KEY (id);


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
-- Name: secure_data secure_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secure_data
    ADD CONSTRAINT secure_data_pkey PRIMARY KEY (id);


--
-- Name: service_levels service_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_levels
    ADD CONSTRAINT service_levels_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


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

CREATE UNIQUE INDEX cash_transactions_unique ON public.cash_transactions USING btree (legal_aid_application_id, transaction_type_id, month_number);


--
-- Name: idx_lfa_merits_task_lists_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lfa_merits_task_lists_on_legal_aid_application_id ON public.legal_framework_merits_task_lists USING btree (legal_aid_application_id);


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
-- Name: index_application_proceeding_involved_children; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_application_proceeding_involved_children ON public.application_proceeding_types_linked_children USING btree (application_proceeding_type_id, involved_child_id);


--
-- Name: index_application_proceeding_scope_limitation; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_application_proceeding_scope_limitation ON public.application_proceeding_types_scope_limitations USING btree (type, application_proceeding_type_id, scope_limitation_id);


--
-- Name: index_application_proceeding_types_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_application_proceeding_types_on_legal_aid_application_id ON public.application_proceeding_types USING btree (legal_aid_application_id);


--
-- Name: index_application_proceeding_types_on_proceeding_case_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_application_proceeding_types_on_proceeding_case_id ON public.application_proceeding_types USING btree (proceeding_case_id);


--
-- Name: index_application_proceeding_types_on_proceeding_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_application_proceeding_types_on_proceeding_type_id ON public.application_proceeding_types USING btree (proceeding_type_id);


--
-- Name: index_attempts_to_settles_on_application_proceeding_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attempts_to_settles_on_application_proceeding_type_id ON public.attempts_to_settles USING btree (application_proceeding_type_id);


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
-- Name: index_chances_of_successes_on_application_proceeding_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chances_of_successes_on_application_proceeding_type_id ON public.chances_of_successes USING btree (application_proceeding_type_id);


--
-- Name: index_chances_of_successes_on_proceeding_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chances_of_successes_on_proceeding_id ON public.chances_of_successes USING btree (proceeding_id);


--
-- Name: index_default_cost_limitations_on_proceeding_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_default_cost_limitations_on_proceeding_type_id ON public.default_cost_limitations USING btree (proceeding_type_id);


--
-- Name: index_dependants_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dependants_on_legal_aid_application_id ON public.dependants USING btree (legal_aid_application_id);


--
-- Name: index_dwp_overrides_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_dwp_overrides_on_legal_aid_application_id ON public.dwp_overrides USING btree (legal_aid_application_id);


--
-- Name: index_gateway_evidences_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gateway_evidences_on_legal_aid_application_id ON public.gateway_evidences USING btree (legal_aid_application_id);


--
-- Name: index_gateway_evidences_on_provider_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gateway_evidences_on_provider_uploader_id ON public.gateway_evidences USING btree (provider_uploader_id);


--
-- Name: index_hmrc_responses_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hmrc_responses_on_legal_aid_application_id ON public.hmrc_responses USING btree (legal_aid_application_id);


--
-- Name: index_incidents_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incidents_on_legal_aid_application_id ON public.incidents USING btree (legal_aid_application_id);


--
-- Name: index_involved_child_proceeding; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_involved_child_proceeding ON public.proceedings_linked_children USING btree (involved_child_id, proceeding_id);


--
-- Name: index_involved_children_application_proceeding; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_involved_children_application_proceeding ON public.application_proceeding_types_linked_children USING btree (involved_child_id, application_proceeding_type_id);


--
-- Name: index_involved_children_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_involved_children_on_legal_aid_application_id ON public.involved_children USING btree (legal_aid_application_id);


--
-- Name: index_legal_aid_applications_on_applicant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_aid_applications_on_applicant_id ON public.legal_aid_applications USING btree (applicant_id);


--
-- Name: index_legal_aid_applications_on_application_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_legal_aid_applications_on_application_ref ON public.legal_aid_applications USING btree (application_ref);


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
-- Name: index_malware_scan_results_on_uploader; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_malware_scan_results_on_uploader ON public.malware_scan_results USING btree (uploader_type, uploader_id);


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
-- Name: index_opponents_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_opponents_on_legal_aid_application_id ON public.opponents USING btree (legal_aid_application_id);


--
-- Name: index_other_assets_declarations_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_other_assets_declarations_on_legal_aid_application_id ON public.other_assets_declarations USING btree (legal_aid_application_id);


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
-- Name: index_proceeding_type_scope_limitations_on_proceeding_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proceeding_type_scope_limitations_on_proceeding_type_id ON public.proceeding_type_scope_limitations USING btree (proceeding_type_id);


--
-- Name: index_proceeding_type_scope_limitations_on_scope_limitation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proceeding_type_scope_limitations_on_scope_limitation_id ON public.proceeding_type_scope_limitations USING btree (scope_limitation_id);


--
-- Name: index_proceeding_types_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proceeding_types_on_code ON public.proceeding_types USING btree (code);


--
-- Name: index_proceeding_types_on_default_service_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proceeding_types_on_default_service_level_id ON public.proceeding_types USING btree (default_service_level_id);


--
-- Name: index_proceedings_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proceedings_on_legal_aid_application_id ON public.proceedings USING btree (legal_aid_application_id);


--
-- Name: index_proceedings_scopes_unique_delegated_default; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_proceedings_scopes_unique_delegated_default ON public.proceeding_type_scope_limitations USING btree (proceeding_type_id, delegated_functions_default) WHERE (delegated_functions_default = true);


--
-- Name: index_proceedings_scopes_unique_on_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_proceedings_scopes_unique_on_ids ON public.proceeding_type_scope_limitations USING btree (proceeding_type_id, scope_limitation_id);


--
-- Name: index_proceedings_scopes_unique_substantive_default; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_proceedings_scopes_unique_substantive_default ON public.proceeding_type_scope_limitations USING btree (proceeding_type_id, substantive_default) WHERE (substantive_default = true);


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
-- Name: index_savings_amounts_on_legal_aid_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_savings_amounts_on_legal_aid_application_id ON public.savings_amounts USING btree (legal_aid_application_id);


--
-- Name: index_scope_limitation_application_proceeding; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scope_limitation_application_proceeding ON public.application_proceeding_types_scope_limitations USING btree (scope_limitation_id, application_proceeding_type_id);


--
-- Name: index_scope_limitations_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scope_limitations_on_code ON public.scope_limitations USING btree (code);


--
-- Name: index_service_levels_on_service_level_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_levels_on_service_level_number ON public.service_levels USING btree (service_level_number);


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
-- Name: textsearch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX textsearch_idx ON public.proceeding_types USING gin (textsearchable);


--
-- Name: attempts_to_settles fk_rails_010ab97abe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attempts_to_settles
    ADD CONSTRAINT fk_rails_010ab97abe FOREIGN KEY (application_proceeding_type_id) REFERENCES public.application_proceeding_types(id);


--
-- Name: application_proceeding_types fk_rails_0d6eacf79b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_proceeding_types
    ADD CONSTRAINT fk_rails_0d6eacf79b FOREIGN KEY (proceeding_type_id) REFERENCES public.proceeding_types(id);


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
-- Name: scheduled_mailings fk_rails_1a034d34c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_mailings
    ADD CONSTRAINT fk_rails_1a034d34c3 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id) ON DELETE CASCADE;


--
-- Name: chances_of_successes fk_rails_347570dfaa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chances_of_successes
    ADD CONSTRAINT fk_rails_347570dfaa FOREIGN KEY (application_proceeding_type_id) REFERENCES public.application_proceeding_types(id);


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
-- Name: gateway_evidences fk_rails_44101dd0cd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gateway_evidences
    ADD CONSTRAINT fk_rails_44101dd0cd FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


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
-- Name: opponents fk_rails_6202c21351; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opponents
    ADD CONSTRAINT fk_rails_6202c21351 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: bank_errors fk_rails_68a2610735; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_errors
    ADD CONSTRAINT fk_rails_68a2610735 FOREIGN KEY (applicant_id) REFERENCES public.applicants(id);


--
-- Name: chances_of_successes fk_rails_7549c96c78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chances_of_successes
    ADD CONSTRAINT fk_rails_7549c96c78 FOREIGN KEY (proceeding_id) REFERENCES public.proceedings(id);


--
-- Name: legal_framework_merits_task_lists fk_rails_7e5016e4d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_merits_task_lists
    ADD CONSTRAINT fk_rails_7e5016e4d1 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: involved_children fk_rails_84782c3371; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.involved_children
    ADD CONSTRAINT fk_rails_84782c3371 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


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
-- Name: bank_account_holders fk_rails_a0f80d0f18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_account_holders
    ADD CONSTRAINT fk_rails_a0f80d0f18 FOREIGN KEY (bank_provider_id) REFERENCES public.bank_providers(id);


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
-- Name: default_cost_limitations fk_rails_c42d332697; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.default_cost_limitations
    ADD CONSTRAINT fk_rails_c42d332697 FOREIGN KEY (proceeding_type_id) REFERENCES public.proceeding_types(id);


--
-- Name: benefit_check_results fk_rails_d026359e92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benefit_check_results
    ADD CONSTRAINT fk_rails_d026359e92 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: legal_framework_submissions fk_rails_daf85484ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_framework_submissions
    ADD CONSTRAINT fk_rails_daf85484ba FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


--
-- Name: application_proceeding_types fk_rails_dfcc175535; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_proceeding_types
    ADD CONSTRAINT fk_rails_dfcc175535 FOREIGN KEY (legal_aid_application_id) REFERENCES public.legal_aid_applications(id);


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
-- Name: statement_of_cases fk_rails_efb816a921; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statement_of_cases
    ADD CONSTRAINT fk_rails_efb816a921 FOREIGN KEY (provider_uploader_id) REFERENCES public.providers(id);


--
-- Name: providers fk_rails_f9affe4236; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT fk_rails_f9affe4236 FOREIGN KEY (selected_office_id) REFERENCES public.offices(id);


--
-- PostgreSQL database dump complete
--

