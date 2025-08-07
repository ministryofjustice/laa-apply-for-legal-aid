{{/* vim: set filetype=mustache: */}}
{{/*
Environment variables for web and worker containers
*/}}
{{- define "apply-for-legal-aid.envs" }}
env:
  {{ if .Values.postgresql.enabled }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: postgresqlUsername
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: postgresqlPassword
  - name: POSTGRES_HOST
    value: {{ printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" }}
  - name: POSTGRES_DATABASE
    value: {{ .Values.postgresql.auth.Database | quote }}
  {{ else }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-rds-instance-output
        key: database_username
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-rds-instance-output
        key: database_password
  - name: POSTGRES_HOST
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-rds-instance-output
        key: rds_instance_address
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-rds-instance-output
        key: database_name
  {{ end }}
  {{ if .Values.admin.allowAdminPassword }}
  - name: ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: adminPassword
  {{ end }}
  - name: GOVUK_NOTIFY_API_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: govukNotifyApiKey
  - name: ORDNANCE_SURVEY_API_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: ordnanceSurveyApiKey
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: secretKeyBase
  - name: SENTRY_DSN
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: sentryDsn
  - name: RAILS_ENV
    value: production
  - name: RAILS_LOG_TO_STDOUT
    value: "true"
  - name: HOST
    value: {{ .Values.deploy.host | quote }}
  - name: BC_LSC_SERVICE_NAME
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: benefitCheckerLscServiceName
  - name: BC_CLIENT_ORG_ID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: benefitCheckerClientOrgId
  - name: BC_CLIENT_USER_ID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: benefitCheckerClientUserId
  - name: BC_WSDL_URL
    value: {{ .Values.benefit_checker.wsdlUrl | quote }}
  - name: CCMS_SOA_SUBMIT_APPLICATIONS
    value: {{ .Values.ccms_soa.submit_applications | quote }}
  - name: CCMS_SOA_CLIENT_USERNAME
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: ccmsSoaClientUsername
  - name: CCMS_SOA_CLIENT_PASSWORD_TYPE
    value: {{ .Values.ccms_soa.clientPasswordType | quote }}
  - name: CCMS_SOA_CLIENT_PASSWORD
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: ccmsSoaClientPassword
  - name: CCMS_SOA_USER_ROLE
    value: {{ .Values.ccms_soa.userRole | quote }}
  - name: CCMS_SOA_CASE_SERVICES_WSDL
    value: {{ .Values.ccms_soa.caseServicesWsdl | quote }}
  - name: CCMS_SOA_CLIENT_PROXY_SERVICE_WSDL
    value: {{ .Values.ccms_soa.clientProxyServiceWsdl | quote }}
  - name: CCMS_SOA_DOCUMENT_SERVICES_WSDL
    value: {{ .Values.ccms_soa.documentServicesWsdl | quote }}
  - name: CCMS_SOA_GET_REFERENCE_DATA_WSDL
    value: {{ .Values.ccms_soa.getReferenceDataWsdl | quote }}
  - name: OMNIAUTH_ENTRAID_MOCK_AUTH
    value: {{ .Values.omniauth_entraid.mock_auth | quote }}
  - name: OMNIAUTH_ENTRAID_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: omniauthAzureClientID
  - name: OMNIAUTH_ENTRAID_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: omniauthAzureClientSecret
  - name: OMNIAUTH_ENTRAID_TENANT_ID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: omniauthAzureTenantID
  - name: OMNIAUTH_ENTRAID_REDIRECT_URI
    value: {{ .Values.branch_builder.omniauth_azure_redirect_uri }}
  - name: PROVIDER_DETAILS_URL
    value: {{ .Values.provider_details.url | quote }}
  - name: PDA_URL
    value: {{ .Values.pda.url | quote }}
  - name: PDA_AUTH_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: pdaAuthKey
  - name: TRUE_LAYER_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: trueLayerClientId
  - name: TRUE_LAYER_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: trueLayerClientSecret
  - name: TRUE_LAYER_ENABLE_MOCK
    value: {{ .Values.trueLayer.enableMock | quote }}
  - name: GOOGLE_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: googleClientId
  - name: GOOGLE_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: googleClientSecret
  - name: SIDEKIQ_WEB_UI_PASSWORD
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: sidekiqWebUiPassword
  {{ if .Values.redis.enabled }}
  - name: REDIS_PROTOCOL
    value: "redis"
  - name: REDIS_HOST
    value: {{ template "apply-for-legal-aid.redis-uat-host" . }}
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: redisPassword
  {{ else }}
  - name: REDIS_HOST
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-elasticache-instance-output
        key: primary_endpoint_address
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-elasticache-instance-output
        key: auth_token
  {{ end }}
  - name: S3_BUCKET
    valueFrom:
      secretKeyRef:
        name: apply-for-legal-aid-s3-instance-output
        key: bucket_name
  - name: ADMIN_ALLOW_RESET
    value: {{ .Values.admin.allowReset | quote }}
  - name: ADMIN_ALLOW_CREATE_TEST_APPLICATIONS
    value: {{ .Values.admin.allowCreateTestApplications | quote }}
  - name: GOOGLE_TAG_MANAGER_TRACKING_ID
    value: {{ .Values.google_tag_manager.trackingId | quote }}
  - name: KUBERNETES_DEPLOYMENT
    value: "true"
  - name: METRICS_SERVICE_HOST
    value: {{ template "apply-for-legal-aid.fullname" . }}-metrics
  - name: CFE_CIVIL_HOST
    value: {{ .Values.checkFinancialEligibility.civil_host | quote }}
  - name: APPLY_EMAIL
    value: {{ .Values.email_domain.suffix | quote }}
  - name: ADMIN_SHOW_FORM
    value: {{ .Values.admin.showForm | quote }}
  - name: POLICY_DISREGARDS_START_DATE
    value: {{ .Values.policy_disregards_start_date | quote }}
  - name: MTR_A_START_DATE
    value: {{ .Values.mtr_a_start_date | quote }}
  - name: LEGAL_FRAMEWORK_API_HOST
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: legalFrameworkApiHost
  - name: LEGAL_FRAMEWORK_API_HOST_JS
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: legalFrameworkApiHostJS
  - name: SLACK_ALERT_EMAIL
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: slackAlertEmail
  - name: HMRC_API_HOST
    value: {{ .Values.hmrc_interface.host | quote  }}
  - name: HMRC_API_UID
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: hmrcApiUid
  - name: HMRC_API_SECRET
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: hmrcApiSecret
  - name: HMRC_DURATION_CHECK
    value: {{ .Values.hmrc_interface.duration | quote  }}
  - name: HMRC_USE_DEV_MOCK
    value: {{ .Values.hmrc_interface.hmrc_use_dev_mock | quote  }}
  - name: RESEARCH_PANEL_FORM_LINK
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: researchLink
  - name: ENCRYPTION_PRIMARY_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: encryptionPrimaryKey
  - name: ENCRYPTION_DETERMINISTIC_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: encryptionDeterministicKey
  - name: ENCRYPTION_KEY_DERIVATION_SALT
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: encryptionKeyDerivationSalt
  - name: MAINTENANCE_MODE
    value: {{ .Values.maintenance_mode.enabled | quote  }}
  - name: SLACK_ALERT_WEBHOOK
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: slackAlertWebhook
  - name: COLLECT_HMRC_DATA
    value: {{ .Values.collect_hmrc_data.enabled | quote  }}
  - name: CLAMD_CONF_FILENAME
    value: {{ .Values.clamav.configFile }}
{{- end }}
