{{/*
Expand the name of the chart.
*/}}
{{- define "cpWebserver.name" -}}
{{- default .Chart.Name .Values.cpWebserver.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cpWebserver.fullname" -}}
{{- if .Values.cpWebserver.fullnameOverride }}
{{- .Values.cpWebserver.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.cpWebserver.nameOverride }}
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
{{- define "cpWebserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cpWebserver.labels" -}}
helm.sh/chart: {{ include "cpWebserver.chart" . }}
{{ include "cpWebserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cpWebserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cpWebserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cpWebserver.serviceAccountName" -}}
{{- if .Values.cpWebserver.serviceAccount.create }}
{{- default (include "cpWebserver.fullname" .) .Values.cpWebserver.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.cpWebserver.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define IngressClass name
*/}}
{{- define "cpWebserver.ingressClass" -}}
{{- if .Values.global.traefikEnabled }}
{{- printf "%s-%s" .Release.Name "traefik" }}
{{- else }}
{{- "traefik" }}
{{- end }}
{{- end }}
