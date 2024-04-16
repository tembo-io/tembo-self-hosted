{{/*
Expand the name of the chart.
*/}}
{{- define "cpReconciler.name" -}}
{{- default .Chart.Name .Values.cpReconciler.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cpReconciler.fullname" -}}
{{- if .Values.cpReconciler.fullnameOverride }}
{{- .Values.cpReconciler.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.cpReconciler.nameOverride }}
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
{{- define "cpReconciler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cpReconciler.labels" -}}
helm.sh/chart: {{ include "cpReconciler.chart" . }}
{{ include "cpReconciler.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cpReconciler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cpReconciler.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cpReconciler.serviceAccountName" -}}
{{- if .Values.cpReconciler.serviceAccount.create }}
{{- default (include "cpReconciler.fullname" .) .Values.cpReconciler.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.cpReconciler.serviceAccount.name }}
{{- end }}
{{- end }}
