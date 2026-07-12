const fs = require('fs-extra');
const path = require('path');
const assert = require('assert');
const config = require('../src/config');
const { atomicTransfer } = require('../src/lib/transfer');
const { startWatcher } = require('../src/lib/watcher');

async function runTests() {
    console.log('Starting Phase 02 Logic Tests...');

    const testRoot = path.join(__dirname, 'test_env');
    const sourceDir = path.join(testRoot, 'source');
    const targetDir = path.join(testRoot, 'target');

    await fs.remove(testRoot);
    await fs.ensureDir(sourceDir);
    await fs.ensureDir(targetDir);

    const originalSourceDir = config.sourceDir;
    const originalTargetDir = config.targetDir;
    const originalLogFile = config.logFile;

    config.sourceDir = sourceDir;
    config.targetDir = targetDir;
    config.logFile = path.join(testRoot, 'test.log');

    try {
        console.log('Test 1: Atomic Transfer Logic...');
        const testFile = path.join(sourceDir, 'test.txt');
        await fs.writeFile(testFile, 'Hello World');
        
        const { jobId, success } = await atomicTransfer(testFile, 'test.txt');
        
        assert.strictEqual(success, true, 'Transfer should be successful');
        assert.ok(jobId, 'Should return a jobId');
        assert.ok(await fs.pathExists(path.join(targetDir, 'test.txt')), 'Payload should exist in target');
        assert.ok(await fs.pathExists(path.join(targetDir, 'test.txt.json')), 'Signal should exist in target');
        
        const signal = await fs.readJson(path.join(targetDir, 'test.txt.json'));
        assert.strictEqual(signal.jobId, jobId, 'Signal jobId should match returned jobId');
        console.log('Pass: Atomic Transfer');

        console.log('Test 2: Watcher Detection Logic...');
        let detectedFiles = [];
        const watcher = startWatcher((filePath, fileName) => {
            detectedFiles.push(fileName);
        });

        // Small delay to ensure watcher is fully initialized
        await new Promise(resolve => setTimeout(resolve, 500));

        await fs.writeFile(path.join(sourceDir, 'watch_me.txt'), 'content');
        
        // Increase wait time for stabilityThreshold (2000ms) + buffer
        await new Promise(resolve => setTimeout(resolve, 4000));
        assert.ok(detectedFiles.includes('watch_me.txt'), 'Watcher should detect new files');

        await fs.writeFile(path.join(sourceDir, 'ignore_me.tmp'), 'content');
        await new Promise(resolve => setTimeout(resolve, 4000));
        assert.ok(!detectedFiles.includes('ignore_me.tmp'), 'Watcher should ignore .tmp files');
        
        await watcher.close();
        console.log('Pass: Watcher Detection');

        console.log('ALL PHASE 02 LOGIC TESTS PASSED!');
    } catch (err) {
        console.error('TEST FAILED:');
        console.error(err);
        process.exit(1);
    } finally {
        config.sourceDir = originalSourceDir;
        config.targetDir = originalTargetDir;
        config.logFile = originalLogFile;
    }
}

runTests();
