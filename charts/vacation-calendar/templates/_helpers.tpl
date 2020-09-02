{{/*
Expand the name of the chart.
*/}}
{{- define "vacation-calendar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vacation-calendar.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "vacation-calendar.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vacation-calendar.labels" -}}
helm.sh/chart: {{ include "vacation-calendar.chart" . }}
{{ include "vacation-calendar.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vacation-calendar.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vacation-calendar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Lookup the name for the path
*/}}
{{- define "vacation-calendar.secretPath" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.ingressRoute.secretPath.name) -}}
{{- "/" -}}
{{- if $secret -}}
{{- index $secret.data .Values.ingressRoute.secretPath.key | b64dec -}}
{{- else -}}
{{- "vacation-calendar" -}}
{{- end -}}
{{- "{?:.ics|}" -}}
{{- end -}}
