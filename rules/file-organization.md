# File Organization

## Primary Directories
- **Daily Notes**: `YYYY/QX/[W]##/MM-DD-YYYY.md` - Tactical execution and immediate work documentation
- **Work Documentation**: `Work/Jobs/` - Company-specific folders (Vast Bank, Mbanq, Black Cat Security, Secureda)
- **Personal Content**: `Personal/` - Investments, taxes, and personal matters
- **Thoughts Directory**: `thoughts/` - Central location for plans, research, and related files that don't belong to a specific project
  - `thoughts/plans/` - Implementation plans (e.g., `2025-11-24-daily-note-automation-v2.md`)
  - `thoughts/research/` - General research documents

## Project-Specific Thoughts Directories
Some projects maintain their own thoughts directories for project-specific documentation:
- **K-Town**: `Personal/Projects/K-Town/thoughts/` - K-Town specific research, plans, and progress tracking
  - `thoughts/research/YYYY-MM-DD/` - K-Town research documents
  - `thoughts/plans/YYYY-MM-DD/` - K-Town implementation plans
  - `thoughts/progress/YYYY-MM-DD/` - K-Town progress tracking

**Rule**: If work is project-specific (e.g., K-Town), use that project's thoughts directory. For general/cross-project work, use the root `thoughts/` directory.

## Context-Based Tagging
**MANDATORY**: All work must include appropriate context tags:
- `#vast_bank` - Vast Bank work
- `#personal` - Personal projects, research, learning
- `#mbanq` - Mbanq projects and initiatives
- `#secureda` - Secureda projects
- `#black_cat_security` - Black Cat Security projects

## Linking Strategy
- **Be Granular**: Link specific concepts/entities (`[[Azure AD]]`, `[[Terraform]]`)
- **Create Context**: Link meeting notes to related projects
- **Connect People**: Always link to people using `[[First Last]]` format
- **Project References**: Link to project notes and initiatives
