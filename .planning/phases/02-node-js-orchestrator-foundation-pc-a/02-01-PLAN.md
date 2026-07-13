---
requirements: [INT-01]
depends_on: [Phase 1]
wave: 1
must_haves:
  truths:
    - "Node.js environment is initialized."
    - "Project dependencies (chokidar, fs-extra, uuid) are installed."
    - "config.json contains the WhatsAppDropFolder path."
    - "Configuration loading module is operational."
  artifacts:
    - {path: "package.json", provides: "Project dependencies", min_lines: 10}
    - {path: "config.json", provides: "Path configuration", min_lines: 5}
    - {path: "src/config/index.js", provides: "Config loader", min_lines: 5}
  key_links:
    - {from: "config.json", to: "src/config/index.js", via: "JSON import"}
---

# Phase 02: Node.js Orchestrator Foundation (PC A) - Plan 1: Setup

## 1. Objective
Initialize the Node.js project environment and establish the configuration foundation.

## 2. Execution Tasks

<task id="T2.1">
  <description>Initialize Node.js project and install dependencies (chokidar, fs-extra, uuid).</description>
  <files>
    - "package.json"
    - "package-lock.json"
  </files>
  <action>Run `npm init -y` and `npm install chokidar fs-extra uuid`.</action>
  <verify>
    <automated>npm list chokidar fs-extra uuid</automated>
    Verify that package.json exists and contains chokidar, fs-extra, and uuid in dependencies.
  </verify>
  <done>Dependencies installed and project initialized.</done>
</task>

<task id="T2.2">
  <description>Update config.json with WhatsAppDropFolder path.</description>
  <files>
    - "config.json"
  </files>
  <action>Add `"WhatsAppDropFolder": "C:/path/to/whatsapp/drop"` to config.json.</action>
  <verify>
    <automated>node -e "console.log(require('./config.json').WhatsAppDropFolder)"</automated>
    Verify that the key is present and returns a string.
  </verify>
  <done>Configuration updated.</done>
</task>

<task id="T2.3">
  <description>Implement src/config/index.js for configuration loading.</description>
  <files>
    - "src/config/index.js"
  </files>
  <action>Create the file to export a structured configuration object loaded from config.json.</action>
  <verify>
    <automated>node -e "const cfg = require('./src/config/index.js'); console.log(cfg.WhatsAppDropFolder ? 'PASS' : 'FAIL')"</automated>
    Verify the module correctly exports the configuration.
  </verify>
  <done>Config module implemented.</done>
</task>
