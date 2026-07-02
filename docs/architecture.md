# Sufra — DevOps Architecture

End-to-end GitOps pipeline: a single `git push` ships code to production on AWS
EKS, with no manual deploy step.

> View rendered: VS Code Markdown preview (`Ctrl+Shift+V`) or on GitHub.

## CI/CD → GitOps flow

```mermaid
flowchart LR
    dev([👩‍💻 Developer]) -->|git push| appRepo

    subgraph GH["🐙 GitHub"]
        appRepo["JAHEZ3/Sufra<br/>(private · app code)"]
        infraRepo["JAHEZ3/sufra-infrastructure<br/>(public · GitOps source of truth)"]
    end

    subgraph GHA["⚙️ GitHub Actions (CI)"]
        build["Build images<br/>Docker + Next.js/NestJS"]
        push["Push → ECR"]
        bump["kustomize edit set image<br/>bump tags in infra repo"]
    end

    appRepo -->|"servers/** · frontend/**"| build
    build --> push
    push --> bump
    bump -->|"INFRA_REPO_TOKEN (PAT)"| infraRepo

    subgraph AWS["☁️ AWS · us-east-1 · acct 220719767281"]
        ecr[("📦 ECR<br/>sufra/*")]
        secrets[["🔐 Secrets Manager<br/>RDS master pw"]]
        rds[("🐘 RDS PostgreSQL 16<br/>managed · 7-day backups")]

        subgraph EKS["⎈ EKS · sufra-dev-eks"]
            argo{{"🐙 ArgoCD<br/>auto-sync · self-heal · prune"}}
            subgraph ns["namespace: sufra"]
                be["6 backend services<br/>(NestJS)"]
                fe["3 frontends<br/>(Next.js)"]
                infra["redis · nats<br/>postgres (fallback)"]
            end
        end

        alb["🌐 ALB Ingress<br/>path + host routing"]
        r53["Route53 · ACM<br/>*.sufra.shop TLS"]
    end

    push -.-> ecr
    infraRepo ==>|"ArgoCD watches main"| argo
    argo -->|kubectl apply| ns
    ecr -.->|pull images| ns
    be <-->|"TLS (PGSSLMODE)"| rds
    secrets -.->|master pw| rds

    users([🍽️ Users]) --> r53 --> alb
    alb -->|"/ "| fe
    alb -->|"/api/*"| be

    classDef aws fill:#232f3e,stroke:#ff9900,color:#fff;
    classDef gh fill:#24292e,stroke:#8b949e,color:#fff;
    classDef data fill:#1b3a4b,stroke:#4fc3f7,color:#fff;
    class ecr,secrets,rds,alb,r53,argo,be,fe,infra aws;
    class appRepo,infraRepo,build,push,bump gh;
    class users,dev data;
```

## Runtime request routing

```mermaid
flowchart TD
    u([User / browser]) -->|HTTPS| alb["ALB (one shared IngressGroup: sufra)"]

    alb -->|api.sufra.shop /api/*| gw["api-gateway + services"]
    alb -->|app.sufra.shop| client["client (table QR ordering)"]
    alb -->|dashboard.sufra.shop| dash["dashboard (restaurant owner)"]
    alb -->|panel.sufra.shop| panel["paneldashboard (manager)"]

    client -->|/api/order,restaurant,manager| svc
    panel  -->|/api/auth,manager,order,...| svc
    dash   -->|https://api.sufra.shop baked| svc

    subgraph svc["Backend (namespace sufra)"]
        auth["auth-service :3004"]
        order["order-service :3001"]
        rest["restaurant-service :3003"]
        mgr["manager-service :3006"]
        notif["notification-service :3007"]
        gw2["api-gateway :3000"]
    end

    svc --> db[("RDS PostgreSQL")]
    svc --- nats["NATS (events)"]
    svc --- redis["Redis (cache)"]
```

## Tool stack

| Layer | Tools |
|-------|-------|
| Source | GitHub (2 repos: private app + public GitOps) |
| CI | GitHub Actions · Docker Buildx · OIDC → AWS |
| Registry | Amazon ECR |
| CD (GitOps) | ArgoCD · Kustomize |
| Orchestration | Amazon EKS (Kubernetes 1.30) |
| Data | RDS PostgreSQL · ElastiCache (provisioned) · in-cluster NATS/Redis |
| Networking | AWS Load Balancer Controller (ALB) · Route53 · ACM (TLS) |
| Secrets | AWS Secrets Manager · k8s Secrets (IRSA for S3) |
| IaC | Terraform (bootstrap: state + OIDC) |

## The one-push promise

```
git push  →  GitHub Actions builds & pushes to ECR  →  bumps image tag in the
public infra repo  →  ArgoCD detects the change on main  →  syncs to EKS  →
rolling update live.  No kubectl, no manual deploy.
```
