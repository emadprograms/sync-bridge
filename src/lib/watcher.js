const chokidar = require('chokidar');
const path = require('path');
const config = require('../config');

/**
 * Initializes and starts the file watcher on the source directory.
 * 
 * @param {Function} onFileAdded - Callback triggered when a new file is detected and stabilized.
 * @returns {chokidar.FSWatcher} The chokidar watcher instance.
 */
function startWatcher(onFileAdded) {
    const sourceDir = config.sourceDir;

    const watcher = chokidar.watch(sourceDir, {
        persistent: true,
        ignoreInitial: true,
        awaitWriteFinish: {
            stabilityThreshold: 2000,
            pollInterval: 100
        },
        ignored: [
            /\.tmp$/, // Ignore files ending in .tmp
            /(^|[\/\\])\.git[\/\\]/ // Ignore .git directory
        ]
    });

    watcher
        .on('add', (filePath) => {
            const fileName = path.basename(filePath);
            console.log(`[Watcher] New file detected: ${fileName}`);
            onFileAdded(filePath, fileName);
        })
        .on('change', (filePath) => {
            const fileName = path.basename(filePath);
            console.log(`[Watcher] File changed: ${fileName}`);
            onFileAdded(filePath, fileName);
        })
        .on('error', (error) => {
            console.error(`[Watcher Error] ${error}`);
        });

    console.log(`[Watcher] Monitoring directory: ${sourceDir}`);
    return watcher;
}

module.exports = { startWatcher };
