# Incident Report - Day 36

## Scenario
Option C: Kubernetes scale test (disposable local kind cluster, namespace day36).
Extra evidence: Option A (docker stop/start) done earlier on the Docker container.

## 1. What did I change?
Scaled Deployment winter-arc-app from 2 replicas to 0 in namespace day36.

## 2. What symptom did I observe?
App became unreachable. No Pods in day36, Service endpoints showed <none>,
and curl http://localhost:8080/health failed.

## 3. Which command revealed the cause?
kubectl -n day36 get pods,svc  -> no Pods running
kubectl -n day36 get endpoints winter-arc-svc  -> <none>

## 4. What action restored service?
kubectl -n day36 scale deployment/winter-arc-app --replicas=2
kubectl -n day36 rollout status deployment/winter-arc-app

## 5. How did I verify recovery?
Deployment 2/2 Ready, both Pods 1/1 Running, Service endpoints showed 2 Pod IPs,
and curl /health returned {"status":"UP"}.

## Impact
Local test app unavailable for a short time. No data affected (app has no database).

## Root cause
Intentional: replicas set to 0 (controlled test).

## Prevention
Use at least 2 replicas, readiness probes, and monitoring/alerts on endpoint count.
