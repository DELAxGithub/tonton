export interface ProjectConfig {
    project: {
        name: string;
        type: string;
        description?: string;
    };
    issueRepository: {
        owner: string;
        name: string;
    };
    targetRepository: {
        owner: string;
        name: string;
        defaultBranch: string;
    };
    paths: {
        root: string;
        source: string[];
    };
    build: {
        command: string;
        testCommand?: string;
        lintCommand?: string;
    };
    issueProcessing: {
        labels: string[];
        maxConcurrentIssues: number;
        confidenceThreshold: number;
    };
    context: {
        files: string[];
        maxFiles: number;
        excludePatterns?: string[];
    };
    healthAppFeatures?: {
        healthKit: boolean;
        aiMealLogging: boolean;
        cloudKitSync: boolean;
        calorieSavings: boolean;
        swiftData: boolean;
    };
    autoFixPatterns?: {
        swiftCompilerErrors: boolean;
        healthKitPermissions: boolean;
        cloudKitIntegration: boolean;
        swiftDataModels: boolean;
        uiAccessibility: boolean;
    };
    claudeCode: {
        useCliTool: boolean;
        maxContextSize: number;
        thinkingMode: string;
        validationSteps: boolean;
    };
    github: {
        createPullRequests: boolean;
        autoMerge: boolean;
        branchNaming: string;
        commitMessageTemplate: string;
    };
    qualityChecks: {
        buildSuccess: boolean;
        testExecution: boolean;
        linting: boolean;
        healthKitValidation?: boolean;
        accessibilityCheck?: boolean;
    };
    notifications: {
        slack?: {
            enabled: boolean;
            webhook?: string;
        };
        email?: {
            enabled: boolean;
            recipient?: string;
        };
        console: {
            enabled: boolean;
            verbose: boolean;
        };
    };
    logging: {
        level: string;
        file: string;
        maxFileSize: string;
        maxFiles: number;
        console: boolean;
    };
    errorHandling: {
        retryAttempts: number;
        retryDelay: number;
        timeoutMs: number;
        gracefulShutdown: boolean;
    };
    performance: {
        maxMemoryUsage: string;
        concurrentOperations: number;
        cacheEnabled: boolean;
        cacheTTL: number;
    };
}
export declare class ConfigManager {
    private static instance;
    private config;
    static load(): Promise<ProjectConfig>;
    private loadConfig;
    private mergeWithEnvironment;
    static getGitHubToken(): string;
    static getAnthropicApiKey(): string | undefined;
}
//# sourceMappingURL=ConfigManager.d.ts.map