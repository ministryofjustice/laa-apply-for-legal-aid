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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: postgresqlDatabase
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: deployHost
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: benefitCheckerWsdlUrl
  - name: CCMS_SOA_SUBMIT_APPLICATIONS
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaSubmitApplications
  - name: CCMS_SOA_AWS_GATEWAY_API_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: ccmsSoaAwsGatewayApiKey
  - name: CCMS_SOA_CLIENT_USERNAME
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: ccmsSoaClientUsername
  - name: CCMS_SOA_CLIENT_PASSWORD_TYPE
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaClientPasswordType
  - name: CCMS_SOA_CLIENT_PASSWORD
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: ccmsSoaClientPassword
  - name: CCMS_SOA_USER_ROLE
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaUserRole
  - name: CCMS_SOA_CASE_SERVICES_WSDL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaCaseServicesWsdl
  - name: CCMS_SOA_CLIENT_PROXY_SERVICE_WSDL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaClientProxyServiceWsdl
  - name: CCMS_SOA_DOCUMENT_SERVICES_WSDL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaDocumentServicesWsdl
  - name: CCMS_SOA_GET_REFERENCE_DATA_WSDL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: ccmsSoaGetReferenceDataWsdl
  - name: LAA_PORTAL_IDP_SSO_TARGET_URL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: laaPortalIdpSsoTargetUrl
  - name: LAA_PORTAL_IDP_SLO_TARGET_URL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: laaPortalIdpSloTargetUrl
  - name: LAA_PORTAL_IDP_CERT
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: laaPortalIdpCert
  - name: LAA_PORTAL_IDP_CERT_FINGERPRINT_ALGORITHM
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: laaPortalIdpCertFingerprintAlgorithm
  - name: LAA_PORTAL_CERTIFICATE
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: laaPortalCertificate
  - name: LAA_PORTAL_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: laaPortalSecretKey
  - name: LAA_PORTAL_MOCK_SAML
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: laaPortalMockSaml
  - name: PROVIDER_DETAILS_URL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: providerDetailsUrl
  - name: PDA_URL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: pdaUrl
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: trueLayerEnableMock
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: adminAllowReset
  - name: ADMIN_ALLOW_CREATE_TEST_APPLICATIONS
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: adminAllowCreateTestApplications
  - name: GOOGLE_TAG_MANAGER_TRACKING_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: googleTagManagerTrackingId
  - name: KUBERNETES_DEPLOYMENT
    value: "true"
  - name: METRICS_SERVICE_HOST
    value: {{ template "apply-for-legal-aid.fullname" . }}-metrics
  - name: CFE_CIVIL_HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: checkFinancialEligibilityCivilHost
  - name: APPLY_EMAIL
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: email_domainSuffix
  - name: ADMIN_SHOW_FORM
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: adminShowForm
  - name: POLICY_DISREGARDS_START_DATE
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: policyDisregardsStartDate
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: hmrcApiHost
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: hmrcDurationCheck
  - name: HMRC_USE_DEV_MOCK
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: hmrcUseDevMock
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
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: maintenanceMode
  - name: SLACK_ALERT_WEBHOOK
    valueFrom:
      secretKeyRef:
        name: laa-apply-for-legalaid-secrets
        key: slackAlertWebhook
  - name: COLLECT_HMRC_DATA
    valueFrom:
      secretKeyRef:
        name: {{ template "apply-for-legal-aid.fullname" . }}
        key: collectHmrcData
  - name: CLAMD_CONF_FILENAME
    value: {{ .Values.clamav.configFile }}
{{- end }}
