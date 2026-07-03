{{/*
Expand the name of the chart.
*/}}
{{- define "terrakube.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terrakube.fullname" -}}
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
{{- define "terrakube.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terrakube.labels" -}}
helm.sh/chart: {{ include "terrakube.chart" . }}
{{ include "terrakube.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Returns "true" when MINIO/Garage terraform storage is configured.
Requires bucketName and endpoint, plus either inline accessKey/secretKey
or a reference to an existing Kubernetes secret.
*/}}
{{- define "terrakube.storage.minio.enabled" -}}
{{- if and (.Values.storage.minio).bucketName (.Values.storage.minio).endpoint -}}
{{- if or (and (.Values.storage.minio).accessKey (.Values.storage.minio).secretKey) (.Values.storage.minio).existingSecret -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Emits container env entries that source the MINIO/Garage credentials from an
existing Kubernetes secret. Only rendered when an existingSecret is configured
for the (non default) MINIO storage.
Usage:
  {{- include "terrakube.storage.minio.secretEnv" (dict "ctx" . "access" (list "AwsStorageAccessKey") "secret" (list "AwsStorageSecretKey")) | nindent 8 }}
*/}}
{{- define "terrakube.storage.minio.secretEnv" -}}
{{- $ctx := .ctx -}}
{{- $m := $ctx.Values.storage.minio -}}
{{- if and (not $ctx.Values.storage.defaultStorage) (eq (include "terrakube.storage.minio.enabled" $ctx) "true") $m.existingSecret -}}
{{- range .access }}
- name: {{ . }}
  valueFrom:
    secretKeyRef:
      name: {{ $m.existingSecret | quote }}
      key: {{ $m.existingSecretAccessKeyKey | default "accessKey" | quote }}
{{- end }}
{{- range .secret }}
- name: {{ . }}
  valueFrom:
    secretKeyRef:
      name: {{ $m.existingSecret | quote }}
      key: {{ $m.existingSecretSecretKeyKey | default "secretKey" | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Emits container env entries that source the AWS S3 credentials from an
existing Kubernetes secret. Only rendered when an existingSecret is configured
for the (non default) AWS storage.
Usage:
  {{- include "terrakube.storage.aws.secretEnv" (dict "ctx" . "access" (list "AwsStorageAccessKey") "secret" (list "AwsStorageSecretKey")) | nindent 8 }}
*/}}
{{- define "terrakube.storage.aws.secretEnv" -}}
{{- $ctx := .ctx -}}
{{- $a := $ctx.Values.storage.aws -}}
{{- if and (not $ctx.Values.storage.defaultStorage) $a.bucketName $a.region $a.existingSecret -}}
{{- range .access }}
- name: {{ . }}
  valueFrom:
    secretKeyRef:
      name: {{ $a.existingSecret | quote }}
      key: {{ $a.existingSecretAccessKeyKey | default "accessKey" | quote }}
{{- end }}
{{- range .secret }}
- name: {{ . }}
  valueFrom:
    secretKeyRef:
      name: {{ $a.existingSecret | quote }}
      key: {{ $a.existingSecretSecretKeyKey | default "secretKey" | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "terrakube.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terrakube.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
API labels
*/}}
{{- define "terrakube-api.labels" -}}
app.kubernetes.io/component: terrakube-api
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
Executor labels
*/}}
{{- define "terrakube-executor.labels" -}}
app.kubernetes.io/component: terrakube-executor
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
OpenLDAP labels
*/}}
{{- define "terrakube-openldap.labels" -}}
app.kubernetes.io/component: terrakube-openldap
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
Registry labels
*/}}
{{- define "terrakube-registry.labels" -}}
app.kubernetes.io/component: terrakube-registry
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
UI labels
*/}}
{{- define "terrakube-ui.labels" -}}
app.kubernetes.io/component: terrakube-ui
{{ include "terrakube.selectorLabels" . }}
{{- end }}