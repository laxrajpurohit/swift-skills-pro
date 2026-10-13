const fs = require('fs');
const os = require('os');
const path = require('path');
const { skillDir } = require('./agents');
const { ensureDir } = require('./utils');

const HOME = os.homedir();

// Each agent's hook config: where it lives, the folder that shows the agent is
// installed, and the entries to add. `cmd(event)` builds the shell command for
// one of the two guardrail events, `post-edit` and `pre-commit`.
const HOOK_TARGETS = {
  'Claude Code': {
    file: path.join(HOME, '.claude', 'settings.json'),
    detect: path.join(HOME, '.claude'),
    agent: 'claude',
    entries: (cmd) => ({
      PostToolUse: { matcher: 'Edit|Write|MultiEdit', hooks: [{ type: 'command', command: cmd('post-edit'), timeout: 60 }] },
      PreToolUse: { matcher: 'Bash', hooks: [{ type: 'command', command: cmd('pre-commit'), timeout: 120 }] },
    }),
  },
  Cursor: {
    file: path.join(HOME, '.cursor', 'hooks.json'),
    detect: path.join(HOME, '.cursor'),
    agent: 'cursor',
    base: { version: 1 },
    entries: (cmd) => ({
      postToolUse: { command: cmd('post-edit'), matcher: 'Write', timeout: 60 },
      beforeShellExecution: { command: cmd('pre-commit'), timeout: 120 },
    }),
  },
  Codex: {
    file: path.join(HOME, '.codex', 'hooks.json'),
    detect: path.join(HOME, '.codex'),
    agent: 'codex',
    note: 'Codex runs new hooks only after you trust them: run /hooks in Codex.',
    entries: (cmd) => ({
      PostToolUse: { matcher: 'apply_patch|Edit|Write', hooks: [{ type: 'command', command: cmd('post-edit'), timeout: 60 }] },
      PreToolUse: { matcher: 'Bash', hooks: [{ type: 'command', command: cmd('pre-commit'), timeout: 120 }] },
    }),
  },
  Windsurf: {
    file: path.join(HOME, '.codeium', 'windsurf', 'hooks.json'),
    detect: path.join(HOME, '.codeium', 'windsurf'),
    agent: 'windsurf',
    entries: (cmd) => ({
      post_write_code: { command: cmd('post-edit'), show_output: true },
      pre_run_command: { command: cmd('pre-commit'), show_output: true },
    }),
  },
};

// Every command we write contains this, which is how uninstall finds our entries.
function marker(skillName) {
  return `/${skillName}/scripts/agent-hook.sh`;
}

function readConfig(file) {
  if (!fs.existsSync(file)) return {};
  const raw = fs.readFileSync(file, 'utf8');
  if (!raw.trim()) return {};
  return JSON.parse(raw); // throws on a file we can't safely rewrite
}

function writeConfig(file, config) {
  ensureDir(path.dirname(file));
  const tmp = `${file}.tmp-${process.pid}`;
  fs.writeFileSync(tmp, JSON.stringify(config, null, 2) + '\n');
  fs.renameSync(tmp, file);
}

// Drops our entries: a flat hook ({ command }) or one inside a matcher group ({ hooks: [...] }).
function stripEntries(config, mark) {
  const hooks = config.hooks;
  if (!hooks || typeof hooks !== 'object') return;
  for (const event of Object.keys(hooks)) {
    if (!Array.isArray(hooks[event])) continue;
    hooks[event] = hooks[event]
      .map((entry) => {
        if (entry && Array.isArray(entry.hooks)) {
          const kept = entry.hooks.filter((h) => !String(h.command || '').includes(mark));
          return kept.length ? { ...entry, hooks: kept } : null;
        }
        return String((entry && entry.command) || '').includes(mark) ? null : entry;
      })
      .filter(Boolean);
    if (hooks[event].length === 0) delete hooks[event];
  }
  if (Object.keys(hooks).length === 0) delete config.hooks;
}

// Agents whose app is on this machine. Call before copying skills, which creates the folders.
function presentAgents() {
  return Object.keys(HOOK_TARGETS).filter((name) => fs.existsSync(HOOK_TARGETS[name].detect));
}

function installHooks(skillName, agent, present) {
  const target = HOOK_TARGETS[agent.name];
  if (!target || !present.includes(agent.name)) return null;

  const script = path.join(skillDir(agent, skillName), 'scripts', 'agent-hook.sh');
  const cmd = (event) => `bash "${script}" ${target.agent} ${event}`;

  try {
    const config = readConfig(target.file);
    stripEntries(config, marker(skillName));
    Object.assign(config, { ...target.base, ...config });
    config.hooks = config.hooks || {};
    for (const [event, entry] of Object.entries(target.entries(cmd))) {
      config.hooks[event] = (config.hooks[event] || []).concat(entry);
    }
    writeConfig(target.file, config);
    return { ok: true, file: target.file, note: target.note };
  } catch (err) {
    return { ok: false, file: target.file, error: err.message };
  }
}

function uninstallHooks(skillName, agent) {
  const target = HOOK_TARGETS[agent.name];
  if (!target || !fs.existsSync(target.file)) return null;
  try {
    const config = readConfig(target.file);
    const before = JSON.stringify(config);
    stripEntries(config, marker(skillName));
    if (JSON.stringify(config) === before) return null;
    writeConfig(target.file, config);
    return { ok: true, file: target.file };
  } catch (err) {
    return { ok: false, file: target.file, error: err.message };
  }
}

module.exports = { presentAgents, installHooks, uninstallHooks };
