{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "apply-for-legal-aid.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 53 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 53 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
And we leave 10 extra characters for addition information.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "apply-for-legal-aid.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 53 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 53 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 53 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "apply-for-legal-aid.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 53 | trimSuffix "-" -}}
{{- end -}}

{{/*
Defining cron schedule for the job sending metrics to Prometheus.
In staging and production, the job runs every minute.
In UAT, in order to not use too much resource, we run the job only once per hour.
https://pauladamsmith.com/blog/2011/05/go_time.html
*/}}
{{- define "apply-for-legal-aid.cronjob-schedule-metrics" -}}
  {{- if contains "-uat" .Release.Namespace -}}
    {{- $currentMinute := now | date "4" -}}
    {{- printf "%s * * * *" $currentMinute -}}
  {{- else -}}
    {{ "* * * * *" }}
  {{- end -}}
{{- end -}}

{{/*
Defining cron schedule for the backup db job
In production the job runs once per hour between 7am and 9pm
In UAT and Staging, we dont run the job by scheduling it for 31st February.
*/}}
{{- define "apply-for-legal-aid.cronjob-schedule-hourly-db-backup" -}}
  {{- if contains "-production" .Release.Namespace -}}
    {{ "3 7-21 * * *"}}
  {{- else -}}
    {{ "0 0 31 2 *" }}
  {{- end -}}
{{- end -}}

{{/*
Defining cron schedule for the cleanup db backup job
In production the job runs once per day at 7am
In UAT and Staging, we dont run the job by scheduling it for 31st February
*/}}
{{- define "apply-for-legal-aid.cronjob-schedule-db-backup-cleanup" -}}
  {{- if contains "-production" .Release.Namespace -}}
    {{ "0 7 * * *"}}
  {{- else -}}
    {{ "0 0 31 2 *" }}
  {{- end -}}
{{- end -}}
