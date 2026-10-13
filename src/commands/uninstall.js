const { AGENTS, skillPath, skillDir } = require('../agents');
const { SKILLS, findSkill, allSkillNames } = require('../skills');
const { cleanupDir, fileExists, c } = require('../utils');
const { uninstallHooks } = require('../hooks');

module.exports = function uninstall(skillArg) {
  let skillNames;
  if (skillArg) {
    const skill = findSkill(skillArg);
    if (!skill) {
      console.error(`${c.red('Unknown skill:')} ${skillArg}`);
      console.log(`Available: ${allSkillNames().join(', ')}`);
      process.exit(1);
    }
    skillNames = [skillArg];
  } else {
    skillNames = allSkillNames();
  }

  console.log(`\n${c.bold('Uninstalling skills...')}`);

  const results = [];

  for (const skillName of skillNames) {
    const agentResults = [];

    for (const agent of AGENTS) {
      // Hooks first: they point at scripts inside the folder about to be removed.
      const hook = uninstallHooks(skillName, agent);
      if (hook && hook.ok) console.log(`  ${c.dim('↳')} hooks removed from ${hook.file}`);
      if (hook && !hook.ok) console.log(`  ${c.yellow('!')} could not update ${hook.file}: ${hook.error}`);

      const filePath = skillPath(agent, skillName);
      const dirPath = skillDir(agent, skillName);

      if (fileExists(filePath)) {
        try {
          cleanupDir(dirPath);
          agentResults.push({ agent: agent.name, removed: true });
        } catch (err) {
          agentResults.push({ agent: agent.name, removed: false, error: err.message });
        }
      } else {
        agentResults.push({ agent: agent.name, removed: false, notPresent: true });
      }
    }

    results.push({ skill: skillName, agents: agentResults });
  }

  // Print summary
  console.log(`\n${c.bold('Uninstall Summary')}`);
  console.log('─'.repeat(50));

  let removed = 0;
  let skipped = 0;

  for (const r of results) {
    const removedAgents = r.agents.filter(a => a.removed).map(a => a.agent);
    const notPresent = r.agents.filter(a => a.notPresent);

    if (removedAgents.length > 0) {
      console.log(`  ${c.red('✗')} ${c.bold(r.skill)} removed from: ${removedAgents.join(', ')}`);
      removed++;
    } else if (notPresent.length === r.agents.length) {
      console.log(`  ${c.dim('-')} ${r.skill} — not installed`);
      skipped++;
    }
  }

  console.log('─'.repeat(50));
  console.log(`${c.red(removed + ' removed')}${skipped > 0 ? `, ${c.dim(skipped + ' not installed')}` : ''}\n`);
};
