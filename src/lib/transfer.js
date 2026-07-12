const fs = require('fs-extra');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const config = require('../config');

/**
 * Performs an atomic transfer of a file to the target destination.
 * The strategy is to copy the file as a .tmp file first, then rename it to the final destination.
 * A corresponding .json signal file is created using the same atomic strategy to notify the receiver.
 * 
 * @param {string} sourcePath - Absolute path to the source file.
 * @param {string} fileName - Name of the file to transfer.
 * @returns {Promise<{jobId: string, success: boolean}>}
 */
async function atomicTransfer(sourcePath, fileName) {
    const jobId = uuidv4();
    const targetDir = config.targetDir;
    const targetPath = path.join(targetDir, fileName);
    const tmpTargetPath = `${targetPath}.tmp`;
    
    const signalPath = `${targetPath}.json`;
    const tmpSignalPath = `${signalPath}.tmp`;

    try {
        // 1. Copy payload to .tmp file
        await fs.copy(sourcePath, tmpTargetPath);
        
        // 2. Create signal file as .tmp
        const signalContent = JSON.stringify({
            jobId,
            fileName,
            timestamp: new Date().toISOString(),
            source: 'PC-A'
        }, null, 2);
        await fs.writeFile(tmpSignalPath, signalContent);

        // 3. Atomic rename of payload
        await fs.rename(tmpTargetPath, targetPath);
        
        // 4. Atomic rename of signal file
        await fs.rename(tmpSignalPath, signalPath);

        return { jobId, success: true };
    } catch (error) {
        console.error(`[Transfer Error] Job ${jobId} failed for ${fileName}:`, error);
        
        // Cleanup tmp files if they exist
        await fs.remove(tmpTargetPath).catch(() => {});
        await fs.remove(tmpSignalPath).catch(() => {});
        
        return { jobId, success: false, error };
    }
}

module.exports = { atomicTransfer };
