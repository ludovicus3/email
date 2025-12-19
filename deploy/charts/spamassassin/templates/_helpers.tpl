{{- define "spamassassin.maintenance.fullname" -}}
{{- printf "%s-maintenance" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spamassassin.initializationJob.fullname" -}}
{{- printf "initialize-%s-pvc" (include "spamassassin.persistence.claimName" .) -}}
{{- end -}}

{{- define "spamassassin.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.spamassassin.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{- define "spamassassin.maintenance.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.maintenance.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{- define "spamassassin.persistence.claimName" -}}
{{- default (include "common.names.fullname" .) .Values.persistence.existingClaim -}}
{{- end -}}