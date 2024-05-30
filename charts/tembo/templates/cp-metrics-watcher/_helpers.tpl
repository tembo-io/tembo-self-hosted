{{/*
Expand the name of the chart.
*/}}
{{- define "cpMetricsWatcher.name" -}}
{{- default .Chart.Name .Values.cpMetricsWatcher.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cpMetricsWatcher.fullname" -}}
{{- if .Values.cpMetricsWatcher.fullnameOverride }}
{{- .Values.cpMetricsWatcher.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.cpMetricsWatcher.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cpMetricsWatcher.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cpMetricsWatcher.labels" -}}
helm.sh/chart: {{ include "cpMetricsWatcher.chart" . }}
{{ include "cpMetricsWatcher.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cpMetricsWatcher.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cpMetricsWatcher.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cpMetricsWatcher.serviceAccountName" -}}
{{- if .Values.cpMetricsWatcher.serviceAccount.create }}
{{- default (include "cpMetricsWatcher.fullname" .) .Values.cpMetricsWatcher.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.cpMetricsWatcher.serviceAccount.name }}
{{- end }}
{{- end }}
