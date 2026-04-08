#!/usr/bin/env node

/**
 * Context Engineering Context Check Command
 * Provides guidance on context usage and optimization
 */

const fs = require('fs');
const path = require('path');

async function main() {
    console.log("🧠 Context Engineering: Context Usage Check");
    console.log("==========================================");
    
    console.log("");
    console.log("📊 CONTEXT USAGE GUIDELINES");
    console.log("===========================");
    console.log("");
    console.log("🎯 TARGET USAGE BY PHASE:");
    console.log("  • Research Phase:     < 30% (heavy on discovery)");
    console.log("  • Planning Phase:     < 20% (focused structure)");
    console.log("  • Implementation:     < 35% (active coding)");
    console.log("");
    console.log("⚠️  USAGE THRESHOLDS:");
    console.log("  •  0-25%: ✅ Optimal - Full reasoning capacity");
    console.log("  • 25-35%: 🟡 Good - Monitor closely");
    console.log("  • 35-40%: 🟠 Warning - Consider progress file");
    console.log("  • 40%+:   🔴 Critical - Reset immediately");
    console.log("");
    console.log("🔍 CONTEXT-HEAVY OPERATIONS:");
    console.log("  • File reading (especially large files)");
    console.log("  • Code analysis and flow tracing");
    console.log("  • Multiple tool outputs (JSON, verbose logs)");
    console.log("  • Extended conversation history");
    console.log("  • Error message chains");
    console.log("");
    console.log("⚡ OPTIMIZATION STRATEGIES:");
    console.log("");
    console.log("1️⃣  USE SUB-AGENTS FOR DISCOVERY");
    console.log("   • Delegate 'find where X happens' tasks");
    console.log("   • Let sub-agents read multiple files");
    console.log("   • Get concise answers with file:line specificity");
    console.log("");
    console.log("2️⃣  STRATEGIC FILE READING");
    console.log("   • Use line offsets for large files (Read tool)");
    console.log("   • Grep/Glob for initial discovery");
    console.log("   • Load full files only when implementing");
    console.log("");
    console.log("3️⃣  PROGRESS FILES OVER COMPACTION");
    console.log("   • Write structured progress summaries");
    console.log("   • Include lessons learned and context");
    console.log("   • Reset with progress file as context");
    console.log("");
    console.log("4️⃣  AVOID CONTEXT POLLUTION");
    console.log("   • Don't argue with AI ('No, do this instead')");
    console.log("   • Reset with corrective guidance instead");
    console.log("   • Keep feedback concise and actionable");
    console.log("");
    console.log("🔄 WHEN TO RESET CONTEXT:");
    console.log("   • Usage approaches 35-40%");
    console.log("   • Completing major milestone");
    console.log("   • AI making repeated errors");
    console.log("   • Switching between workflow phases");
    console.log("   • Before final implementation push");
    console.log("");
    console.log("📋 CONTEXT RESET WORKFLOW:");
    console.log("   1. Run '/progress [project] reset'");
    console.log("   2. New progress file created with fresh template");
    console.log("   3. Continue work with clean context window");
    console.log("   4. Progress file provides continuity");
    console.log("");
    console.log("🎮 AVAILABLE COMMANDS:");
    console.log("   /research [project]     - Start Phase 1 (Research)");
    console.log("   /plan [project]         - Start Phase 2 (Planning)");
    console.log("   /implement [project]    - Start Phase 3 (Implementation)");
    console.log("   /progress [project]     - Update progress file");
    console.log("   /progress [project] reset - Create fresh progress file");
    console.log("   /context-check          - This guidance");
    console.log("");
    console.log("🏷️  CONTEXT FLAGS:");
    console.log("   --vast-bank or --vb     - Vast Bank context");
    console.log("   --mbanq                 - Mbanq context");
    console.log("   --secureda              - Secureda context");
    console.log("   (default: Personal context)");
    console.log("");
    console.log("💡 PRO TIPS:");
    console.log("   • Monitor context usage throughout session");
    console.log("   • Use 'Task' tool for multi-step operations");
    console.log("   • Write progress files proactively");
    console.log("   • Trust the three-phase workflow process");
    console.log("   • Quality comes from good specs, not perfect code review");
    console.log("");
    console.log("📈 SUCCESS METRICS:");
    console.log("   • < 40% average context usage");
    console.log("   • 2x development velocity improvement");
    console.log("   • 50% reduction in implementation errors");
    console.log("   • Faster iteration cycles");
    console.log("   • Higher confidence in shipped code");
}

main().catch(console.error);