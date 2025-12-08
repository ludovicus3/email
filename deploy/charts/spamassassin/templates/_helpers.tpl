{{- define "spamassassin.image" -}}
{{- $chart := dict "AppVersion" (printf "%s-v%s" .Chart.Name .Chart.AppVersion) "Name" .Chart.Name -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" $chart) -}}
{{- end -}}

{{- define "spamassassin.persistence.claimName" -}}
{{- default (include "common.names.fullname" .) .Values.persistence.existingClaim -}}
{{- end -}}