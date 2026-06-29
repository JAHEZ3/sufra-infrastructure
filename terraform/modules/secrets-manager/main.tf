# Secrets Manager module: manages a set of application secrets. Each secret
# can hold a string, a JSON object (value_map), or be left empty as a
# placeholder to be populated out-of-band.

locals {
  name = "${var.project}-${var.environment}"

  # Secrets that have an initial value to write a version for.
  secrets_with_value = {
    for k, v in var.secrets : k => v
    if v.value != null || v.value_map != null
  }
}

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name        = "${local.name}/${each.key}"
  description = each.value.description
  kms_key_id  = var.kms_key_id

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, {
    Name = "${local.name}/${each.key}"
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.secrets_with_value

  secret_id = aws_secretsmanager_secret.this[each.key].id

  # value_map is serialized to JSON; value is stored as-is.
  secret_string = each.value.value_map != null ? jsonencode(each.value.value_map) : each.value.value

  # Let the value drift after creation - rotations happen outside Terraform.
  lifecycle {
    ignore_changes = [secret_string]
  }
}
