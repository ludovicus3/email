{{- define "postfix.master.service" -}}
{{- $private := include "postfix.master.ternary" .private -}}
{{- $unpriv := include "postfix.master.ternary" .unprivileged -}}
{{- $chroot := include "postfix.master.ternary" .chroot -}}
{{- $wakeup := default "-" .wakeup -}}
{{- $maxproc := default "-" .maxProcesses -}}
{{- printf "%-15s %-15s %s %s %s %-8s %-8s %s" .name .type $private $unpriv $chroot $wakeup $maxproc .command }}
{{- range .args }}
  {{- . | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "postfix.master.ternary" -}}
{{- if kindIs "bool" . -}}
  {{- ternary "y" "n" . -}}
{{- else -}}
  {{- print "-" -}}
{{- end -}}
{{- end -}}