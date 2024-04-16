{{/*
Expand the name of the chart.
*/}}
{{- define "cpService.name" -}}
{{- default .Chart.Name .Values.cpService.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cpService.fullname" -}}
{{- if .Values.cpService.fullnameOverride }}
{{- .Values.cpService.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.cpService.nameOverride }}
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
{{- define "cpService.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cpService.labels" -}}
helm.sh/chart: {{ include "cpService.chart" . }}
{{ include "cpService.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cpService.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cpService.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "cpService.watcherSelectorLabels" -}}
app.kubernetes.io/name: {{ include "cpService.name" . }}-watcher
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "cpService.watcherLabels" -}}
helm.sh/chart: {{ include "cpService.chart" . }}
{{ include "cpService.watcherSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "cpService.serviceAccountName" -}}
{{- if .Values.cpService.serviceAccount.create }}
{{- default (include "cpService.fullname" .) .Values.cpService.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.cpService.serviceAccount.name }}
{{- end }}
{{- end }}
