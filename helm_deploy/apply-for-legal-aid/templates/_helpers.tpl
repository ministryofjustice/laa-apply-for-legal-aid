{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "apply-for-legal-aid.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "apply-for-legal-aid.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "apply-for-legal-aid.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Defining cron schedule for the job sending metrics to Prometheus.
In staging and production, the job runs every minute.
In UAT, in order to not use too much resource, we run the job only once per hour.
*/}}
{{- define "apply-for-legal-aid.metrics-cronjob-schedule" -}}
  {{- if contains "-uat" .Release.Namespace -}}
    {{/* https://pauladamsmith.com/blog/2011/05/go_time.html */}}
    {{- $currentMinute := now | date "4" -}}
    {{- printf "%s * * * *" $currentMinute -}}
  {{- else -}}
    {{ "* * * * *" }}
  {{- end -}}
{{- end -}}
