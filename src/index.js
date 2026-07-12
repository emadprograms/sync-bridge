const { startWatcher } = require('./lib/watcher');
const { atomicTransfer } = require('./lib/transfer');
const config = require('./config');

/**
 * A simple Promise-based serial queue to ensure transfers are processed one by one.
 */
class JobQueue {
    constructor() {
        this.queue = Promise.resolve();
    }

    /**
     * Enqueues a new job.
     * @param {Function} job - A function that returns a Promise.
     */
    enqueue(job) {
        this.queue = this.queue.then(() => job());
        return this.queue;
    }
}

const queue = new JobQueue();

async function main() {
    console.log('--- Sync-Bridge Orchestrator (PC A) ---');
    console.log(`Source: ${config.sourceDir}`);
    console.log(`Target: ${config.targetDir}`);
    console.log('Starting file watcher...');

    startWatcher((filePath, fileName) => {
        // Enqueue the transfer job to the serial queue
        queue.enqueue(async () => {
            console.log(`[Queue] Processing ${fileName}...`);
            const result = await atomicTransfer(filePath, fileName);
            if (result.success) {
                console.log(`[Queue] Successfully transferred ${fileName} (Job ID: ${result.jobId})`);
            } else {
                console.error(`[Queue] Failed to transfer ${fileName}`);
            }
        });
    });
}

// Handle unexpected errors
process.on('uncaughtException', (err) => {
    console.error('[Fatal Error] Uncaught Exception:', err);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('[Fatal Error] Unhandled Rejection at:', promise, 'reason:', reason);
});

main().catch(err => {
    console.error('[Fatal Error] Main loop crashed:', err);
    process.exit(1);
});
