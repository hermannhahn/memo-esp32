#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Resolve the root project directory by traversing upwards
function findProjectDir() {
    let current = process.cwd();
    while (true) {
        if (fs.existsSync(path.join(current, 'CMakeLists.txt')) && fs.existsSync(path.join(current, 'main'))) {
            return current;
        }
        const parent = path.dirname(current);
        if (parent === current) {
            break;
        }
        current = parent;
    }
    return path.resolve(__dirname, '../../');
}

const projectDir = findProjectDir();
const isWindows = process.platform === 'win32';

function runCommand(command, showOutput = true) {
    try {
        const options = { cwd: projectDir, stdio: showOutput ? 'inherit' : 'pipe' };
        execSync(command, options);
        return true;
    } catch (error) {
        try {
            const options = { cwd: projectDir, stdio: 'pipe' };
            const output = execSync(command, options);
            if (showOutput && output) {
                console.log(output.toString());
            }
            return true;
        } catch (innerError) {
            if (showOutput) {
                console.error(`❌ Error executing command: ${command}`);
                console.error(innerError.message || innerError);
                if (innerError.stdout) console.log(innerError.stdout.toString());
                if (innerError.stderr) console.error(innerError.stderr.toString());
            }
            return false;
        }
    }
}

function runBuildScript(args = []) {
    const params = args.join(' ');
    const cmd = isWindows ? `build.bat ${params}` : `pwsh ./build.ps1 ${params}`;
    return runCommand(cmd.trim());
}

function runBuildDevScript(args = []) {
    const params = args.join(' ');
    const cmd = isWindows
        ? `powershell -ExecutionPolicy Bypass -File .\\build-dev.ps1 ${params}`
        : `pwsh ./build-dev.ps1 ${params}`;
    return runCommand(cmd.trim());
}

function runFlashScript(port) {
    const param = port ? `-Port ${port}` : '';
    const cmd = isWindows ? `flash.bat ${param}` : `pwsh ./flash.ps1 ${param}`;
    return runCommand(cmd.trim());
}

function runPublishScript(flags = '') {
    const cmd = isWindows ? `publish.bat ${flags}` : `pwsh ./publish.ps1 ${flags}`;
    return runCommand(cmd.trim());
}

const args = process.argv.slice(2);
const command = args[0];

if (!command) {
    printHelp();
    process.exit(0);
}

switch (command) {
    case 'build': {
        console.log('🛠️  Building release firmware...');
        const buildArgs = args.slice(1);
        runBuildScript(buildArgs);
        break;
    }

    case 'build-dev': {
        console.log('🛠️  Fast development build...');
        const devArgs = args.slice(1);
        runBuildDevScript(devArgs);
        break;
    }

    case 'flash': {
        const port = args[1] && !args[1].startsWith('-') ? args[1] : '';
        console.log(`⚡ Flashing firmware to ESP32${port ? ` on ${port}` : ''}...`);
        runFlashScript(port);
        break;
    }

    case 'test': {
        console.log('🔄 Fast development build + Flash to ESP32...');
        const testPort = args[1] && !args[1].startsWith('-') ? args[1] : '';
        if (runBuildDevScript()) {
            runFlashScript(testPort);
        } else {
            console.error('❌ Build failed. Flash aborted.');
            process.exit(1);
        }
        break;
    }

    case 'publish': {
        const versionType = args[1];
        const resetUpdates = args.includes('--reset-updates');

        if (versionType && !versionType.startsWith('-')) {
            const normalized = versionType.toLowerCase();
            if (!['major', 'minor', 'patch'].includes(normalized)) {
                console.error('❌ Invalid version type. Choose between: major, minor, or patch.');
                console.error('Usage: memo publish [major|minor|patch] [--reset-updates]');
                process.exit(1);
            }
            console.log(`📦 Publishing release (next version increment: ${normalized})...`);
            let flags = `-v ${normalized}`;
            if (resetUpdates) flags += ' --reset-updates';
            runPublishScript(flags);
        } else {
            console.log('📦 Publishing release (next increment: patch by default)...');
            let flags = '-v patch';
            if (resetUpdates) flags += ' --reset-updates';
            runPublishScript(flags);
        }
        break;
    }

    case 'release': {
        console.log('🚀 Full build + release publication sequence...');
        console.log('   Step 1/2: Building release binary...');
        if (!runBuildScript()) {
            console.error('❌ Build failed. Release publication aborted.');
            process.exit(1);
        }
        console.log('   Step 2/2: Publishing release...');
        const relVersionType = args[1];
        const relReset = args.includes('--reset-updates');
        let relFlags = '-v patch';
        if (relVersionType && ['major', 'minor', 'patch'].includes(relVersionType.toLowerCase())) {
            relFlags = `-v ${relVersionType.toLowerCase()}`;
        }
        if (relReset) relFlags += ' --reset-updates';
        runPublishScript(relFlags);
        break;
    }

    case 'compile': {
        console.log('📦 Compiling board via scripts/build.py...');
        const compileArgs = args.slice(1).join(' ');
        runCommand(`python scripts/build.py ${compileArgs}`);
        break;
    }

    case 'list-boards': {
        console.log('📋 Listing all supported boards and variants...');
        runCommand('python scripts/build.py --list-boards');
        break;
    }

    case 'gen-lang': {
        console.log('🌐 Generating project translations (gen_lang.py)...');
        runCommand('python scripts/gen_lang.py');
        break;
    }

    case 'assets': {
        console.log('🖼️  Compiling default assets partition (build_default_assets.py)...');
        runCommand('python scripts/build_default_assets.py');
        break;
    }

    case 'audio-debug': {
        console.log('🔊 Starting audio debug server (audio_debug_server.py)...');
        runCommand('python scripts/audio_debug_server.py');
        break;
    }

    case 'download-runs': {
        console.log('📥 Downloading GitHub Actions artifacts (download_github_runs.py)...');
        runCommand('python scripts/download_github_runs.py');
        break;
    }

    case 'help':
    case '--help':
    case '-h':
        printHelp();
        break;

    default:
        console.error(`❌ Unknown command: "${command}"`);
        printHelp();
        process.exit(1);
}

function printHelp() {
    console.log(`
⚙️  MEMO ESP32 CLI Tool

Usage:
  memo <command> [options]

Available Commands:
  build [board] [variant]   Builds release firmware via build.ps1 (scripts/build.py + merge-bin + copies to releases/).
                            Does NOT perform git operations.
  build-dev [board]         Fast development build via build-dev.ps1.
  flash [port]              Flashes the compiled merged binary to the ESP32 (default port: COM4).
  test [port]               Executes build-dev followed by flash.
  publish [version] [--reset-updates]
                            Publishes current release: merges development -> main,
                            creates GitHub Release with binary assets on hermannhahn/memo-esp32,
                            updates manifest.json, and bumps next version (patch/minor/major).
                            Run "memo build" before publishing!
  release [version]         Full release sequence: build + publish.
  compile [board] [flags]   Compiles board variants using scripts/build.py.
  list-boards               Lists all supported hardware boards and variants.
  gen-lang                  Generates/updates language translations.
  assets                    Builds default SPIFFS assets image.
  audio-debug               Runs audio streaming debug server.
  help                      Displays this help guide.
`);
}
