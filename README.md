# platform-gitops

A small replica of a platform team's GitOps setup, running on minikube.

```
service repo (rider-assignment-service)
  CI: test + lint -> build -> push ghcr.io/...:<git-sha> -> bump image.tag here
                                                               |
platform-gitops (this repo)                                    v
  charts/golden-service/     platform-owned base chart   (in many companies: its own repo)
  apps/<service>/<env>/      per-service values          (the "developer access" repo; changed by PR)
  platform/local-deps/       Postgres, Redis, Kafka for local only (cloud: managed services via Terraform)
  argocd/                    ApplicationSet + apps that Argo CD runs
                                                               |
                                                               v
                                         Argo CD (in the cluster) syncs Git -> Kubernetes
```

## Golden chart defaults every service gets

- Resource names from the release name, so services never collide
- Immutable image tag required (`image.tag` = git SHA)
- `checksum/config` + `checksum/secret`: config changes roll pods immediately
- No `replicas` when the HPA is enabled (the HPA owns it)
- Liveness = TCP only; readiness = HTTP `/health`
- `maxUnavailable: 0` rolling updates, graceful termination
- Optional, off by default: Ingress, PodDisruptionBudget, cloud identity annotations

## Add a new service (self-service)

1. Create `apps/<service>/local/values.yaml` (copy rider-assignment's).
2. Open a PR, get it reviewed, merge.
3. The `services-local` ApplicationSet creates the Argo CD app and deploys it.

## Bootstrap (once per cluster)

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/
```

## Check the chart locally

```bash
helm lint charts/golden-service -f apps/rider-assignment/local/values.yaml
helm template rider-assignment charts/golden-service -f apps/rider-assignment/local/values.yaml
```
