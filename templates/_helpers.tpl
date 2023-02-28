{{- define "application" }}
{{- range $index, $customer := .customers }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ $.environment }}-{{ $.application }}-{{ $customer }}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "{{ mod $index 2 }}"
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
        image:
          version: {{ $.image.version }}
          repo: {{ $.image.repo }}
  destination:
    namespace: {{ $.environment }}-{{ $customer }}
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
