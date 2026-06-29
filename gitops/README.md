# GitOps (ArgoCD)

Application manifests deployed to the EKS cluster by **ArgoCD**, separate from
the Terraform-managed infrastructure.

```
gitops/
├── applications/      # ArgoCD Application objects (one per service / app-of-apps)
│   └── podinfo.yaml
└── apps/              # the actual Kubernetes manifests ArgoCD syncs
    └── podinfo/       # demo microservice (Deployment + Service + Ingress/ALB)
```

## How it works

1. ArgoCD watches a path in this Git repo (`spec.source.path`).
2. Any change pushed to `main` is automatically applied to the cluster
   (`syncPolicy.automated`), with `prune` + `selfHeal` enabled.
3. Infra (VPC, EKS, RDS, ...) stays in Terraform; apps live here.

## Add a new service

1. Create `apps/<service>/` with its manifests (or a Helm chart).
2. Add `applications/<service>.yaml` pointing at that path.
3. `kubectl apply -f applications/<service>.yaml` once (or use the
   app-of-apps pattern to register them automatically).

## Register the demo app

```bash
kubectl apply -f gitops/applications/podinfo.yaml
argocd app get podinfo      # or watch it in the ArgoCD UI
```
