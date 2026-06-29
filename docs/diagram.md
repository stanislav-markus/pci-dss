# POC Infrastructure Diagram

```mermaid
flowchart TB
  users["Finite allowed client CIDRs"] -->|"HTTPS 443 only"| alb

  subgraph vpc["Dedicated VPC"]
    subgraph public["Public subnets"]
      alb["Application Load Balancer"]
      nat["NAT Gateways"]
    end

    subgraph firewall_tier["Firewall subnets"]
      fw["AWS Network Firewall"]
    end

    subgraph app_tier["Private app subnets"]
      app["Linux app EC2"]
    end

    subgraph db_tier["Isolated database subnets"]
      db["Linux MySQL EC2"]
    end
  end

  alb -->|"HTTP 80, SG reference only"| app
  app -->|"TCP 3306, SG reference only"| db
  app -->|"HTTPS 443 / DNS"| fw
  db -->|"HTTPS 443 / DNS during bootstrap"| fw
  fw -->|"Inspected default route"| nat
  nat -->|"HTTPS 443 allowlisted by domain"| external["example.com / secureweb.com / bootstrap repos"]
```

## Security Boundaries

- The ALB is the only public entry point.
- The app instance has no public IP address.
- The database instance has no public IP address.
- App and database security groups do not use default allow-all egress.
- External web traffic is routed through AWS Network Firewall with a domain allowlist.
