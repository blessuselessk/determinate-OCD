# Prompt: ocd.networking

**Version:** 0.1.0

## Role
OpenClaw-aware networking aspect

## Context: networking-ctx
| Key | Value |
| --- | ----- |
| firewall | Ports 443 (HTTPS) and 22 (SSH) open externally |
| gateway-port | 18789 loopback-only (proxied by Caddy) |
| dhcp | Enabled via lib.mkDefault (host-overridable) |

## Constraints
1. Gateway and webhook ports stay loopback-only
2. All external traffic must route through Caddy reverse proxy
3. SSH port must remain open for Determinate remote deploy

## Steps
1. Enable NetworkManager for connection management
2. Open firewall ports 443 (HTTPS) and 22 (SSH)
3. Verify gateway port 18789 is not in allowedTCPPorts

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- |
| hostname | string | Target machine hostname for network identity |

## Output Schema: networking-output
| Field | Type | Description |
| ----- | ---- | ----------- |
| applied | bool | Whether the networking config was applied |
| firewall-status | enum(active\|inactive) | Current firewall state after activation |

## Checkpoint: verify-loopback
| Property | Value |
| -------- | ----- |
| after-step | 3 |
| assertion | Gateway port 18789 is not in allowedTCPPorts |
| on-fail | halt |