const { AGENTS, skillPath } = require('../agents');
const { SKILLS } = require('../skills');
const { fileExists, c } = require('../utils');

module.exports = function list() {
  console.log(`\n${c.bold('Installed Skills')}\n`);

  // Header
  const nameCol = 25;
  const agentCol = 12;

  let header = 'Skill'.padEnd(nameCol);
  for (const agent of AGENTS) {
    header += agent.name.padEnd(agentCol);
  }
  console.log(c.bold(header));
  console.log('─'.repeat(nameCol + agentCol * AGENTS.length));

  let totalInstalled = 0;

  for (const skill of SKILLS) {
    let row = skill.name.padEnd(nameCol);
    let hasAny = false;

    for (const agent of AGENTS) {
      const exists = fileExists(skillPath(agent, skill.name));
      if (exists) {
        row += c.green('✓'.padEnd(agentCol));
        hasAny = true;
      } else {
        row += c.dim('—'.padEnd(agentCol));
      }
    }

    console.log(row);
    if (hasAny) totalInstalled++;
  }

  console.log('─'.repeat(nameCol + agentCol * AGENTS.length));
  console.log(`\n${totalInstalled}/${SKILLS.length} skills installed\n`);
};
