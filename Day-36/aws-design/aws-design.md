# Proposed AWS Design (DESIGN ONLY - NOT DEPLOYED)

## Request flow
User -> Route 53 (DNS) -> Application Load Balancer (public subnet)
     -> ECS Fargate tasks running the app container (private subnets)

## Public / private boundary
- Public subnets: Application Load Balancer only.
- Private subnets: app containers. No public IPs.
- Security groups: ALB allows 80/443 from internet; app allows 3000 only from the ALB.

## Image storage
Docker image stored in Amazon ECR.

## IAM roles
- Task execution role: lets ECS pull the image from ECR and write logs to CloudWatch.
- Task role: least-privilege permissions the app itself needs (none right now).

## Monitoring signals
- CloudWatch Logs: app logs (Server running on port 3000).
- ALB health check on /health.
- Alarms: unhealthy host count, 5xx errors, CPU/memory, running task count.

## Cost risks
- NAT Gateway (hourly + data charges, often the biggest surprise).
- Application Load Balancer runs 24/7.
- Fargate tasks billed while running.
- CloudWatch log storage if logs are never expired.
- Mitigation: AWS Budgets alert, set log retention, delete resources after testing.

## Status
Design only. No AWS resources were created.
