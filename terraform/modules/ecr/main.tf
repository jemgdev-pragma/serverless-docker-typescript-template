resource "aws_ecr_repository" "repo" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
}

output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}
