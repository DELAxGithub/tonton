import { ProjectConfig } from '../config/ConfigManager.js';
import { Logger } from '../utils/Logger.js';
export interface ProcessingOptions {
    dryRun: boolean;
    verbose: boolean;
    issueNumber?: number;
}
export interface ProcessingResult {
    processed: number;
    successful: number;
    failed: number;
    errors: string[];
}
export declare class IssueProcessor {
    private config;
    private logger;
    private octokit;
    private claudeService;
    private githubService;
    private contextCollector;
    constructor(config: ProjectConfig, logger: Logger);
    startContinuousProcessing(options?: ProcessingOptions): Promise<void>;
    processSingleRun(options?: ProcessingOptions): Promise<ProcessingResult>;
    private getProcessableIssues;
    private processIssue;
    private generateStatusComment;
}
//# sourceMappingURL=IssueProcessor.d.ts.map