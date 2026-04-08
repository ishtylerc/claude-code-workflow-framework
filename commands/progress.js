#!/usr/bin/env node

/**
 * Context Engineering Progress File Command
 * Updates progress file with current implementation status
 * Manages context resets and handoffs between sessions
 */

const fs = require('fs');
const path = require('path');

async function main() {
    console.log("📊 Context Engineering: Progress Update");
    console.log("=====================================");
    
    // Get current date and time
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
    const timestamp = `${dateStr} | ${timeStr}`;

    // Get project name and action from command line
    const projectName = process.argv[2] || 'UnnamedProject';
    const action = process.argv[3] || 'update'; // update, reset, complete
    
    // Determine context
    let context = 'Personal';
    
    if (process.argv.includes('--vast-bank') || process.argv.includes('--vb')) {
        context = 'Vast Bank';
    } else if (process.argv.includes('--mbanq')) {
        context = 'Mbanq';
    } else if (process.argv.includes('--secureda')) {
        context = 'Secureda';
    }

    // Set up file paths
    const basePath = `/Users/ishtyler/Documents/My Brain 2.0`;
    let progressPath;
    
    if (context === 'Personal') {
        progressPath = path.join(basePath, 'Personal', 'Progress');
    } else {
        progressPath = path.join(basePath, 'Work', 'Jobs', context, 'Progress');
    }
    
    // Find existing progress file
    let progressFiles = [];
    if (fs.existsSync(progressPath)) {
        progressFiles = fs.readdirSync(progressPath)
            .filter(f => f.startsWith(`Progress-${projectName.replace(/\s+/g, '-')}`) && f.endsWith('.md'))
            .sort()
            .reverse(); // Most recent first
    }
    
    if (progressFiles.length === 0) {
        console.log(`❌ No progress file found for project: ${projectName}`);
        console.log(`💡 Run '/implement ${projectName}' to start implementation tracking`);
        process.exit(1);
    }
    
    const currentProgressFile = progressFiles[0];
    const progressFilePath = path.join(progressPath, currentProgressFile);
    
    console.log(`📄 Progress file: ${currentProgressFile}`);
    console.log(`🏷️  Context: ${context}`);
    console.log(`🎯 Action: ${action}`);
    
    // Handle different actions
    switch (action.toLowerCase()) {
        case 'update':
        case 'checkpoint':
            console.log("");
            console.log("🔄 PROGRESS UPDATE MODE");
            console.log("=====================");
            console.log("This will help you update the progress file with:");
            console.log("  • Completed tasks and outcomes");
            console.log("  • Current context usage percentage");
            console.log("  • Key insights and discoveries");
            console.log("  • Next steps and priorities");
            console.log("");
            console.log("📝 MANUAL STEPS:");
            console.log("  1. Open the progress file in your editor");
            console.log("  2. Update the relevant sections with current status");
            console.log("  3. Add new insights to 'Key Discoveries & Insights'");
            console.log("  4. Update 'Next Session Preparation' section");
            console.log("  5. Note current context usage percentage");
            break;
            
        case 'reset':
            const resetFileName = `Progress-${projectName.replace(/\s+/g, '-')}-${dateStr.replace(/\//g, '-')}-${timeStr.replace(/:/g, '-').replace(/\s/g, '')}-RESET.md`;
            const resetFilePath = path.join(progressPath, resetFileName);
            
            // Load template for fresh progress file
            const templatePath = path.join(basePath, 'Templates', 'Context Engineering', 'Progress-Template.md');
            
            if (!fs.existsSync(templatePath)) {
                console.error(`❌ Template not found: ${templatePath}`);
                process.exit(1);
            }
            
            let template = fs.readFileSync(templatePath, 'utf8');
            
            // Replace template variables
            template = template
                .replace(/{DATE}/g, dateStr)
                .replace(/{TIME}/g, timeStr)
                .replace(/{TIMESTAMP}/g, timestamp)
                .replace(/{PROJECT_NAME}/g, projectName)
                .replace(/{PROJECT_TAG}/g, projectName.toLowerCase().replace(/\s+/g, '_'))
                .replace(/{COMPANY_TAG}/g, context === 'Personal' ? '#personal' : `#${context.toLowerCase().replace(/\s+/g, '_')}`);
            
            fs.writeFileSync(resetFilePath, template);
            
            console.log("");
            console.log("🔄 CONTEXT RESET COMPLETE");
            console.log("========================");
            console.log(`✅ New progress file created: ${resetFileName}`);
            console.log("🎯 This provides a fresh context window for continuing work");
            console.log("");
            console.log("📋 RESET BENEFITS:");
            console.log("  • Clean context window (0% usage)");
            console.log("  • Fresh start for complex operations");
            console.log("  • Maintains progress history");
            console.log("  • Optimizes AI reasoning capacity");
            break;
            
        case 'complete':
            console.log("");
            console.log("🎉 PROJECT COMPLETION MODE");
            console.log("=========================");
            console.log("Mark the project as completed and summarize outcomes:");
            console.log("");
            console.log("📝 COMPLETION CHECKLIST:");
            console.log("  • All implementation phases completed");
            console.log("  • Tests passing and verified");
            console.log("  • Documentation updated");
            console.log("  • Code reviewed and approved");
            console.log("  • Performance metrics acceptable");
            console.log("");
            console.log("📊 Update the progress file with:");
            console.log("  • Final status summary");
            console.log("  • Success metrics achieved");
            console.log("  • Lessons learned");
            console.log("  • Recommendations for future");
            break;
            
        default:
            console.log(`❌ Unknown action: ${action}`);
            console.log("📋 Available actions: update, reset, complete");
            process.exit(1);
    }
    
    console.log("");
    console.log("📁 PROGRESS FILE LOCATION:");
    console.log(`   ${progressFilePath}`);
    console.log("");
    console.log("🔗 WORKFLOW INTEGRATION:");
    console.log("  • Update daily note with progress summary");
    console.log("  • Link progress file in project hub");
    console.log("  • Use progress for context handoffs");
    console.log("  • Track context usage patterns");
    console.log("");
    console.log("⚡ CONTEXT OPTIMIZATION TIPS:");
    console.log("  • Reset context when usage > 35%");
    console.log("  • Write progress before major context operations");
    console.log("  • Use sub-agents for heavy discovery work");
    console.log("  • Keep focus on current implementation phase");
}

main().catch(console.error);