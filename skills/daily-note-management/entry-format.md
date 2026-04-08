# Daily Note Entry Format Reference

This document provides the complete comprehensive entry template with detailed field descriptions and usage guidance.

## Complete Template

```markdown
- **HH:MM AM/PM** - **[Descriptive Title]** #tag1 #tag2 #tag3

  **[WORK TYPE]**: [Brief description of work completed]

  **[Work Category]**:
  - ✅ [Primary deliverable completed]
  - ✅ [Secondary task accomplished]
  - ✅ [Technical milestone achieved]

  **Files Modified**:
  - 📝 [[File Name]] - [Description of changes]
  - 🔧 'relative/path/to/config.json' - [Configuration updates]
  - 📊 [[Another Document Name]] - [Analysis completed]

  **[Key Decisions/Insights]**:
  - 💡 [Important discovery or decision made]
  - 🎯 [Strategic direction clarified]
  - ⚠️ [Challenge identified and resolved]

  **[Roadblocks/Issues]**:
  - 🚧 [Obstacle encountered and how addressed]
  - 🔄 [Stubborn issue requiring multiple attempts]
  - ⏳ [Dependency or blocker that needs follow-up]

  **[Results/Impact Category]**:
  - [Key finding or result]
  - [Another important outcome]

  **Deliverable Created**: [[Document Name]] - [Description]

  **Strategic Value**: [How this work advances goals/objectives]

---
```

## Field Descriptions

### Header Line

#### Timestamp: `**HH:MM AM/PM**`
- Format: 12-hour time with AM/PM
- Generate using: `date '+%I:%M %p %m-%d-%Y'`
- Example: `**02:34 PM**`

#### Title: `**[Descriptive Title]**`
- Clear, action-oriented description of work
- 3-8 words typically
- Examples:
  - `**Research Specialist Skill Creation**`
  - `**K-Town Docker Configuration Fix**`
  - `**Security Report Generation for Corban Client**`

#### Tags: `#tag1 #tag2 #tag3`
- Minimum 2-3 tags, maximum 5-6
- Include context tag (#vast_bank, #personal, etc.)
- Include work type tags (#research, #documentation, #security)
- Include technology/tool tags when relevant (#docker, #aws, #python)

### Work Type: `**[WORK TYPE]**`

Common work types to use:
- `**Research Completed**`
- `**Implementation Work**`
- `**Documentation Created**`
- `**Bug Fix Applied**`
- `**Configuration Update**`
- `**Investigation Completed**`
- `**Analysis Performed**`
- `**Orchestration Work**`
- `**Infrastructure Changes**`
- `**Security Assessment**`

### Work Category: `**[Work Category]**`

Customize the category name based on work type:
- `**Implementation Tasks**`
- `**Research Activities**`
- `**Documentation Updates**`
- `**Files Created**`
- `**Bug Fixes Applied**`
- `**Configuration Changes**`

Use checkmarks (✅) for completed items:
```markdown
**Implementation Tasks**:
- ✅ Created three skill definition files
- ✅ Extracted content from CLAUDE.md
- ✅ Organized supporting documentation
```

### Files Modified: `**Files Modified**`

List ALL files created or modified with appropriate emoji and reference format:

#### Emoji Guide
- 📝 New markdown files created
- ✏️ Existing markdown files edited
- 🔧 Configuration files (JSON, YAML, TOML)
- 📊 Data/analysis files
- 🐍 Python files
- 📜 Scripts (bash, shell)
- 🎨 Frontend files (CSS, HTML, JS)
- 🏗️ Infrastructure files (Terraform, Dockerfiles)

#### Reference Format
- **Markdown files**: `[[File Name]]` (without .md extension)
- **Non-markdown files**: `'relative/path/to/file.ext'`

Examples:
```markdown
**Files Modified**:
- 📝 [[Daily Note Management Skill]] - Created comprehensive skill definition
- 🔧 'docker-compose.yml' - Added ngrok profile configuration
- 📜 'scripts/deploy.sh' - Updated deployment logic for new environment
```

### Key Decisions/Insights: `**[Key Decisions/Insights]**`

Document important discoveries, decisions, and insights:

#### Emoji Guide
- 💡 Discovery or insight
- 🎯 Strategic decision or direction
- ⚠️ Challenge identified
- 🔍 Investigation finding
- 📈 Performance improvement
- 🔒 Security consideration

Examples:
```markdown
**Key Decisions/Insights**:
- 💡 Discovered that ngrok conflicts occur when running both host and container instances
- 🎯 Decided to enforce Docker-only development to prevent environment inconsistencies
- ⚠️ Identified missing error handling in webhook processing
```

### Roadblocks/Issues: `**[Roadblocks/Issues]**`

Document obstacles encountered and how they were addressed:

#### Emoji Guide
- 🚧 Obstacle/roadblock
- 🔄 Retry/iteration required
- ⏳ Dependency/blocker
- ⚡ Quick fix applied
- 🔥 Critical issue resolved

Examples:
```markdown
**Roadblocks/Issues**:
- 🚧 Docker container networking required troubleshooting nginx proxy configuration
- 🔄 Multiple attempts needed to get ngrok tunnel properly exposed through Docker
- ⏳ Waiting on client approval before implementing Phase 2 changes
```

**Note**: This section is optional if no significant roadblocks occurred.

### Results/Impact Category: `**[Results/Impact Category]**`

Customize the category name based on work type:
- `**Research Findings**`
- `**Implementation Results**`
- `**Analysis Results**`
- `**Security Findings**`
- `**Performance Results**`
- `**Testing Results**`

List concrete outcomes:
```markdown
**Research Findings**:
- Identified 3 best practices for Claude skill organization
- Progressive disclosure pattern reduces skill file size by 60%
- Trigger descriptions require both WHAT and WHEN to activate reliably
```

### Deliverable Created: `**Deliverable Created**`

**Single deliverable**: Use this format
```markdown
**Deliverable Created**: [[Document Name]] - [Description]
```

**Multiple deliverables**: Use plural and list format
```markdown
**Deliverables Created**:
- [[Skill Definition]] - Core daily note management instructions
- [[Entry Format Guide]] - Comprehensive template documentation
- [[Examples Collection]] - Real-world usage examples
```

### Strategic Value: `**Strategic Value**`

Explain how this work advances broader goals/objectives:

Examples:
```markdown
**Strategic Value**: Modularizes CLAUDE.md, reducing file size and improving maintainability while preserving critical daily note enforcement protocols.
```

```markdown
**Strategic Value**: Enables reliable K-Town demo deployments with consistent environment across development sessions, reducing configuration drift issues.
```

```markdown
**Strategic Value**: Provides comprehensive security assessment for Corban client, supporting contract renewal and demonstrating proactive threat detection capabilities.
```

### Separator: `---`

ALWAYS end each entry with a horizontal rule to separate from previous entries:
```markdown
---
```

## Adaptive Template Usage

### Minimal Entry (Simple Work)
For straightforward tasks, a simplified version is acceptable:
```markdown
- **02:45 PM** - **Quick Configuration Fix** #infrastructure #docker

  **Configuration Update**: Fixed port mapping in docker-compose.yml

  **Files Modified**:
  - 🔧 'docker-compose.yml' - Corrected nginx port binding

  **Strategic Value**: Resolves local development access issues.

---
```

### Standard Entry (Most Work)
Use the full template for typical work:
```markdown
- **02:45 PM** - **Daily Note Management Skill Creation** #documentation #skills #modularization

  **Documentation Created**: Extracted daily note management protocol from CLAUDE.md into dedicated skill

  **Files Created**:
  - 📝 [[SKILL.md]] - Core skill definition with enforcement rules
  - 📝 [[entry-format.md]] - Comprehensive entry template guide
  - 📝 [[examples.md]] - Real-world usage examples

  **Files Modified**:
  - 📝 [[SKILL Definition]] - Added complete entry format template
  - 🔧 'relative/path/to/config.json' - [Configuration updates]

  **Key Decisions**:
  - 💡 Used progressive disclosure pattern to keep SKILL.md under 500 lines
  - 🎯 Preserved ZERO TOLERANCE enforcement language from original

  **Implementation Results**:
  - Reduced CLAUDE.md by ~200 lines
  - Created reusable skill for daily note management
  - Improved discoverability through trigger-based activation

  **Deliverables Created**:
  - [[Daily Note Management Skill]] - Complete skill package
  - [[Entry Format Guide]] - Detailed template documentation
  - [[Examples Collection]] - Real-world usage patterns

  **Strategic Value**: Modularizes CLAUDE.md, improving maintainability while preserving critical daily note enforcement. Enables skill reuse across projects.

---
```

### Extended Entry (Complex Work)
For substantial work with roadblocks and multiple insights:
```markdown
- **03:15 PM** - **K-Town Docker Multi-Mode Configuration** #k-town #docker #infrastructure #personal

  **Infrastructure Implementation**: Created intelligent LAN/WAN mode switching for K-Town with automatic detection and verification

  **Implementation Tasks**:
  - ✅ Designed dual-profile docker-compose configuration
  - ✅ Implemented automatic mode detection from docker-compose.yml
  - ✅ Created safety checks for container conflicts
  - ✅ Added comprehensive verification steps
  - ✅ Documented mode switching in project README

  **Files Modified**:
  - 🔧 'docker-compose.yml' - Added ngrok profile for WAN mode
  - 📜 'scripts/switch-mode.sh' - Created mode switching script
  - 📝 [[K-Town Development Guide]] - Updated deployment procedures
  - 🔧 '.env.example' - Added NGROK_AUTH_TOKEN configuration

  **Key Decisions**:
  - 💡 Discovered Docker profiles provide cleaner separation than environment variables
  - 🎯 Implemented dry-run mode for safe testing before actual changes
  - ⚠️ Identified need for container state verification before switching
  - 🔍 Found that nginx proxy configuration differs between LAN/WAN modes

  **Roadblocks/Issues**:
  - 🚧 Initial approach with environment variables created complex conditional logic
  - 🔄 Required three iterations to handle edge cases (containers partially started)
  - ⏳ Ngrok tunnel URL requires manual configuration in client code (future improvement)
  - 🔥 Resolved conflict between host ngrok and container ngrok instances

  **Implementation Results**:
  - LAN mode: 3 containers (server, client, nginx)
  - WAN mode: 4 containers (adds ngrok tunnel)
  - Automatic detection prevents incorrect mode switching
  - Comprehensive verification ensures clean state transitions

  **Deliverables Created**:
  - [[K-Town Mode Switching Guide]] - Complete implementation documentation
  - 'scripts/switch-mode.sh' - Automated mode switching script
  - Updated [[K-Town Docker Setup]] - Development environment guide

  **Strategic Value**: Enables seamless K-Town demo deployments for both local testing (LAN) and public demonstrations (WAN), reducing deployment complexity and preventing environment configuration errors. Supports faster iteration during development while maintaining production-ready demo capabilities.

---
```

## Special Cases

### Slash Command Completion

For slash command work, include command details:
```markdown
- **04:20 PM** - **Security Report Generation** #black_cat_security #security_report #foi

  **Slash Command Execution**: Generated comprehensive security incident report for FOI client

  **Command Details**:
  - Command: `/security-report --client=FOI --incident=phishing-campaign-2025-12-09`
  - Output: Generated structured incident report with timeline and remediation steps
  - Files: [[FOI-Phishing-Incident-2025-12-09]]

  **Analysis Completed**:
  - ✅ Examined email headers and routing information
  - ✅ Identified 37 affected user accounts
  - ✅ Documented attack vector and payload characteristics
  - ✅ Created remediation timeline with verification steps

  **Files Created**:
  - 📝 [[FOI-Phishing-Incident-2025-12-09]] - Complete incident report
  - 📊 'reports/foi-affected-users.csv' - List of impacted accounts

  **Security Findings**:
  - Spear-phishing campaign targeted finance department
  - Payload delivered through SharePoint link redirection
  - 3 users clicked malicious link, no credential compromise detected

  **Deliverable Created**: [[FOI-Phishing-Incident-2025-12-09]] - Comprehensive security incident documentation

  **Strategic Value**: Provides client with detailed incident analysis supporting security awareness training initiatives and demonstrating SOC response capabilities.

---
```

### Sub-Agent Orchestration

When orchestrating sub-agents, document the orchestration:
```markdown
- **05:30 PM** - **Research Workflow Orchestration** #research #orchestration #skills

  **Orchestration Work**: Coordinated Research Specialist agent for comprehensive skill system analysis

  **Orchestration Tasks**:
  - ✅ Loaded Research Specialist with skill system context
  - ✅ Provided research parameters and constraints
  - ✅ Reviewed research outputs for completeness
  - ✅ Integrated findings into skill creation process

  **Agent Activities**:
  - Research Specialist analyzed 5 Claude skill repositories
  - Identified 3 best practices for skill organization
  - Generated comprehensive recommendations document

  **Files Created**:
  - 📝 [[Claude Skills Best Practices Research]] - Research Specialist output
  - 📝 [[Skill System Design Decisions]] - Integration of research findings

  **Research Findings**:
  - Progressive disclosure pattern most effective for complex skills
  - Trigger descriptions must include both WHAT and WHEN
  - Examples significantly improve skill adoption and correct usage

  **Deliverable Created**: [[Claude Skills Research Report]] - Comprehensive analysis of skill system patterns

  **Strategic Value**: Informs skill system design decisions with research-backed best practices, improving skill effectiveness and maintainability.

---
```

## Table Formatting in Entries

When including tables in daily note entries (e.g., comparison matrices, inventory lists, risk assessments), follow these rules to ensure proper rendering in Obsidian:

### Critical Rule: Blank Line Before Tables

Markdown tables **require a blank line before them** to render properly. Without the blank line, Obsidian displays raw pipe characters instead of a formatted table.

**WRONG** (table won't render):
```markdown
  **K-Town Asset Inventory**:
  | Category | Count | Location |
  |----------|-------|----------|
  | Models | 72 | `client/public/models/` |
```

**CORRECT** (table renders properly):
```markdown
  **K-Town Asset Inventory**:

  | Category | Count | Location |
  |----------|-------|----------|
  | Models | 72 | `client/public/models/` |
```

### Table Formatting Best Practices

1. **Always add a blank line** between the heading/label and the table
2. **Maintain consistent column counts** across all rows (same number of `|` pipes)
3. **Use at least 3 dashes** in separator row (`|---|---|---|`)
4. **Indent consistently** if table is inside an entry (2 spaces for entry content)

### Common Table Types in Entries

**Comparison Matrix**:
```markdown
  **Technical Comparison**:

  | Aspect | Option A | Option B |
  |--------|----------|----------|
  | Performance | Fast | Moderate |
  | Cost | $100/mo | $50/mo |
```

**Risk/Priority Matrix**:
```markdown
  **Risk Assessment**:

  | Risk | Impact | Likelihood | Priority |
  |------|--------|------------|----------|
  | Data loss | High | Low | Medium |
  | Downtime | Medium | Medium | Medium |
```

**Inventory/Asset List**:
```markdown
  **Asset Inventory**:

  | Category | Count | Location |
  |----------|-------|----------|
  | Images | 50 | `assets/images/` |
  | Scripts | 12 | `scripts/` |
```

## File Reference Examples

### Markdown Files (use [[brackets]])
```markdown
- 📝 [[Daily Note Management Guide]] - Comprehensive procedures
- 📝 [[K-Town GDD Section 1 Synthesis]] - Game design document section
- 📝 [[Security Assessment Report]] - Client security analysis
- 📝 [[Implementation Plan]] - Phase 2 development plan
```

### Configuration Files (use 'quotes')
```markdown
- 🔧 'docker-compose.yml' - Added ngrok profile
- 🔧 'package.json' - Updated dependencies
- 🔧 '.env.example' - Added environment variables
- 🔧 'nginx.conf' - Configured reverse proxy
```

### Scripts (use 'quotes')
```markdown
- 📜 'scripts/deploy.sh' - Updated deployment logic
- 📜 'scripts/daily-note-automation-macos.sh' - Fixed task rollover
- 📜 'bin/backup-vault.sh' - Added encryption support
```

### Code Files (use 'quotes')
```markdown
- 🐍 'src/api/auth.py' - Implemented JWT validation
- 🎨 'client/src/App.tsx' - Added new component
- 🏗️ 'infrastructure/terraform/main.tf' - Configured AWS resources
```

## Context Tag Examples

### Work Context Tags
```markdown
#vast_bank #mbanq #secureda #black_cat_security #personal
```

### Work Type Tags
```markdown
#research #documentation #implementation #bug_fix #security
#infrastructure #analysis #investigation #orchestration
```

### Technology Tags
```markdown
#docker #kubernetes #aws #python #typescript #terraform
#postgresql #redis #nginx #sentinelone #microsoft_sentinel
```

### Project Tags
```markdown
#k-town #jarvis #kas-doodz #daily_note_automation
```

### Client Tags
```markdown
#eckerd #foi #corban #alaw #envera #vantage_point
```

## Emoji Quick Reference

### File Types
- 📝 Markdown files
- ✏️ Edited markdown
- 🔧 Config files
- 📊 Data files
- 🐍 Python
- 📜 Scripts
- 🎨 Frontend
- 🏗️ Infrastructure

### Insights
- 💡 Discovery
- 🎯 Decision
- ⚠️ Challenge
- 🔍 Investigation
- 📈 Improvement
- 🔒 Security

### Issues
- 🚧 Roadblock
- 🔄 Retry
- ⏳ Blocker
- ⚡ Quick fix
- 🔥 Critical issue

### Status
- ✅ Complete
- 🔄 In progress
- ⏸️ Paused
- ❌ Failed
- ⏭️ Skipped
