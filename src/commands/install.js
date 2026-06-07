const fs = require('fs');
const path = require('path');
const { AGENTS, skillPath, skillDir } = require('../agents');
const { SKILLS, findSkill, allSkillNames } = require('../skills');
const { ensureDir, copyFile, fileExists, cloneRepo, cleanupDir, c } = require('../utils');

// When running via npx, skills are bundled in the package.
// Fallback: clone the repo if bundled skills not found.
function getSkillSource(skillName) {
  // Bundled path: <package-root>/<skill-name>/skills/<skill-name>/SKILL.md
  const pkgRoot = path.resolve(__dirname, '..', '..');
  const bundled = path.join(pkgRoot, skillName, 'skills', skillName, 'SKILL.md');
  if (fileExists(bundled)) {
    return { type: 'bundled', path: bundled };
  }
  return null;
}

module.exports = function install(skillArg) {
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

  // Check if skills are bundled (local/npx), else clone
  let repoDir = null;
  const firstCheck = getSkillSource(skillNames[0]);

  if (!firstCheck) {
    console.log(`\n${c.bold('Fetching skills...')}`);
    repoDir = cloneRepo();
    if (!repoDir) {
      console.error(c.red('Failed to fetch skills. Check network and try again.'));
      process.exit(1);
    }
  }

  console.log(`\n${c.bold('Installing skills...')}`);

  const results = [];

  for (const skillName of skillNames) {
    let srcFile = null;

    // Try bundled first
    const bundled = getSkillSource(skillName);
    if (bundled) {
      srcFile = bundled.path;
    } else if (repoDir) {
      // Fallback to cloned repo
      const repoPaths = [
        path.join(repoDir, skillName, 'skills', skillName, 'SKILL.md'),
        path.join(repoDir, 'skills', skillName, 'SKILL.md'),
        path.join(repoDir, skillName, 'SKILL.md'),
      ];
      for (const p of repoPaths) {
        if (fileExists(p)) {
          srcFile = p;
          break;
        }
      }
    }

    if (!srcFile) {
      results.push({ skill: skillName, status: 'not_found' });
      continue;
    }

    const agentResults = [];
    for (const agent of AGENTS) {
      const dest = skillPath(agent, skillName);
      try {
        copyFile(srcFile, dest);
        agentResults.push({ agent: agent.name, ok: true });
      } catch (err) {
        agentResults.push({ agent: agent.name, ok: false, error: err.message });
      }
    }

    results.push({ skill: skillName, status: 'installed', agents: agentResults });
  }

  // Cleanup cloned repo if used
  if (repoDir) cleanupDir(repoDir);

  // Print summary
  console.log(`\n${c.bold('Install Summary')}`);
  console.log('─'.repeat(50));

  let installed = 0;
  let failed = 0;

  for (const r of results) {
    if (r.status === 'not_found') {
      console.log(`  ${c.yellow('?')} ${r.skill} — not found`);
      failed++;
      continue;
    }

    const okAgents = r.agents.filter(a => a.ok).map(a => a.agent);
    const failAgents = r.agents.filter(a => !a.ok).map(a => a.agent);

    if (okAgents.length > 0) {
      console.log(`  ${c.green('✓')} ${c.bold(r.skill)} → ${okAgents.join(', ')}`);
      installed++;
    }
    if (failAgents.length > 0) {
      console.log(`    ${c.red('✗')} Failed: ${failAgents.join(', ')}`);
    }
  }

  console.log('─'.repeat(50));
  console.log(`${c.green(installed + ' installed')}${failed > 0 ? `, ${c.yellow(failed + ' not found')}` : ''}\n`);
};
