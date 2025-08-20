import { ProjectConfig } from '../config/ConfigManager.js';
import { Logger } from '../utils/Logger.js';
export interface AnalyzeAndFixRequest {
    issue: any;
    context: any;
    dryRun: boolean;
    verbose: boolean;
}
export interface FixResult {
    success: boolean;
    summary: string;
    changesApplied: boolean;
    buildSuccess?: boolean;
    testSuccess?: boolean;
    errors: string[];
}
export declare class ClaudeCodeService {
    private config;
    private logger;
    constructor(config: ProjectConfig, logger: Logger);
    analyzeAndFix(request: AnalyzeAndFixRequest): Promise<FixResult>;
    private formatIssueForClaude;
    private createAnalysisPrompt;
    private executeClaude;
    runBuildTest(): Promise<boolean>;
    runTests(): Promise<boolean>;
    runLint(): Promise<boolean>;
}
//# sourceMappingURL=ClaudeCodeService.d.ts.map