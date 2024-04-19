{{/*
Helpers for the label-namespace job
*/}}

{{- define "labelNamespaceJob.name" -}}
{{- default .Chart.Name "label-namespace" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "labelNamespaceJob.fullname" -}}
{{- $name := default .Chart.Name "label-namespace" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "labelNamespaceJob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "labelNamespaceJob.selectorLabels" -}}
app.kubernetes.io/name: {{ include "labelNamespaceJob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "labelNamespaceJob.labels" -}}
helm.sh/chart: {{ include "labelNamespaceJob.chart" . }}
{{ include "labelNamespaceJob.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Helpers for the init-cp-db job
*/}}

{{- define "initControlPlaneDatabaseJob.name" -}}
{{- default .Chart.Name "init-cp-db" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "initControlPlaneDatabaseJob.fullname" -}}
{{- $name := default .Chart.Name "init-cp-db" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "initControlPlaneDatabaseJob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "initControlPlaneDatabaseJob.selectorLabels" -}}
app.kubernetes.io/name: {{ include "initControlPlaneDatabaseJob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "initControlPlaneDatabaseJob.labels" -}}
helm.sh/chart: {{ include "initControlPlaneDatabaseJob.chart" . }}
{{ include "initControlPlaneDatabaseJob.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Helpers for the init-cp-queue-db job
*/}}

{{- define "initControlPlaneQueueDatabaseJob.name" -}}
{{- default .Chart.Name "init-cp-queue-db" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "initControlPlaneQueueDatabaseJob.fullname" -}}
{{- $name := default .Chart.Name "init-cp-queue-db" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "initControlPlaneQueueDatabaseJob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "initControlPlaneQueueDatabaseJob.selectorLabels" -}}
app.kubernetes.io/name: {{ include "initControlPlaneQueueDatabaseJob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "initControlPlaneQueueDatabaseJob.labels" -}}
helm.sh/chart: {{ include "initControlPlaneQueueDatabaseJob.chart" . }}
{{ include "initControlPlaneQueueDatabaseJob.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
