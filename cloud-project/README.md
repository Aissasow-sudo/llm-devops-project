# Projet Cloud, Floci et Terraform — GCP (Cloud Storage + Pub/Sub)

## 1. Provider choisi

**GCP**, simulé localement par l'émulateur **[floci-gcp](https://github.com/floci-io/floci-gcp)** (membre de la famille [Floci](https://github.com/floci-io/floci)), exposé sur le port **4588**.

## 2. Services choisis

| Service | Ressource Terraform | Module |
|---|---|---|
| Cloud Storage | `google_storage_bucket` | [`modules/storage`](modules/storage) |
| Pub/Sub | `google_pubsub_topic` + `google_pubsub_subscription` | [`modules/pubsub`](modules/pubsub) |

### Pourquoi ces deux services ?

- **Cloud Storage** est le service GCP le plus simple et le plus universel : il illustre bien la notion de ressource "stateful" (bucket) et se configure avec un minimum de paramètres, ce qui le rend idéal pour vérifier rapidement que l'endpoint local fonctionne.
- **Pub/Sub** apporte un second type de ressource (messagerie asynchrone, avec une relation topic → souscription), ce qui permet de montrer une dépendance **entre ressources** (`google_pubsub_subscription.this.topic = google_pubsub_topic.this.name`) et donc l'intérêt des `outputs` de module.
- Les deux services sont explicitement supportés par floci-gcp et le provider Terraform `google` expose pour chacun un attribut d'endpoint personnalisé (`storage_custom_endpoint`, `pubsub_custom_endpoint`), ce qui rend le TP réalisable sans configuration exotique.

---

## 3. Étape 1 — Installation et lancement de Floci (floci-gcp)

Floci-gcp est distribué sous forme d'image Docker, orchestrée avec `docker compose` par le dépôt **Floci UI** (voir étape suivante). Il n'est pas nécessaire de lancer `floci-gcp` séparément : `docker compose --profile multicloud up -d` (étape 2) démarre également le conteneur `floci-gcp` en tant que dépendance de la stack.

Pour vérifier manuellement qu'il tourne et répond une fois la stack démarrée :

```bash
# Vérifier que le conteneur tourne
docker ps --filter name=floci-gcp

# Vérifier que le port répond
curl -i http://localhost:4588
```

**Port utilisé par le provider GCP : `4588`** (Cloud Storage, Pub/Sub, Firestore, Datastore, Secret Manager, IAM, etc. partagent tous ce même port via négociation HTTP/2 ALPN).

📸 Capture fournie : [`screenshots/floci.png`](screenshots/floci.png) — `docker ps` (les 5 conteneurs `Up`) et la réponse de `curl` sur le port 4588.

---

## 4. Étape 2 — Lancement de Floci UI

Floci UI fournit un `docker compose` qui démarre en une seule commande l'interface web **et** les émulateurs Cloud dont elle a besoin (AWS, Azure, GCP en profil `multicloud`).

```bash
git clone https://github.com/floci-io/floci-ui.git
cd floci-ui
docker compose --profile multicloud up -d
```

Cela démarre 5 conteneurs : `floci-ui` (4500), `floci-api` (4501), `floci` AWS (4566), `floci-az` (4577) et **`floci-gcp` (4588)**.

Floci UI est accessible sur :

```text
http://localhost:4500
```

Dans l'interface :

1. Sélectionner le provider **GCP** en haut à droite (bloc CLOUD).
2. Vérifier que la carte « RUNTIME » indique `Runtime reachable` et pointe vers `floci-gcp:4588`.
3. Parcourir les services disponibles dans le menu de gauche (section « CLOUD SERVICES · GCP ») : **Storage**, **Pub/Sub**, Database, GKE, Serverless, …
4. Confirmer visuellement que **Storage** et **Pub/Sub** sont bien listés : ce sont les deux services utilisés dans ce projet.

📸 Capture fournie : [`screenshots/floci-ui.png`](screenshots/floci-ui.png) — Floci UI ouvert, provider GCP sélectionné, "Runtime reachable".

---

## 5. Étape 3 — Choix du provider et des services

```text
Provider : GCP

Service 1 : Cloud Storage
Service 2 : Pub/Sub
```

Justification : voir section [« Pourquoi ces deux services ? »](#pourquoi-ces-deux-services-).

---

## 6. Étape 4 — Structure du projet Terraform

```text
cloud-project/
│
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
│
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
│
├── modules/
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── pubsub/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── screenshots/
    ├── floci.png
    ├── floci-ui.png
    ├── resources-storage.png
    ├── resources-pubsub.png
    └── destroy.png
```

---

## 7. Étape 5 — Configuration du provider ([`providers.tf`](providers.tf))

```hcl
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  storage_custom_endpoint = "${var.floci_gcp_endpoint}/storage/v1/"
  pubsub_custom_endpoint  = "${var.floci_gcp_endpoint}/v1/"

  access_token = "floci-local-dev-token"
}
```

### Vraie API GCP vs Floci : quelle différence ?

| | Vrai Google Cloud | Terraform + Floci |
|---|---|---|
| **Endpoint contacté** | `https://storage.googleapis.com`, `https://pubsub.googleapis.com`, … (domaines Google, sur Internet) | `http://localhost:4588` (processus local, sur la machine du développeur) |
| **Authentification** | Compte de service réel, clé JSON ou OAuth valide, IAM réellement vérifié | Aucune vérification réelle : floci-gcp accepte les requêtes même avec un jeton factice (`access_token = "floci-local-dev-token"`) |
| **Facturation** | Les ressources créées sont facturées | Aucun coût, tout est simulé en mémoire/disque local |
| **Persistance / portée** | Ressources visibles par toute l'organisation GCP, durables | Ressources visibles uniquement dans l'instance locale de floci-gcp, perdues si le conteneur est supprimé |
| **Ce que Terraform change** | Rien dans le code Terraform lui-même | Seuls les attributs `*_custom_endpoint` du bloc `provider "google"` changent la destination des appels API — les blocs `resource` restent identiques |

C'est exactement la notion d'**endpoint local** : le fournisseur Terraform `google` est le même binaire, écrit le même protocole HTTP/gRPC, mais on lui indique de parler à `localhost:4588` plutôt qu'aux domaines `googleapis.com`. Cela permet de développer et tester une configuration Terraform sans compte GCP réel, sans risque de coût, et avec un cycle de test beaucoup plus rapide.

---

## 8. Étape 6 — Variables ([`variables.tf`](variables.tf))

Le projet définit des variables typées avec description et, pour plusieurs d'entre elles, une **validation** (bonus) : `project_name`, `environment` (dev/staging/prod uniquement), `storage_class` (valeurs autorisées GCP), `pubsub_ack_deadline_seconds` (borné entre 10 et 600).

Aucune valeur n'est écrite en dur dans les ressources : tout transite par `var.*` ou par les `locals`.

---

## 9. Étape 7 — `terraform.tfvars`

[`terraform.tfvars`](terraform.tfvars) fixe les valeurs par défaut (`environment = "dev"`). Deux fichiers additionnels dans [`environments/`](environments) permettent de basculer entre `dev` et `prod` (bonus) :

```bash
terraform apply -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

---

## 10. Étape 8 — `locals` ([`locals.tf`](locals.tf))

```hcl
locals {
  resource_prefix = lower("${var.project_name}-${var.environment}")

  bucket_name       = "${local.resource_prefix}-bucket"
  pubsub_topic_name = "${local.resource_prefix}-topic"
  pubsub_sub_name   = "${local.resource_prefix}-sub"

  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    runtime     = "floci-gcp"
  }
}
```

`local.resource_prefix` et `local.common_labels` sont réutilisés dans [`main.tf`](main.tf) pour nommer et étiqueter les deux modules.

---

## 11. Étape 9 — Modules ([`main.tf`](main.tf))

```hcl
module "storage" {
  source = "./modules/storage"

  name          = local.bucket_name
  location      = var.storage_location
  storage_class = var.storage_class
  labels        = local.common_labels
}

module "pubsub" {
  source = "./modules/pubsub"

  topic_name           = local.pubsub_topic_name
  subscription_name    = local.pubsub_sub_name
  ack_deadline_seconds = var.pubsub_ack_deadline_seconds
  labels               = local.common_labels
}
```

Chaque module encapsule un service : [`modules/storage`](modules/storage) crée le bucket, [`modules/pubsub`](modules/pubsub) crée le topic et sa souscription.

---

## 12. Étape 10 — Outputs

Chaque module expose ses ressources ([`modules/storage/outputs.tf`](modules/storage/outputs.tf), [`modules/pubsub/outputs.tf`](modules/pubsub/outputs.tf)), et le fichier racine [`outputs.tf`](outputs.tf) les relaie :

```hcl
output "storage_bucket_name" {
  value = module.storage.bucket_name
}

output "pubsub_topic_name" {
  value = module.pubsub.topic_name
}
```

---

## 13. Étape 11 — Validation et déploiement

Depuis le dossier `cloud-project/`, avec `floci-gcp` démarré sur le port 4588 :

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

(`terraform apply -auto-approve` pour éviter la confirmation interactive si besoin.)

### Vérification dans Floci UI

1. Ouvrir `http://localhost:4500`.
2. Sélectionner le provider **GCP**.
3. Ouvrir le service **Cloud Storage** → le bucket `cloud-project-dev-bucket` doit apparaître.
4. Ouvrir le service **Pub/Sub** → le topic `cloud-project-dev-topic` et la souscription `cloud-project-dev-sub` doivent apparaître.

📸 Captures fournies : [`screenshots/resources-storage.png`](screenshots/resources-storage.png) (bucket `cloud-project-dev-bucket`) et [`screenshots/resources-pubsub.png`](screenshots/resources-pubsub.png) (topic `cloud-project-dev-topic`).

---

## 14. Étape 12 — Destruction

```bash
terraform destroy
```

Revérifier dans Floci UI (`http://localhost:4500`) que le bucket, le topic et la souscription ont disparu.

📸 Capture fournie : [`screenshots/destroy.png`](screenshots/destroy.png) — Pub/Sub à "0 normalized resources" après `terraform destroy`.

---

## 15. Reproduire ce projet de zéro

```bash
# 1. Démarrer Floci UI + tous les émulateurs (AWS, Azure, GCP), dont floci-gcp sur le port 4588
git clone https://github.com/floci-io/floci-ui.git
cd floci-ui
docker compose --profile multicloud up -d
# -> http://localhost:4500

# 3. Cloner ce dépôt et se placer dans le dossier Terraform
git clone <url-de-ce-depot>
cd cloud-project

# 4. Déployer
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply

# 5. Vérifier dans Floci UI, puis détruire
terraform destroy
```

---

## 16. Références

- Floci : <https://floci.io/> · <https://github.com/floci-io/floci>
- floci-gcp : <https://github.com/floci-io/floci-gcp>
- Floci UI : <https://github.com/floci-io/floci-ui>
- Terraform : <https://developer.hashicorp.com/terraform/docs>
- Provider Google : <https://registry.terraform.io/providers/hashicorp/google/latest/docs>
