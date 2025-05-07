# PostgreSQL on Kubernetes – Secure GitOps Deployment (NHS Tech Assessment)

##  Project Overview

This repository demonstrates a minimal, modular, and secure deployment of PostgreSQL in Kubernetes using Helm, Terraform, and GitOps principles — aligned with DevOps best practices and NHS cloud infrastructure standards.

The task was set as part of an interview assessment for a **Senior Software/Infrastructure Engineer** role at **Lancashire and South Cumbria NHS**, where the broader goal is to support secure, multi-tenant research environments built on **Azure Kubernetes Service (AKS)**. 

The focus is not on production readiness, but on showcasing:

- Understanding of Kubernetes fundamentals
- Security-conscious infrastructure design
- GitOps-aligned delivery strategy
- Clear architectural thinking

###  What’s Included:
- PostgreSQL deployment using the **Bitnami Helm chart**
- Two Kubernetes-native security practices:
  - `NetworkPolicy` for traffic isolation
  - `Secret` for credential security
- Terraform code to manage the Helm release declaratively
- GitOps-ready structure compatible with **ArgoCD**
- NHS-relevant considerations around secure research environments

### Why This Matters in NHS Context

In healthcare platforms like **Trusted Research Environments (TREs)**, storing sensitive patient telemetry data (e.g., from wearables) requires strong **multi-tenant isolation, encrypted secrets, reproducible infra**, and **auditable delivery pipelines**.

This project mirrors such a foundation by applying:
- Infrastructure-as-Code principles
- Policy-driven cluster security
- GitOps for traceable and secure environment updates

This project uses the [Bitnami PostgreSQL Helm Chart](https://artifacthub.io/packages/helm/bitnami/postgresql) for deployment.
- [ArgoCD GitOps Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- See [GitOps in Healthcare][gitops-healthcare] for more.

[gitops-healthcare]: https://www.weave.works/blog/gitops-and-regulated-industries

##  Architecture & Design Decisions

The architecture was designed with modularity, security, and auditability in mind, while keeping the scope narrow enough for a timed technical assessment. It reflects real-world patterns applicable to cloud-native infrastructure, especially for regulated environments like NHS Trusted Research Environments (TREs).

---

###  Core Stack Summary

| Component      | Tool                      | Reason                                                                 |
|----------------|---------------------------|------------------------------------------------------------------------|
| DB Deployment  | [Bitnami PostgreSQL Helm Chart](https://artifacthub.io/packages/helm/bitnami/postgresql) | Reusable, community-tested, secure Helm chart with built-in best practices |
| Infrastructure as Code | [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) | Enables declarative, versioned, and repeatable deployment |
| K8s Secrets    | Kubernetes Secret object   | Avoids plaintext credentials and supports future integration with Key Vault |
| Network Control| Kubernetes NetworkPolicy   | Implements least-privilege networking at pod level                      |

---

###  Design Workflow

1. **Helm Values Defined**
   - The Helm chart was configured for:
     - Internal-only access (`ClusterIP`)
     - Persistent volume claim (PVC)
     - Custom resource requests/limits
     - Externalized credentials via Kubernetes Secret

2. **Terraform as Declarative Wrapper**
   - Instead of manually applying Helm, `main.tf` wraps it with:
     - Namespace management
     - Chart versioning
     - Value injection
   - This aligns with GitOps and audit/compliance practices

3. **Kubernetes Concepts Applied**
   - **Secrets**:
     - Used base64 encoding (standard practice) to inject PostgreSQL credentials
     - Positioned for future CSI integration with Azure Key Vault

   - **NetworkPolicy**:
     - Restricts traffic to DB pods from only pods labeled `role: backend`
     - Ensures segmentation — a must in NHS-like multi-tenant clusters

   - **Persistence**:
     - PVC configured in Helm ensures data durability across pod restarts

---

###  NHS Context Awareness

This setup echoes the **foundational security and delivery needs** of Trusted Research Environments:

- Deployments are **declarative** and managed via version control
- Secrets are **abstracted** from configs and externalized
- Pod communication is **explicitly controlled**
- Infrastructure is **scalable, repeatable**, and portable across environments

> NHS Secure Data Environments expect infrastructure that is secure-by-default, tenant-isolated, and Git-traceable — this architecture aligns with those principles within the time constraints of the exercise.


📖 [NHS Secure Data Environments Overview](https://www.england.nhs.uk/digitaltechnology/secure-data-environments/)

##  GitOps Readiness & Repo Structure

The repository is structured to support GitOps-based delivery, particularly through ArgoCD. While the implementation is intentionally minimal due to the time constraints of the assessment, the structure demonstrates an understanding of how Git can be used as the single source of truth for Kubernetes infrastructure.

###  Directory Structure

```text
postgresql-k8s-assessment/
├── helm/                         # PostgreSQL Helm values
│   └── argocd/
│       └── base/
│           └── postgres-app.yaml  # ArgoCD Application manifest
├── manifests/                    # Security policies (Secrets, NetworkPolicy)
├── main.tf                       # Terraform-managed Helm release
└── README.md
```

###  Why GitOps?

- **Auditability** – All infrastructure definitions and changes are tracked via Git
- **Consistency** – Tools like ArgoCD ensure the live cluster state always reflects Git
- **Multi-tenancy readiness** – Supports future overlays for environments like `dev/`, `prod`, or per research tenant

###  ArgoCD Application Highlights

The `postgres-app.yaml` manifest (in `helm/argocd/base`) defines:

- The source Git repository and chart path
- Sync policy with `selfHeal` and `prune` enabled
- Deployment into the `research` namespace
- Use of Helm values from `values.yaml`

📖 Reference: [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)

> In a healthcare environment such as an NHS Trusted Research Environment (TRE), GitOps ensures infrastructure changes are fully declarative, auditable, and securely deployed through automated CI/CD pipelines.

##  Security Considerations

Security is a fundamental concern in any healthcare system, especially in environments handling sensitive patient telemetry data like NHS Trusted Research Environments (TREs). This project includes two Kubernetes-native security mechanisms that form the foundation for a secure posture within a multi-tenant AKS environment.

---

### 1. Kubernetes Secret

- The PostgreSQL password is stored as a Kubernetes `Secret` instead of hardcoding it in the Helm values file.
- Passwords are base64-encoded and managed separately from source code logic.
- In a production scenario, this can be extended using CSI drivers to mount secrets directly from tools like [Azure Key Vault](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver).

📖 Reference: [Kubernetes Secrets Best Practices](https://kubernetes.io/docs/concepts/configuration/secret/)

---

### 2. NetworkPolicy

- A `NetworkPolicy` restricts PostgreSQL access to only pods with the label `role: backend`.
- This blocks lateral traffic within the cluster and ensures only explicitly allowed services can connect to the database.
- It supports a **zero-trust network model**, aligned with NHS's multi-tenant cluster guidelines.

📖 Reference: [Kubernetes NetworkPolicy Docs](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

> In a secure healthcare research platform, isolation of access and abstracted credential storage are foundational to compliance with security frameworks like **NHS DSPT** and **GDPR**.

##  Security Considerations

Security is a fundamental concern in any healthcare system, especially in environments handling sensitive patient telemetry data like NHS Trusted Research Environments (TREs). This project includes two Kubernetes-native security mechanisms that form the foundation for a secure posture within a multi-tenant AKS environment.

---

### 1. Kubernetes Secret

- The PostgreSQL password is stored as a Kubernetes `Secret` instead of hardcoding it in the Helm values file.
- Passwords are base64-encoded and managed separately from source code logic.
- In a production scenario, this can be extended using CSI drivers to mount secrets directly from tools like [Azure Key Vault](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver).

📖 Reference: [Kubernetes Secrets Best Practices](https://kubernetes.io/docs/concepts/configuration/secret/)

---

### 2. NetworkPolicy

- A `NetworkPolicy` restricts PostgreSQL access to only pods with the label `role: backend`.
- This blocks lateral traffic within the cluster and ensures only explicitly allowed services can connect to the database.
- It supports a **zero-trust network model**, aligned with NHS's multi-tenant cluster guidelines.

📖 Reference: [Kubernetes NetworkPolicy Docs](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

> In a secure healthcare research platform, isolation of access and abstracted credential storage are foundational to compliance with security frameworks like **NHS DSPT** and **GDPR**.

##  Assumptions, Limitations & Next Steps

This assessment was completed under a tight deadline and intentionally scoped to demonstrate architectural thinking, Kubernetes proficiency, and GitOps awareness. Below are a few key assumptions and trade-offs made to balance realism with speed.

---

### ✅ Assumptions

- The PostgreSQL deployment runs in a pre-provisioned AKS cluster with basic ingress and storage classes available.
- The GitOps controller (e.g., ArgoCD) is already installed and configured in the cluster.
- Sensitive credentials are manually created for now but can later be integrated with enterprise secret stores.

---

###  Limitations

-  **TLS encryption** between services is not configured, but would be required in production.
-  **High availability** and replication features of PostgreSQL were not set up due to time scope.
-  **Monitoring & logging** (e.g., Prometheus, Grafana, or Azure Monitor) were not integrated.
-  **Role-based access control (RBAC)** is not demonstrated in this sample.

---


