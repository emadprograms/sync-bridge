const config = require('../../config.json');

module.exports = {
    sourceDir: config.WhatsAppDropFolder,
    targetDir: config.LocalSyncPath,
    logFile: config.LogFilePath,
};
