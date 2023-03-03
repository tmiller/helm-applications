{{- define "application" }}
{{- range $index, $customer := .customers }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ $.environment }}-{{ $customer.name }}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    ver: {{ $.image.version | quote }}
    app: {{ $.application | quote }}
    env: {{ $.environment | quote }}
  annotations:
    argocd.argoproj.io/sync-wave: "{{ mod $index 10 }}"
spec:
  project: default
  source:
    repoURL: {{ $.helm.gitRepository }}
    targetRevision: {{ $.helm.gitRevision }}
    path: .
    helm:
      values: |-
        environment: {{ $.environment }}
        application: {{ $.application }}
        customer: {{ $customer }}
        domains:
        {{- range $.defaultDomains }}
          - {{ $customer.name }}.{{ . }}
        {{- end }}
        {{- if hasKey $customer "vanityDomains" }}
        {{- range $customer.vanityDomains }}
          - {{ . }}
        {{- end }}
        {{- end }}
        image:
          version: {{ $.image.version }}
          repo: {{ $.image.repo }}
  destination:
    namespace: {{ $.environment }}-{{ $customer.name }}
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true   
    syncOptions:
      - RespectIgnoreDifferences=true
      - CreateNamespace=true
{{- end }}
{{- end }} 
