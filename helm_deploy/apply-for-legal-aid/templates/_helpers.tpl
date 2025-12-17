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
Define cron hour for staging
On staging we turn off the database at 10PM and restart it at 6AM UTC (11PM and 7AM BST) to save money
This means that overnight cronjobs on staging all fail as the DB is not present
*/}}
{{- define "apply-for-legal-aid.cronjob-hour-to-start-offset" -}}
  {{- if contains "-staging" .Release.Namespace -}}
    {{- 7 -}}
  {{- else if contains "-uat" .Release.Namespace -}}
    {{- 7 -}}
  {{- else -}}
    {{ 0 }}
  {{- end -}}
{{- end -}}

{{/*
Function to return the name for a UAT redis chart master node host
This duplicates bitnami/redis chart's internal logic whereby
If branch name contains "redis" then the redis-release-name appends "-master", otherwise it appends "-redis-master"
*/}}
{{- define "apply-for-legal-aid.redis-uat-host" -}}
  {{- $redis_fullName := (include "common.names.fullname" .Subcharts.redis) -}}
  {{- printf "%s-master.%s.svc.cluster.local" $redis_fullName .Release.Namespace -}}
{{- end -}}

{{/*
Function to return a list of whitelisted IPs allowed to access the service.
*/}}
{{- define "apply-for-legal-aid.whitelist" -}}
    {{- .Values.pingdomIPs }}
{{- end -}}

