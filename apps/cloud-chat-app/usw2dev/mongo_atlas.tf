resource "mongodbatlas_project" "this" {
  name   = "${var.app_full_name}-mongo"
  org_id = var.TFC_MONGO_ATLAS_ORG_ID
}
