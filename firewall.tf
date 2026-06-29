resource "aws_networkfirewall_rule_group" "egress_domains" {
  capacity = 100
  name     = "${local.name}-egress-domains"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = var.egress_allowed_domains
      }
    }
  }

  tags = merge(local.tags, {
    Name = "${local.name}-egress-domains"
  })
}

resource "aws_networkfirewall_firewall_policy" "egress" {
  name = "${local.name}-egress"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order = "DEFAULT_ACTION_ORDER"
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.egress_domains.arn
    }
  }

  tags = merge(local.tags, {
    Name = "${local.name}-egress"
  })
}

resource "aws_networkfirewall_firewall" "egress" {
  name                = "${local.name}-egress"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.egress.arn
  vpc_id              = aws_vpc.main.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall

    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = merge(local.tags, {
    Name = "${local.name}-egress"
  })
}

locals {
  firewall_endpoint_ids_by_az = {
    for sync_state in aws_networkfirewall_firewall.egress.firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }
}
