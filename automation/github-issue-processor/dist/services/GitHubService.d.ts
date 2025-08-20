import { Octokit } from '@octokit/rest';
import { ProjectConfig } from '../config/ConfigManager.js';
import { Logger } from '../utils/Logger.js';
export interface CreatePullRequestRequest {
    issue: any;
    fixResult: any;
    branchName: string;
}
export interface CommentRequest {
    issueNumber: number;
    message: string;
}
export declare class GitHubService {
    private octokit;
    private config;
    private logger;
    constructor(octokit: Octokit, config: ProjectConfig, logger: Logger);
    createPullRequest(request: CreatePullRequestRequest): Promise<any>;
    commentOnIssue(request: CommentRequest): Promise<void>;
    addLabelsToIssue(issueNumber: number, labels: string[]): Promise<void>;
    closeIssue(issueNumber: number, reason: string): Promise<void>;
    private generatePullRequestBody;
}
//# sourceMappingURL=GitHubService.d.ts.map