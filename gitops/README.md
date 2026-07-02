# GitOps (ArgoCD)

Application manifests deployed to the EKS cluster by **ArgoCD**, separate from
the Terraform-managed infrastructure.

```
gitops/
├── applications/      # ArgoCD Application objects (one per service / app-of-apps)
│   ├── podinfo.yaml
│   └── sufra.yaml     # the full Sufra platform (auto-sync to production)
└── apps/              # the actual Kubernetes manifests ArgoCD syncs
    ├── podinfo/       # demo microservice (Deployment + Service + Ingress/ALB)
    └── sufra/         # backend microservices + frontends + in-cluster infra
```

## The Sufra platform (production)

`apps/sufra/` is the live source of truth for the cluster: 6 NestJS backend
services, 3 Next.js frontends (client/dashboard/paneldashboard), in-cluster
redis/nats + a fallback postgres StatefulSet, the `sufra-config` ConfigMap
(pointed at managed **RDS**, `NODE_ENV=production`, `PGSSLMODE=no-verify`), the
`sufra-app` ServiceAccount (S3 IRSA) and the consolidated ALB `sufra-https`
Ingress. ArgoCD keeps all of it Synced with `prune` + `selfHeal`.

### Secrets (public repo!)

`sufra-secrets` (DB creds, JWT secrets) is **not** in Git and is **not** managed
by ArgoCD — it is applied out-of-band and ArgoCD never prunes it (it only prunes
resources it tracks from Git). The RDS master password lives in AWS Secrets
Manager. Long-term: move to External Secrets Operator.

### CI → CD flow

Push code to the private app repo `JAHEZ3/Sufra` → its `servers-cicd.yml`
builds + pushes images to ECR → its `gitops` job runs `kustomize edit set image`
against `apps/sufra/kustomization.yaml` **here** (using a `INFRA_REPO_TOKEN` PAT)
and commits → ArgoCD sees the new tags on `main` and rolls them onto EKS.

Register it once:

```bash
kubectl apply -f gitops/applications/sufra.yaml
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
