# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-28

### Added
- `NotificationStore.search()` for combining query, priority, channel, and date-range filters with AND semantics
- `LoggingDeliveryBackend` decorator that emits each notification to a sink before delegating to an inner backend

### Fixed
- Corrected README requirements line to reflect actual SDK constraint (`Dart >= 3.6`)

## [0.3.0] - 2026-04-02

### Added
- `NotificationTemplate` for reusable notification formats with `{{variable}}` substitution
- `NotificationTemplate.placeholders` to extract placeholder names
- `RateLimiter` for per-channel delivery cooldowns
- `NotificationStore.removeWhere()` for bulk removal by predicate
- `NotificationManager` now supports optional `RateLimiter` integration

## [0.2.0] - 2026-04-01

### Added
- `DeliveryStatus` enum with pending, delivered, failed, and retrying states
- `groupId` field on `Notification` for grouping related notifications
- `deliveryStatus` field on `Notification` with default of `DeliveryStatus.pending`
- `NotificationStore.byGroup()` to filter notifications by group ID
- `NotificationStore.byStatus()` to filter notifications by delivery status
- `NotificationScheduler.scheduleRepeating()` to schedule repeating notifications at a fixed interval

## [0.1.0] - 2026-04-01

### Added
- Initial release
- `Notification` class with auto-generated IDs, title, body, channel, priority, payload, and scheduling
- `NotificationChannel` with name, importance, sound, and description
- `Priority` enum (low, normal, high, urgent) and `Importance` enum (low, normal, high)
- `NotificationStore` for in-memory CRUD with filtering by channel and priority
- `NotificationScheduler` for scheduling, cancelling, rescheduling, and delivering due notifications
- `DeliveryBackend` abstract interface with `MemoryDeliveryBackend` for testing
- `NotificationManager` high-level facade with delivery callbacks
