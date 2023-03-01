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
  labels:
    version: {{ $.image.version }}
    app: {{ $.application }}
    php: 7.4
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
