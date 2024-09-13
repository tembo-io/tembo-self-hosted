{{/*
Expand the name of the chart.
*/}}
{{- define "temboUI.name" -}}
{{- default .Chart.Name .Values.temboUI.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "temboUI.fullname" -}}
{{- if .Values.temboUI.fullnameOverride }}
{{- .Values.temboUI.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.temboUI.nameOverride }}
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
{{- define "temboUI.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "temboUI.labels" -}}
helm.sh/chart: {{ include "temboUI.chart" . }}
{{ include "temboUI.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "temboUI.selectorLabels" -}}
app.kubernetes.io/name: {{ include "temboUI.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "temboUI.serviceAccountName" -}}
{{- if .Values.temboUI.serviceAccount.create }}
{{- default (include "temboUI.fullname" .) .Values.temboUI.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.temboUI.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define IngressClass name
*/}}
{{- define "temboUI.ingressClass" -}}
{{- if .Values.global.traefikEnabled }}
{{- printf "%s-%s" .Release.Name "traefik" }}
{{- else }}
{{- "traefik" }}
{{- end }}
{{- end }}

{{/*
Define API Base URL
*/}}
{{- define "temboUI.apiBaseUrl" -}}
{{- if .Values.global.tlsEnabled }}
- name: NEXT_PUBLIC_API_BASE_URL_V1
  value: {{- printf " https://api.%s/api/v1" .Values.global.baseDomain }}
{{- else }}
- name: NEXT_PUBLIC_API_BASE_URL_V1
  value: {{- printf " http://api.%s/api/v1" .Values.global.baseDomain }}
{{- end }}
{{- end }}

{{/*
Define Metrics Base URL
*/}}
{{- define "temboUI.metricsBaseUrl" -}}
{{- if .Values.global.tlsEnabled }}
- name: NEXT_PUBLIC_METRICS_BASE_URL
  value: {{- printf " https://dataplane.%s" .Values.global.baseDomain }}
{{- else }}
- name: NEXT_PUBLIC_METRICS_BASE_URL
  value: {{- printf " http://dataplane.%s" .Values.global.baseDomain }}
{{- end }}
{{- end }}
