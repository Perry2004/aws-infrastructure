resource "mongodbatlas_project" "cca-mongo" {
  name   = "${var.app_full_name}-mongo"
  org_id = var.TFC_MONGO_ATLAS_ORG_ID
}

resource "mongodbatlas_advanced_cluster" "cca-mongo" {
  project_id   = mongodbatlas_project.cca-mongo.id
  name         = "${var.app_full_name}-mongo-cluster"
  cluster_type = "REPLICASET"

  replication_specs = [
    {
      region_configs = [
        {
          region_name           = replace(upper(var.aws_region), "-", "_")
          priority              = 7
          provider_name         = "tenant"
          backing_provider_name = "AWS"
          electable_specs = {
            instance_size = "M0"
            node_count    = 3
          }
        }
      ]
    }
  ]
}
