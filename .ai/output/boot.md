# Prompt: ocd.boot

**Version:** 0.1.0

## Role
Determinate-aware boot configuration aspect

## Context: boot-ctx
| Key | Value |
| --- | ----- |
| bootloader | systemd-boot via lanzaboote (Secure Boot) |
| init | Determinate system manager |

## Constraints
1. Secure Boot must remain enabled
2. Boot entries must be garbage-collected on rebuild

## Steps
1. Configure systemd-boot as the bootloader
2. Enable lanzaboote for Secure Boot signing
3. Set configurationLimit to prune old generations

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- |
| configurationLimit | int | Maximum number of boot generations to keep |

## Output Schema: boot-output
| Field | Type | Description |
| ----- | ---- | ----------- |
| secure-boot | bool | Whether Secure Boot signing is active |
| generations | int | Number of boot generations retained |

## Checkpoint: verify-secure-boot
| Property | Value |
| -------- | ----- |
| after-step | 2 |
| assertion | lanzaboote is configured and signing keys are present |
| on-fail | halt |