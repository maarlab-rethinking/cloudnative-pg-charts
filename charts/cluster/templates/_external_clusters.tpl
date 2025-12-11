{{- define "cluster.externalClusters" -}}
{{- if eq .Values.mode "standalone" }}
externalClusters: []
{{- else if eq .Values.mode "recovery" }}
  {{- if eq .Values.recovery.method "pg_basebackup" }}
externalClusters:
  - name: pgBaseBackupSource
     {{- include "cluster.externalSourceCluster" .Values.recovery.pgBaseBackup.source | nindent 4 }}
  {{- else if eq .Values.recovery.method "import" }}
externalClusters:
  - name: importSource
     {{- include "cluster.externalSourceCluster" .Values.recovery.import.source | nindent 4 }}
  {{- else if eq .Values.recovery.method "object_store" }}
externalClusters:
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ .Values.recovery.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
  {{- else }}
externalClusters: []
  {{- end }}
{{- else if eq .Values.mode "replica" }}
externalClusters:
  - name: originCluster
  {{- if not (empty .Values.replica.origin.objectStore.provider) }}
    barmanObjectStore:
      serverName: {{ .Values.replica.origin.objectStore.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.replica.origin.objectStore "secretPrefix" "origin" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 -}}
  {{- end }}
  {{- if not (empty .Values.replica.origin.pg_basebackup.host) }}
    {{- include "cluster.externalSourceCluster" .Values.replica.origin.pg_basebackup | nindent 4 }}
  {{- end }}
{{- else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{ end }}
