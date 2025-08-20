import { ProjectConfig } from '../config/ConfigManager.js';
import { Logger } from '../utils/Logger.js';
export interface ProjectContext {
    files: ContextFile[];
    projectInfo: ProjectInfo;
    issueContext: IssueContext;
}
export interface ContextFile {
    path: string;
    relativePath: string;
    content: string;
    size: number;
    type: 'swift' | 'plist' | 'entitlements' | 'xcodeproj' | 'markdown' | 'other';
}
export interface ProjectInfo {
    name: string;
    type: string;
    rootPath: string;
    healthFeatures: any;
    buildConfig: any;
}
export interface IssueContext {
    number: number;
    title: string;
    body: string;
    labels: string[];
    relevantFiles: string[];
}
export declare class ContextCollector {
    private config;
    private logger;
    constructor(config: ProjectConfig, logger: Logger);
    collectContext(issue: any): Promise<ProjectContext>;
    private collectRelevantFiles;
    private determineFileType;
    private findIssueRelevantFiles;
    private extractKeywords;
    private getProjectInfo;
    private extractIssueContext;
}
//# sourceMappingURL=ContextCollector.d.ts.map