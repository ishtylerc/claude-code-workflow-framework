#!/usr/bin/env node

/**
 * Context Engineering Implementation Phase Command
 * Initiates Phase 3 of the three-phase workflow for ANY project type
 * Supports: Code development, documentation creation, research reports, compliance documentation, analysis deliverables
 * Executes implementation plans systematically with context optimization
 */

const fs = require('fs');
const path = require('path');

async function main() {
    console.log("💻 Context Engineering: Implementation Phase");
    console.log("==========================================");
    
    // Get current date for file naming
    const now = new Date();
    const dateStr = now.toLocaleDateString('en-US', {
        month: '2-digit',
        day: '2-digit', 
        year: 'numeric'
    });
    const timeStr = now.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: true
    });

    // Get project name from user
    const projectName = process.argv[2] || 'UnnamedProject';
    
    // Determine context (Vast Bank, Mbanq, Personal, etc.)
    let context = 'Personal';
    let companyTag = '#personal';
    
    if (process.argv.includes('--vast-bank') || process.argv.includes('--vb')) {
        context = 'Vast Bank';
        companyTag = '#vast_bank';
    } else if (process.argv.includes('--mbanq')) {
        context = 'Mbanq'; 
        companyTag = '#mbanq';
    } else if (process.argv.includes('--secureda')) {
        context = 'Secureda';
        companyTag = '#secureda';
    }

    // Set up file paths
    const basePath = `/Users/ishtyler/Documents/My Brain 2.0`;
    let plansPath;
    let progressPath;
    
    if (context === 'Personal') {
        plansPath = path.join(basePath, 'Personal', 'Plans');
        progressPath = path.join(basePath, 'Personal', 'Progress');
    } else {
        plansPath = path.join(basePath, 'Work', 'Jobs', context, 'Plans');
        progressPath = path.join(basePath, 'Work', 'Jobs', context, 'Progress');
    }
    
    // Try to find corresponding plan file
    const planFileName = `Plan-${projectName.replace(/\s+/g, '-')}-${dateStr.replace(/\//g, '-')}.md`;
    const planFilePath = path.join(plansPath, planFileName);
    
    let planExists = false;
    let actualPlanFile = '';
    
    if (fs.existsSync(planFilePath)) {
        planExists = true;
        actualPlanFile = planFileName;
    } else {
        // Look for any plan file with similar name (different date)
        if (fs.existsSync(plansPath)) {
            const planFiles = fs.readdirSync(plansPath)
                .filter(f => f.startsWith(`Plan-${projectName.replace(/\s+/g, '-')}`) && f.endsWith('.md'));
            
            if (planFiles.length > 0) {
                planExists = true;
                actualPlanFile = planFiles[planFiles.length - 1]; // Get most recent
                console.log(`📄 Found plan file: ${actualPlanFile}`);
            }
        }
    }
    
    // Create initial progress file
    const progressFileName = `Progress-${projectName.replace(/\s+/g, '-')}-${dateStr.replace(/\//g, '-')}-${timeStr.replace(/:/g, '-').replace(/\s/g, '')}.md`;
    const progressFilePath = path.join(progressPath, progressFileName);
    
    // Ensure directory exists
    fs.mkdirSync(progressPath, { recursive: true });
    
    // Create initial progress file
    const initialProgress = `---
author: Ishtyler Etienne
Created: ${dateStr}
Last Modified: ${dateStr} | ${timeStr}
tags:
  - progress
  - context_engineering
  - ${projectName.toLowerCase().replace(/\s+/g, '_')}
  - ${companyTag.replace('#', '')}
---

# Progress Report: ${projectName} - ${dateStr} ${timeStr}

## Project Context
**Implementation Plan**: [[${actualPlanFile.replace('.md', '')}]]
**Project**: ${projectName}
**Context**: ${context}

---

## 🚀 Implementation Phase Started

### Current Status
- **Phase**: Implementation Phase 3 initiated
- **Plan Status**: ${planExists ? '✅ Plan found and loaded' : '❌ No plan file found'}
- **Context Usage**: Starting fresh (0%)
- **Next Action**: ${planExists ? 'Begin Phase 1 of implementation plan' : 'Create implementation plan first'}

### Context Management Goals
- **Target Context Usage**: < 35% per phase
- **Progress File Updates**: After each major step
- **Strategic Resets**: When context reaches 35%

---

## Implementation Checklist

### Pre-Implementation Verification
- [${planExists ? 'x' : ' '}] Implementation plan available
- [ ] Development environment ready
- [ ] Required tools/dependencies available
- [ ] Tests can be run
- [ ] Backup strategy confirmed

### Phase 1: Foundation
- [ ] Step 1.1: {Will be filled from plan}
- [ ] Step 1.2: {Will be filled from plan}

### Phase 2: Core Implementation  
- [ ] Step 2.1: {Will be filled from plan}
- [ ] Step 2.2: {Will be filled from plan}

### Phase 3: Integration & Polish
- [ ] Step 3.1: {Will be filled from plan}
- [ ] Final verification and testing

---

## Context Tracking
- **Session Start Time**: ${timeStr}
- **Initial Context**: 0%
- **Target per Phase**: Foundation (25%), Core (30%), Polish (35%)
- **Reset Triggers**: 35% usage or major milestone completion

---

## Next Steps
${planExists ? 
    '1. Load implementation plan into context\n2. Begin Phase 1: Foundation work\n3. Update this progress file after each step\n4. Monitor context usage continuously' :
    '1. Create implementation plan using /plan command\n2. Get plan reviewed and approved\n3. Return to /implement when plan is ready\n4. Begin systematic implementation'}

---

*Progress tracking initiated at ${dateStr} ${timeStr}*
*Run '/progress ${projectName}' to update this file*`;

    fs.writeFileSync(progressFilePath, initialProgress);
    
    console.log(`✅ Implementation phase initiated: ${projectName}`);
    console.log(`📁 Progress file: ${progressFileName}`);
    console.log(`🏷️  Context: ${context}`);
    
    if (planExists) {
        console.log(`🔗 Implementation plan: ${actualPlanFile}`);
    } else {
        console.log(`⚠️  No implementation plan found!`);
    }
    
    console.log("");
    console.log("🎯 IMPLEMENTATION PHASE OBJECTIVES (ALL PROJECT TYPES):");
    console.log("  🚀 SYSTEMATIC EXECUTION: Follow implementation plan step-by-step");
    console.log("  📝 DELIVERABLE CREATION: Build all planned outputs (code, docs, reports, etc.)");
    console.log("  ✅ QUALITY ASSURANCE: Test, validate, and verify all deliverables");
    console.log("  📊 PROGRESS TRACKING: Update progress files and monitor completion");
    console.log("  ⚡ CONTEXT OPTIMIZATION: Strategic resets when efficiency decreases");
    console.log("");
    console.log("🎭 PROJECT TYPES SUPPORTED:");
    console.log("  💻 CODE: Development, refactoring, bug fixes, infrastructure-as-code");
    console.log("  📝 DOCUMENTATION: Technical guides, process docs, manuals, training materials");
    console.log("  📊 RESEARCH: Analysis reports, evaluation documents, recommendations");
    console.log("  🛡️  COMPLIANCE: Documentation, control implementation, audit preparation");
    console.log("  🔒 SECURITY: Assessments, remediation plans, policy implementation");
    console.log("");
    console.log("📋 IMPLEMENTATION WORKFLOW:");
    console.log("  1. Load implementation plan from Planning Agent");
    console.log("  2. Execute Phase 1: Foundation (setup, structure, prerequisites)");
    console.log("  3. Update progress → Strategic context reset if needed");
    console.log("  4. Execute Phase 2: Core Implementation (main deliverables)");
    console.log("  5. Update progress → Strategic context reset if needed");
    console.log("  6. Execute Phase 3: Integration & Polish (finalization, testing)");
    console.log("  7. Final verification and delivery confirmation");
    console.log("");
    console.log("🔄 CONTEXT MANAGEMENT:");
    console.log("  • Use Implementation Specialist Agent for systematic execution");
    console.log("  • Run '/progress' after each phase completion");
    console.log("  • Strategic context resets when efficiency decreases");
    console.log("  • Use progress files for seamless session handoffs");
    console.log("");
    
    if (!planExists) {
        console.log("❌ BLOCKED: No implementation plan found");
        console.log("   → Run '/plan' command first to create plan");
        console.log("   → Get plan reviewed and approved");
        console.log("   → Then return to '/implement'");
    } else {
        console.log("✅ READY: Implementation plan loaded");
        console.log("   → Begin with Phase 1 foundation work");
        console.log("   → Monitor context usage continuously");
        console.log("   → Update progress file regularly");
    }
}

main().catch(console.error);