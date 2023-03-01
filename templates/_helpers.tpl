{{- define "application" }}
{{- range $index, $customer := .customers }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ $.environment }}-{{ $.application }}-{{ $customer.name }}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    tag: {{ $.image.version | quote }}
    app: {{ $.application | quote }}
  annotations:
    argocd.argoproj.io/sync-wave: "{{ mod $index 4 }}"
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
        domains: {{ $customer.domains | toJson}}
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
