import { Octokit } from '@octokit/rest';
import chalk from 'chalk';
import { ConfigManager } from '../config/ConfigManager.js';
import { ClaudeCodeService } from '../services/ClaudeCodeService.js';
import { GitHubService } from '../services/GitHubService.js';
import { ContextCollector } from '../services/ContextCollector.js';
export class IssueProcessor {
    config;
    logger;
    octokit;
    claudeService;
    githubService;
    contextCollector;
    constructor(config, logger) {
        this.config = config;
        this.logger = logger;
        this.octokit = new Octokit({
            auth: ConfigManager.getGitHubToken(),
        });
        this.claudeService = new ClaudeCodeService(config, logger);
        this.githubService = new GitHubService(this.octokit, config, logger);
        this.contextCollector = new ContextCollector(config, logger);
    }
    async startContinuousProcessing(options = { dryRun: false, verbose: false }) {
        this.logger.info(chalk.green('🔄 継続監視モードを開始しています...'));
        let isRunning = true;
        process.on('SIGINT', () => {
            this.logger.info(chalk.yellow('📋 終了シグナルを受信しました。処理を停止します...'));
            isRunning = false;
        });
        while (isRunning) {
            try {
                await this.processSingleRun(options);
                if (isRunning) {
                    this.logger.info(chalk.blue('⏳ 30秒待機してから次のチェックを実行します...'));
                    await new Promise(resolve => setTimeout(resolve, 30000));
                }
            }
            catch (error) {
                this.logger.error(chalk.red('❌ 処理中にエラーが発生しました:'), error);
                if (isRunning) {
                    this.logger.info(chalk.blue('⏳ エラー後の待機時間: 60秒'));
                    await new Promise(resolve => setTimeout(resolve, 60000));
                }
            }
        }
        this.logger.info(chalk.green('✅ 継続監視モードを終了しました'));
    }
    async processSingleRun(options = { dryRun: false, verbose: false }) {
        const result = {
            processed: 0,
            successful: 0,
            failed: 0,
            errors: []
        };
        try {
            this.logger.info(chalk.blue('🔍 新しいIssueをチェックしています...'));
            const issues = await this.getProcessableIssues(options.issueNumber);
            if (issues.length === 0) {
                this.logger.info(chalk.gray('📭 処理対象のIssueはありません'));
                return result;
            }
            this.logger.info(chalk.green(`📥 ${issues.length} 件のIssueが見つかりました`));
            for (const issue of issues) {
                try {
                    this.logger.info(chalk.blue(`\n🔧 Issue #${issue.number} を処理中: ${issue.title}`));
                    await this.processIssue(issue, options);
                    result.processed++;
                    result.successful++;
                    this.logger.info(chalk.green(`✅ Issue #${issue.number} の処理が完了しました`));
                }
                catch (error) {
                    result.processed++;
                    result.failed++;
                    result.errors.push(`Issue #${issue.number}: ${error}`);
                    this.logger.error(chalk.red(`❌ Issue #${issue.number} の処理に失敗しました:`), error);
                }
            }
        }
        catch (error) {
            result.errors.push(`General error: ${error}`);
            this.logger.error(chalk.red('❌ 全般的なエラーが発生しました:'), error);
        }
        return result;
    }
    async getProcessableIssues(specificIssueNumber) {
        if (specificIssueNumber) {
            const { data: issue } = await this.octokit.issues.get({
                owner: this.config.issueRepository.owner,
                repo: this.config.issueRepository.name,
                issue_number: specificIssueNumber,
            });
            return [issue];
        }
        const { data: issues } = await this.octokit.issues.listForRepo({
            owner: this.config.issueRepository.owner,
            repo: this.config.issueRepository.name,
            state: 'open',
            sort: 'created',
            direction: 'desc',
            per_page: 10,
        });
        return issues.filter(issue => {
            const issueLabels = issue.labels.map(label => typeof label === 'string' ? label : label.name || '');
            return this.config.issueProcessing.labels.some(targetLabel => issueLabels.includes(targetLabel));
        });
    }
    async processIssue(issue, options) {
        this.logger.info(chalk.blue('📊 プロジェクトコンテキストを収集中...'));
        const context = await this.contextCollector.collectContext(issue);
        this.logger.info(chalk.blue('🤖 Claude Codeで分析・修正を実行中...'));
        const fixResult = await this.claudeService.analyzeAndFix({
            issue,
            context,
            dryRun: options.dryRun,
            verbose: options.verbose
        });
        if (options.dryRun) {
            this.logger.info(chalk.yellow('🔍 ドライランモード - 以下の変更が適用される予定です:'));
            this.logger.info(chalk.gray(JSON.stringify(fixResult, null, 2)));
            return;
        }
        if (this.config.qualityChecks.buildSuccess) {
            this.logger.info(chalk.blue('🔨 ビルドテストを実行中...'));
            await this.claudeService.runBuildTest();
        }
        if (this.config.qualityChecks.testExecution && this.config.build.testCommand) {
            this.logger.info(chalk.blue('🧪 テストを実行中...'));
            await this.claudeService.runTests();
        }
        if (this.config.github.createPullRequests && fixResult.changesApplied) {
            this.logger.info(chalk.blue('📤 Pull Requestを作成中...'));
            const pr = await this.githubService.createPullRequest({
                issue,
                fixResult,
                branchName: this.config.github.branchNaming.replace('{number}', issue.number.toString())
            });
            await this.githubService.commentOnIssue({
                issueNumber: issue.number,
                message: this.generateStatusComment(fixResult, pr?.html_url)
            });
        }
    }
    generateStatusComment(fixResult, prUrl) {
        let comment = `## 🏥 TonTon Auto-Fix Results\\n\\n`;
        comment += `**Status**: ✅ 自動修正完了\\n`;
        comment += `**Changes**: ${fixResult.summary || '修正を適用しました'}\\n\\n`;
        if (prUrl) {
            comment += `**Pull Request**: ${prUrl}\\n\\n`;
        }
        comment += `### 🚀 TonTon Health App - Next Steps:\\n`;
        comment += `1. ビルドが成功することを確認\\n`;
        comment += `2. HealthKit統合の動作テスト\\n`;
        comment += `3. AI食事記録機能の検証\\n`;
        comment += `4. アクセシビリティの確認\\n\\n`;
        comment += `*🤖 Auto-generated by Claude Code for TonTon (トントン)*`;
        return comment;
    }
}
//# sourceMappingURL=IssueProcessor.js.map