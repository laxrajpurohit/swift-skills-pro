const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function copyFile(src, dest) {
  ensureDir(path.dirname(dest));
  fs.copyFileSync(src, dest);
}

function removeFile(filePath) {
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

function removeDirIfEmpty(dirPath) {
  if (fs.existsSync(dirPath)) {
    const entries = fs.readdirSync(dirPath);
    if (entries.length === 0) {
      fs.rmdirSync(dirPath);
    }
  }
}

function fileExists(filePath) {
  return fs.existsSync(filePath);
}

const REPO_URL = 'https://github.com/laxrajpurohit/swift-skills-pro.git';

function cloneRepo() {
  const tmpDir = path.join(os.tmpdir(), 'swift-skills-cli-' + Date.now());
  try {
    execSync(`git clone --depth 1 ${REPO_URL} "${tmpDir}"`, {
      stdio: 'pipe',
    });
    return tmpDir;
  } catch (err) {
    console.error('Failed to clone skills repo:', err.message);
    return null;
  }
}

function cleanupDir(dirPath) {
  if (dirPath && fs.existsSync(dirPath)) {
    fs.rmSync(dirPath, { recursive: true, force: true });
  }
}

// ANSI colors
const c = {
  green: (s) => `\x1b[32m${s}\x1b[0m`,
  red: (s) => `\x1b[31m${s}\x1b[0m`,
  yellow: (s) => `\x1b[33m${s}\x1b[0m`,
  cyan: (s) => `\x1b[36m${s}\x1b[0m`,
  bold: (s) => `\x1b[1m${s}\x1b[0m`,
  dim: (s) => `\x1b[2m${s}\x1b[0m`,
};

module.exports = {
  ensureDir,
  copyFile,
  removeFile,
  removeDirIfEmpty,
  fileExists,
  cloneRepo,
  cleanupDir,
  c,
  REPO_URL,
};
