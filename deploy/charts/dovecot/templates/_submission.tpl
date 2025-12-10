{{- define "dovecot.submission.containerPorts" -}}
{{- $submission := or (kindIs "bool" .Values.submission.enabled) (has .Values.submission.enabled (list "submission" "both")) -}}
{{- $submissions := or (kindIs "bool" .Values.submission.enabled) (has .Values.submission.enabled (list "submissions" "both")) -}}
{{- if $submission -}}
- name: submission
  containerPort: {{ default 30587 .Values.submission.container.port }}
  protocol: TCP
{{- end }}
{{- if $submissions }}
- name: submissions
  containerPort: {{ default 30465 .Values.submission.container.sslPort }}
  protocol: TCP
{{- end }}
{{- end -}}

{{- define "dovecot.submission.servicePorts" -}}
{{- $submission := or (kindIs "bool" .Values.submission.enabled) (has .Values.submission.enabled (list "submission" "both")) -}}
{{- $submissions := or (kindIs "bool" .Values.submission.enabled) (has .Values.submission.enabled (list "submissions" "both")) -}}
{{- if $submission }}
- name: submission
  port: {{ default 587 .Values.submission.service.port }}
  protocol: TCP
  targetPort: submission
{{- end }}
{{- if $submissions }}
- name: submissions
  port: {{ default 465 .Values.submission.service.sslPort }}
  protocol: TCP
  targetPort: submissions
{{- end }}
{{- end -}}

{{- define "dovecot.submission.configuration" -}}
{{- $submission := or (kindIs "bool" .Values.submission.enabled) (has .Values.submission.enabled (list "submission" "both")) -}}
{{- $submissions := or (kindIs "bool" .Values.submission.enabled) (has .Values.submission.enabled (list "submissions" "both")) -}}
service submission-login {
  process_min_avail = 1
  client_limit = {{ default 100 .Values.submission.clientLimit }}
  chroot =

  {{- if $submission }}
  inet_listener submission {
    port = {{ default 30587 .Values.submission.container.port }}
  }
  {{- end }}
  {{- if $submissions }}
  inet_listener submissions {
    port = {{ default 30465 .Values.submission.container.sslPort }}
    ssl = yes
  }
  {{- end }}
}
{{- end -}}
