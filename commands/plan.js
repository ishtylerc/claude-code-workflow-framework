#!/usr/bin/env node

/**
 * Context Engineering Planning Phase Command
 * Initiates Phase 2 of the three-phase workflow for ANY project type
 * Supports: Code implementation plans, documentation creation plans, research report plans, compliance documentation plans
 * Creates systematic implementation plan based on research findings
 */

const fs = require('fs');
const path = require('path');

async function main() {
    console.log("📋 Context Engineering: Planning Phase");
    console.log("=====================================");
    
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
    let researchPath;
    
    if (context === 'Personal') {
        plansPath = path.join(basePath, 'Personal', 'Plans');
        researchPath = path.join(basePath, 'Personal', 'Research');
    } else {
        plansPath = path.join(basePath, 'Work', 'Jobs', context, 'Plans');
        researchPath = path.join(basePath, 'Work', 'Jobs', context, 'Research');
    }
    
    const planFileName = `Plan-${projectName.replace(/\s+/g, '-')}-${dateStr.replace(/\//g, '-')}.md`;
    const planFilePath = path.join(plansPath, planFileName);
    
    // Try to find corresponding research file
    const researchFileName = `Research-${projectName.replace(/\s+/g, '-')}-${dateStr.replace(/\//g, '-')}.md`;
    const researchFilePath = path.join(researchPath, researchFileName);
    
    let researchExists = false;
    if (fs.existsSync(researchFilePath)) {
        researchExists = true;
    } else {
        // Look for any research file with similar name (different date)
        const researchFiles = fs.readdirSync(researchPath)
            .filter(f => f.startsWith(`Research-${projectName.replace(/\s+/g, '-')}`) && f.endsWith('.md'));
        
        if (researchFiles.length > 0) {
            researchExists = true;
            console.log(`📄 Found research file: ${researchFiles[0]}`);
        }
    }
    
    // Load template
    const templatePath = path.join(basePath, 'Templates', 'Context Engineering', 'Plan-Template.md');
    
    if (!fs.existsSync(templatePath)) {
        console.error(`❌ Template not found: ${templatePath}`);
        process.exit(1);
    }
    
    let template = fs.readFileSync(templatePath, 'utf8');
    
    // Replace template variables
    template = template
        .replace(/{DATE}/g, dateStr)
        .replace(/{TIME}/g, timeStr)
        .replace(/{PROJECT_NAME}/g, projectName)
        .replace(/{PROJECT_TAG}/g, projectName.toLowerCase().replace(/\s+/g, '_'))
        .replace(/{COMPANY_TAG}/g, companyTag);
    
    // Ensure directory exists
    fs.mkdirSync(plansPath, { recursive: true });
    
    // Write file
    fs.writeFileSync(planFilePath, template);
    
    console.log(`✅ Implementation plan created: ${planFileName}`);
    console.log(`📁 Location: ${plansPath}`);
    console.log(`🏷️  Context: ${context}`);
    
    if (researchExists) {
        console.log(`🔗 Linked research file found`);
    } else {
        console.log(`⚠️  No research file found - consider running '/research' first`);
    }
    
    console.log("");
    console.log("🎯 PLANNING PHASE OBJECTIVES (ALL PROJECT TYPES):");
    console.log("  📐 BLUEPRINT: Create step-by-step implementation/creation plan");
    console.log("  ✅ VERIFICATION: Define success criteria and validation methods");
    console.log("  ⚠️  RISK MANAGEMENT: Identify potential issues and mitigation strategies");
    console.log("  🕰️  TIMELINE: Establish phases, milestones, and deliverable schedule");
    console.log("  ⚡ EFFICIENCY: Context-focused planning (structured over percentage limits)");
    console.log("");
    console.log("📋 DELIVERABLE TYPES SUPPORTED:");
    console.log("  💻 CODE: Implementation plans, refactoring blueprints, integration strategies");
    console.log("  📝 DOCUMENTATION: Content creation plans, structure design, review processes");
    console.log("  📊 RESEARCH: Report writing plans, analysis frameworks, presentation structures");
    console.log("  🛡️  COMPLIANCE: Documentation plans, control implementation, audit preparation");
    console.log("  🔒 SECURITY: Assessment plans, remediation strategies, policy creation");
    console.log("");
    console.log("📋 NEXT STEPS:");
    console.log("  1. Fill in plan details using research findings as foundation");
    console.log("  2. Define specific deliverables and quality standards");
    console.log("  3. Get plan reviewed and approved by relevant stakeholders");
    console.log("  4. Run '/implement' command when plan is finalized");
    console.log("  5. Use '/progress' to track implementation and delivery");
    console.log("");
    console.log("⚠️  CRITICAL: Plan quality determines implementation success across ALL project types");
}

main().catch(console.error);