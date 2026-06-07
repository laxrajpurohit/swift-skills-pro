const os = require('os');
const path = require('path');

const HOME = os.homedir();

const AGENTS = [
  {
    name: 'Claude Code',
    basePath: path.join(HOME, '.claude', 'skills'),
  },
  {
    name: 'Cursor',
    basePath: path.join(HOME, '.cursor', 'skills'),
  },
  {
    name: 'Codex',
    basePath: path.join(HOME, '.codex', 'skills'),
  },
  {
    name: 'Windsurf',
    basePath: path.join(HOME, '.codeium', 'windsurf', 'skills'),
  },
  {
    name: 'Generic',
    basePath: path.join(HOME, '.agents', 'skills'),
  },
];

function skillPath(agent, skillName) {
  return path.join(agent.basePath, skillName, 'SKILL.md');
}

function skillDir(agent, skillName) {
  return path.join(agent.basePath, skillName);
}

module.exports = { AGENTS, skillPath, skillDir };
