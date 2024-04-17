{{/*
Expand the name of the chart.
*/}}
{{- define "dataplaneWebserver.name" -}}
{{- default .Chart.Name .Values.dataplaneWebserver.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dataplaneWebserver.fullname" -}}
{{- if .Values.dataplaneWebserver.fullnameOverride }}
{{- .Values.dataplaneWebserver.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.dataplaneWebserver.nameOverride }}
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
{{- define "dataplaneWebserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dataplaneWebserver.labels" -}}
helm.sh/chart: {{ include "dataplaneWebserver.chart" . }}
{{ include "dataplaneWebserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dataplaneWebserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dataplaneWebserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dataplaneWebserver.serviceAccountName" -}}
{{- if .Values.dataplaneWebserver.serviceAccount.create }}
{{- default (include "dataplaneWebserver.fullname" .) .Values.dataplaneWebserver.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.dataplaneWebserver.serviceAccount.name }}
{{- end }}
{{- end }}
