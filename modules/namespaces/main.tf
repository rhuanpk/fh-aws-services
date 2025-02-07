resource "kubernetes_namespace" "service-video-upload" {
  metadata {
    name = "service-video-upload"
  }
}
resource "kubernetes_namespace" "service-video-processor" {
  metadata {
    name = "service-video-processor"
  }
}
resource "kubernetes_namespace" "service-status-tracker" {
  metadata {
    name = "service-status-tracker"
  }
}
resource "kubernetes_namespace" "service-user" {
  metadata {
    name = "service-user"
  }
}
