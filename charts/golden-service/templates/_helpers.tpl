{{/*
Resource name: the release name (one release per service), so two services
using this chart in the same cluster never collide.
*/}}
{{- define "golden.fullname" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels on every resource.
*/}}
{{- define "golden.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "golden.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | trunc 63 | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels: Service and Deployment find pods with these. Never change them
for an existing service - Deployment selectors are immutable.
*/}}
{{- define "golden.selectorLabels" -}}
app.kubernetes.io/name: {{ include "golden.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
