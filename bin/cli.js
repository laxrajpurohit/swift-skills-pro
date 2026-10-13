#!/usr/bin/env node

const { c } = require('../src/utils');

const argv = process.argv.slice(2);
const flags = argv.filter(a => a.startsWith('--'));
const args = argv.filter(a => !a.startsWith('--'));
const command = args[0] || argv[0];
const skillArg = args[1];

function showHelp() {
  console.log(`
${c.bold('swift-skills-cli')} — Install Swift AI skills to all agent paths

${c.bold('Usage:')}
  swift-skills-cli install [skill]     Install one or all skills
    --no-hooks                         Skip registering agent hooks (swift-guardrails-pro)
  swift-skills-cli uninstall [skill]   Remove one or all skills
  swift-skills-cli list                Show installed skills per agent

${c.bold('Examples:')}
  swift-skills-cli install             Install all 12 skills
  swift-skills-cli install swiftui-pro Install one skill
  swift-skills-cli uninstall           Uninstall all skills
  swift-skills-cli list                Show status table

${c.bold('Skills:')}
  swiftui-pro, swift-concurrency-pro, swift-architecture-pro,
  swift-language-pro, swift-testing-pro, swift-performance-pro,
  swift-accessibility-pro, swift-security-pro, core-data-pro,
  swiftdata-pro, app-intents-pro, swift-guardrails-pro

${c.bold('Agent hooks')} (swift-guardrails-pro, for agents installed on this machine):
  Claude Code  ~/.claude/settings.json
  Cursor       ~/.cursor/hooks.json
  Codex        ~/.codex/hooks.json          (trust them once with /hooks)
  Windsurf     ~/.codeium/windsurf/hooks.json

${c.bold('Agent Paths:')}
  Claude Code  ~/.claude/skills/<skill>/SKILL.md
  Cursor       ~/.cursor/skills/<skill>/SKILL.md
  Codex        ~/.codex/skills/<skill>/SKILL.md
  Windsurf     ~/.codeium/windsurf/skills/<skill>/SKILL.md
  Generic      ~/.agents/skills/<skill>/SKILL.md
`);
}

if (!command || command === 'help' || command === '--help' || command === '-h') {
  showHelp();
  process.exit(0);
}

switch (command) {
  case 'install':
    require('../src/commands/install')(skillArg, { hooks: !flags.includes('--no-hooks') });
    break;
  case 'uninstall':
    require('../src/commands/uninstall')(skillArg);
    break;
  case 'list':
    require('../src/commands/list')();
    break;
  default:
    console.error(`${c.red('Unknown command:')} ${command}`);
    showHelp();
    process.exit(1);
}
