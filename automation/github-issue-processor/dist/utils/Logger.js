import { appendFile, mkdir } from 'fs/promises';
import { dirname, resolve } from 'path';
import chalk from 'chalk';
export class Logger {
    config;
    logLevels = {
        error: 0,
        warn: 1,
        info: 2,
        debug: 3
    };
    currentLevel;
    constructor(config) {
        this.config = config;
        this.currentLevel = this.logLevels[config.level] || this.logLevels.info;
        this.ensureLogDirectory();
    }
    async ensureLogDirectory() {
        try {
            const logDir = dirname(resolve(this.config.file));
            await mkdir(logDir, { recursive: true });
        }
        catch (error) {
        }
    }
    error(message, error) {
        this.log('error', message, error);
    }
    warn(message, details) {
        this.log('warn', message, details);
    }
    info(message, details) {
        this.log('info', message, details);
    }
    debug(message, details) {
        this.log('debug', message, details);
    }
    log(level, message, details) {
        const levelNum = this.logLevels[level];
        if (levelNum > this.currentLevel) {
            return;
        }
        const timestamp = new Date().toISOString();
        const formattedMessage = `[${timestamp}] ${level.toUpperCase()}: ${message}`;
        if (this.config.console) {
            this.outputToConsole(level, formattedMessage, details);
        }
        this.outputToFile(formattedMessage, details);
    }
    outputToConsole(level, message, details) {
        let coloredMessage;
        switch (level) {
            case 'error':
                coloredMessage = chalk.red(message);
                break;
            case 'warn':
                coloredMessage = chalk.yellow(message);
                break;
            case 'info':
                coloredMessage = chalk.blue(message);
                break;
            case 'debug':
                coloredMessage = chalk.gray(message);
                break;
            default:
                coloredMessage = message;
        }
        console.log(coloredMessage);
        if (details) {
            console.log(chalk.gray(JSON.stringify(details, null, 2)));
        }
    }
    async outputToFile(message, details) {
        try {
            let logEntry = message;
            if (details) {
                logEntry += '\\n' + JSON.stringify(details, null, 2);
            }
            logEntry += '\\n';
            await appendFile(resolve(this.config.file), logEntry, 'utf-8');
        }
        catch (error) {
        }
    }
    async rotateLogs() {
        try {
            this.parseMaxFileSize(this.config.maxFileSize);
        }
        catch (error) {
            this.warn('ログローテーションエラー', error);
        }
    }
    parseMaxFileSize(sizeStr) {
        const match = sizeStr.match(/^(\\d+)(\\w+)$/i);
        if (!match)
            return 10 * 1024 * 1024;
        const size = parseInt(match[1], 10);
        const unit = match[2].toLowerCase();
        switch (unit) {
            case 'kb':
                return size * 1024;
            case 'mb':
                return size * 1024 * 1024;
            case 'gb':
                return size * 1024 * 1024 * 1024;
            default:
                return size;
        }
    }
}
//# sourceMappingURL=Logger.js.map