export interface LoggingConfig {
    level: string;
    file: string;
    maxFileSize: string;
    maxFiles: number;
    console: boolean;
}
export declare class Logger {
    private config;
    private logLevels;
    private currentLevel;
    constructor(config: LoggingConfig);
    private ensureLogDirectory;
    error(message: string, error?: any): void;
    warn(message: string, details?: any): void;
    info(message: string, details?: any): void;
    debug(message: string, details?: any): void;
    private log;
    private outputToConsole;
    private outputToFile;
    rotateLogs(): Promise<void>;
    private parseMaxFileSize;
}
//# sourceMappingURL=Logger.d.ts.map