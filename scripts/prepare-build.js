/*
  Robust prepare script for Git installs:
  - If lib/ already exists, skip
  - Otherwise, try to build using npx react-native-builder-bob
  - Fallback to building JS then generating d.ts via npx typescript
*/

const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

function pathExists(p) {
  try {
    fs.accessSync(p)
    return true
  } catch {
    return false
  }
}

function run(cmd) {
  execSync(cmd, { stdio: 'inherit', env: { ...process.env } })
}

const repoRoot = path.resolve(__dirname, '..')
const libModuleIndex = path.join(repoRoot, 'lib', 'module', 'index.js')
const libTypesIndex = path.join(repoRoot, 'lib', 'typescript', 'src', 'index.d.ts')

// Skip if already built
if (pathExists(libModuleIndex) && pathExists(libTypesIndex)) {
  process.exit(0)
}

// Prevent re-entrancy
if (process.env.PREPARE_BUILD_RUNNING === '1') {
  process.exit(0)
}

process.env.PREPARE_BUILD_RUNNING = '1'

try {
  // Primary: build both targets via bob, fetched transiently
  run('npx --yes react-native-builder-bob@0.40.13 build')
} catch (e) {
  // Fallback: build JS module only, then generate d.ts with tsc
  try {
    run('npx --yes react-native-builder-bob@0.40.13 build --target module')
  } catch (e2) {
    console.error('[prepare] Failed to build JS module with bob')
    throw e2
  }

  try {
    // Ensure output dir structure for types
    const typesOutDir = path.join(repoRoot, 'lib', 'typescript')
    if (!pathExists(typesOutDir)) {
      fs.mkdirSync(typesOutDir, { recursive: true })
    }
    // Generate d.ts only, overriding noEmit from base tsconfig
    run(
      'npx --yes typescript@5.8.3 -p tsconfig.build.json --declaration --emitDeclarationOnly --outDir lib/typescript --noEmit false'
    )
  } catch (e3) {
    console.warn('[prepare] Built JS, but failed to generate type definitions')
    // Non-fatal for runtime usage; keep going
  }
}