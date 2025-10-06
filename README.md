# AWS Infrastructure as Code (IaC) with Terraform 🚀

## Platform Information 🛠️

- Cloud provider: AWS ☁️
- IaC tool: Terraform 🌱
- Cloud management: HashiCorp Cloud Platform (HCP) 🧭
- CI: GitHub Actions and Terraform Cloud integration 🔁

## File Structure 📁

- `workspace` 🧩

  The `workspace` directory is used to provision and manage HCP terraform workspaces. All workspaces except the root `terraform-workspaces` are created and managed here.

- `common` 🔐

  The `common` directory contains general resources and configurations that are shared across the account, such as IAM roles, policies, and networking components.
