# mztn-service Terraform構成

このディレクトリは、Google Cloud Project `mztn-service` を管理するためのTerraform構成です。

## 機能

- Google Cloud Projectの基本設定
- GitHub ActionsからのWorkload Identity認証設定
- 必要なAPIの有効化
- GitHub Actions用サービスアカウントの作成とEditor権限の付与
- Artifact Registry (container-images)
- Warren Cloud Runサービス（条件付きデプロイ）
- Firestore Database (warren-v1)
- Cloud Storage (mztn-warren-v1)
- Secret Manager (Warren用API keys)

## ファイル構成

- `provider.tf`: Terraformとプロバイダーの基本設定
- `locals.tf`: 全てのローカル変数（プロジェクト設定、Warren設定など）
- `workload-identity.tf`: Workload Identity Pool、ProviderおよびService Account設定
- `main.tf`: 必要なAPIの有効化
- `artifact-repository.tf`: Docker imageリポジトリ
- `service-account.tf`: Warren用サービスアカウント
- `cloud-storage.tf`: Warren用Cloud Storageバケット
- `firestore.tf`: Warren用Firestoreデータベース
- `secret.tf`: Warren用Secretの管理
- `iam.tf`: Warren用IAM権限設定
- `cloud-run.tf`: Warren Cloud Runサービス

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

## Warren Cloud Runサービスのデプロイ

Warrenサービスは条件付きでデプロイされます。以下の手順でデプロイしてください：

1. **Warren Dockerイメージをビルド・プッシュ**:
```bash
# イメージをビルド
docker build -t warren .

# タグ付け
docker tag warren asia-northeast1-docker.pkg.dev/mztn-service/container-images/warren:latest

# プッシュ
docker push asia-northeast1-docker.pkg.dev/mztn-service/container-images/warren:latest
```

2. **デプロイ設定を有効化**:
`locals.tf`ファイルでWarrenのデプロイを有効化:
```hcl
locals {
  # Warren configuration
  deploy_warren     = true   # ← trueに変更
  warren_image_tag  = "latest"  # 必要に応じて変更
  # ...
}
```

3. **Warrenサービスをデプロイ**:
```bash
terraform plan
terraform apply
```

4. **Secretの値を設定**:
```bash
# 各Secretに値を設定
echo -n "your-slack-token" | gcloud secrets versions add WARREN_SLACK_OAUTH_TOKEN --data-file=-
echo -n "your-otx-key" | gcloud secrets versions add WARREN_OTX_API_KEY --data-file=-
# 他のSecretも同様に設定...
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