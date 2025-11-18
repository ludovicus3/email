{{- define "opendkim.signingKey.file" -}}
{{- printf "%s.private" .name -}}
{{- end -}}

{{- define "opendkim.signingKey.path" -}}
{{- printf "/etc/opendkim/keys/%s" (include "opendkim.signingKey.file" .) -}}
{{- end -}}

{{- define "opendkim.secret.signingKeys" -}}
{{- range $key := .Values.opendkim.signingKeys }}
  {{- with .privateKey -}}
    {{ include "opendkim.signingKey.file" $key }}: {{ . | b64enc }}
  {{- end -}}
{{- end }}
{{- end -}}

{{- define "opendkim.signingKey.domainName" -}}
{{- $domain := required "Each signing key must have a domain defined for it." .domain -}}
{{- printf "%s._domainkey.%s" (include "opendkim.signingKey.selector" .) $domain -}}
{{- end -}}

{{- define "opendkim.signingKey.selector" -}}
{{- default "default" .selector -}}
{{- end -}}
