#!/usr/bin/env node

/**
 * Context Engineering Research Phase Command
 * Initiates Phase 1 of the three-phase workflow for ANY project type
 * Supports: Code analysis, documentation research, compliance evaluation, security assessment, business analysis
 * Creates research file with template and manages context efficiently
 */

const fs = require('fs');
const path = require('path');

async function main() {
    console.log("🔍 Context Engineering: Research Phase");
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
    let researchPath;
    
    if (context === 'Personal') {
        researchPath = path.join(basePath, 'Personal', 'Research');
    } else {
        researchPath = path.join(basePath, 'Work', 'Jobs', context, 'Research');
    }
    
    const fileName = `Research-${projectName.replace(/\s+/g, '-')}-${dateStr.replace(/\//g, '-')}.md`;
    const filePath = path.join(researchPath, fileName);
    
    // Load template
    const templatePath = path.join(basePath, 'Templates', 'Context Engineering', 'Research-Template.md');
    
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
    fs.mkdirSync(researchPath, { recursive: true });
    
    // Write file
    fs.writeFileSync(filePath, template);
    
    console.log(`✅ Research file created: ${fileName}`);
    console.log(`📁 Location: ${researchPath}`);
    console.log(`🏷️  Context: ${context}`);
    console.log("");
    console.log("🎯 RESEARCH PHASE OBJECTIVES (ALL PROJECT TYPES):");
    console.log("  📊 ANALYSIS: Understanding existing systems, documentation, processes");
    console.log("  🔍 DISCOVERY: Map relevant files, patterns, dependencies, requirements");
    console.log("  📚 RESEARCH: Web search, standards, best practices, vendor documentation"); 
    console.log("  🔗 INTEGRATION: Identify connection points and system relationships");
    console.log("  ⚡ EFFICIENCY: Context-mindful research (quality over arbitrary limits)");
    console.log("");
    console.log("🎭 PROJECT TYPES SUPPORTED:");
    console.log("  💻 CODE: Architecture analysis, dependency mapping, security review");
    console.log("  📝 DOCUMENTATION: Content analysis, gap identification, standards research");
    console.log("  🛡️  COMPLIANCE: Framework evaluation, requirement mapping, control analysis");  
    console.log("  🔒 SECURITY: Vulnerability assessment, threat modeling, control evaluation");
    console.log("  📋 BUSINESS: Process analysis, workflow optimization, requirement gathering");
    console.log("");
    console.log("📋 NEXT STEPS:");
    console.log("  1. Use Research Specialist Agent for comprehensive discovery");
    console.log("  2. Use Discovery Sub-Agent for targeted 'find where X' tasks");
    console.log("  3. Focus on specific references (file:line_number, document:section)");
    console.log("  4. Complete thorough research before moving to planning phase");
    console.log("  5. Run '/plan' command when research delivers actionable insights");
    console.log("");
    console.log(`💡 CONTEXT OPTIMIZATION: Use specialized agents to preserve main context`);
}

main().catch(console.error);