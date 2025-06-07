# mztn-service Terraform構成

このディレクトリは、Google Cloud Project `mztn-service` を管理するためのTerraform構成です。

## 機能

- Google Cloud Projectの基本設定
- GitHub ActionsからのWorkload Identity認証設定
- 必要なAPIの有効化
- GitHub Actions用サービスアカウントの作成とEditor権限の付与

## ファイル構成

- `provider.tf`: Terraformとプロバイダーの基本設定
- `workload-identity.tf`: Workload Identity Pool、ProviderおよびService Account設定
- `main.tf`: ローカル変数と必要なAPIの有効化

## セットアップ

1. 必要に応じて`main.tf`内のlocalsブロックで設定を変更します：

```hcl
locals {
  project_id        = "mztn-service"
  region           = "asia-northeast1"
  github_repository = "m-mizutani/google-cloud-ops"
}
```

2. GCSバケット`mztn-terraform`が存在することを確認します（事前に作成が必要）。

3. Terraformを初期化し、適用します：

```bash
terraform init
terraform plan
terraform apply
```

## GitHub Actionsでの使用

適用後、出力される値を使用してGitHub Actionsワークフローを設定できます：

```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v1
  with:
    workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
    service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
```

必要なシークレット：
- `WIF_PROVIDER`: Workload Identity Provider name
- `WIF_SERVICE_ACCOUNT`: Service Account email

これらの値は、Terraformの適用後に以下のコマンドで確認できます：

```bash
# Workload Identity Provider
gcloud iam workload-identity-pools providers list --workload-identity-pool=github-actions-pool --location=global

# Service Account
gcloud iam service-accounts list --filter="displayName:Github Actions Service Account"
``` 