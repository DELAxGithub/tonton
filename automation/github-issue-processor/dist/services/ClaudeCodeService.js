import { spawn, exec } from 'child_process';
import { promisify } from 'util';
import { writeFile } from 'fs/promises';
import { resolve } from 'path';
import chalk from 'chalk';
const execAsync = promisify(exec);
export class ClaudeCodeService {
    config;
    logger;
    constructor(config, logger) {
        this.config = config;
        this.logger = logger;
    }
    async analyzeAndFix(request) {
        const result = {
            success: false,
            summary: '',
            changesApplied: false,
            errors: []
        };
        try {
            const issueFile = resolve(this.config.paths.root, '.temp-issue-context.md');
            const issueContent = this.formatIssueForClaude(request.issue, request.context);
            await writeFile(issueFile, issueContent, 'utf-8');
            const prompt = this.createAnalysisPrompt(request.issue, request.dryRun);
            const claudeResult = await this.executeClaude(prompt, {
                verbose: request.verbose,
                dryRun: request.dryRun
            });
            result.success = claudeResult.success;
            result.summary = claudeResult.output;
            result.changesApplied = claudeResult.changesApplied;
            if (!claudeResult.success) {
                result.errors.push(claudeResult.error || 'Claude Code実行エラー');
            }
        }
        catch (error) {
            result.errors.push(`Claude Code Service Error: ${error}`);
            this.logger.error(chalk.red('Claude Code Service エラー:'), error);
        }
        return result;
    }
    formatIssueForClaude(issue, context) {
        return `# GitHub Issue #${issue.number}: ${issue.title}

## Issue詳細
**作成者**: ${issue.user.login}
**作成日**: ${issue.created_at}
**ラベル**: ${issue.labels.map((label) => label.name).join(', ')}

## Issue本文
${issue.body || 'No description provided.'}

## プロジェクトコンテキスト
**プロジェクト**: ${this.config.project.name}
**タイプ**: ${this.config.project.type}

### 関連ファイル
${context.files?.map((file) => `- ${file.path}`).join('\\n') || 'None'}

### TonTon Health App Features
- HealthKit Integration: ${this.config.healthAppFeatures?.healthKit ? '✅' : '❌'}
- AI Meal Logging: ${this.config.healthAppFeatures?.aiMealLogging ? '✅' : '❌'}
- CloudKit Sync: ${this.config.healthAppFeatures?.cloudKitSync ? '✅' : '❌'}
- Calorie Savings: ${this.config.healthAppFeatures?.calorieSavings ? '✅' : '❌'}
- SwiftData: ${this.config.healthAppFeatures?.swiftData ? '✅' : '❌'}

---
**注意**: この内容は自動生成されました。TonTon (トントン) iOS Health Appの改善のため、Claude Codeで分析・修正を行ってください。
`;
    }
    createAnalysisPrompt(issue, dryRun) {
        const dryRunFlag = dryRun ? '--dry-run' : '';
        const mode = dryRun ? 'analyze and preview fixes' : 'analyze and apply fixes';
        return `I need you to ${mode} for TonTon iOS health tracking app based on this GitHub Issue:

**Issue #${issue.number}**: ${issue.title}

Please:
1. Read the issue details from .temp-issue-context.md
2. Analyze the TonTon iOS project structure (SwiftUI + HealthKit + AI)
3. Identify the root cause and potential solutions
4. ${dryRun ? 'Preview the changes that would be made' : 'Apply appropriate fixes'}
5. Ensure health app specific functionality remains intact:
   - HealthKit permissions and integration
   - AI meal logging workflow
   - Calorie calculations accuracy
   - SwiftData model integrity
   - iOS accessibility compliance

Focus on:
- Swift compiler errors and warnings
- HealthKit integration issues
- SwiftData model problems
- UI/UX accessibility
- Build configuration issues

Use TonTon-specific patterns and maintain code quality standards for a health tracking app.

${dryRunFlag}`;
    }
    async executeClaude(prompt, options) {
        return new Promise((resolve) => {
            const args = [];
            if (options.verbose) {
                args.push('--verbose');
            }
            this.logger.info(chalk.blue(`🤖 Claude Code実行中... (${this.config.paths.root})`));
            const claude = spawn('claude', args, {
                cwd: this.config.paths.root,
                stdio: ['pipe', 'pipe', 'pipe'],
                env: {
                    ...process.env
                }
            });
            let output = '';
            let errorOutput = '';
            claude.stdout.on('data', (data) => {
                const text = data.toString();
                output += text;
                if (options.verbose) {
                    process.stdout.write(chalk.gray(text));
                }
            });
            claude.stderr.on('data', (data) => {
                const text = data.toString();
                errorOutput += text;
                if (options.verbose) {
                    process.stderr.write(chalk.red(text));
                }
            });
            claude.on('close', (code) => {
                const success = code === 0;
                const changesApplied = !options.dryRun && success && output.includes('changes applied');
                const result = {
                    success,
                    output: output || errorOutput,
                    changesApplied
                };
                if (!success && errorOutput) {
                    result.error = errorOutput;
                }
                resolve(result);
            });
            claude.on('error', (error) => {
                resolve({
                    success: false,
                    output: '',
                    changesApplied: false,
                    error: error.message || 'Unknown error'
                });
            });
            claude.stdin.write(prompt + '\\n');
            claude.stdin.end();
        });
    }
    async runBuildTest() {
        try {
            this.logger.info(chalk.blue('🔨 ビルドテストを実行中...'));
            const { stderr } = await execAsync(this.config.build.command, {
                cwd: this.config.paths.root,
                timeout: this.config.errorHandling.timeoutMs
            });
            const success = stderr === '' || !stderr.includes('error');
            if (success) {
                this.logger.info(chalk.green('✅ ビルド成功'));
            }
            else {
                this.logger.error(chalk.red('❌ ビルド失敗:'), stderr);
            }
            return success;
        }
        catch (error) {
            this.logger.error(chalk.red('❌ ビルドテストエラー:'), error);
            return false;
        }
    }
    async runTests() {
        if (!this.config.build.testCommand) {
            this.logger.info(chalk.gray('⚠️ テストコマンドが設定されていません'));
            return true;
        }
        try {
            this.logger.info(chalk.blue('🧪 テストを実行中...'));
            const { stdout, stderr } = await execAsync(this.config.build.testCommand, {
                cwd: this.config.paths.root,
                timeout: this.config.errorHandling.timeoutMs
            });
            const success = stderr === '' || !stderr.includes('error') || stdout.includes('Test Succeeded');
            if (success) {
                this.logger.info(chalk.green('✅ テスト成功'));
            }
            else {
                this.logger.error(chalk.red('❌ テスト失敗:'), stderr);
            }
            return success;
        }
        catch (error) {
            this.logger.error(chalk.red('❌ テスト実行エラー:'), error);
            return false;
        }
    }
    async runLint() {
        if (!this.config.build.lintCommand) {
            this.logger.info(chalk.gray('⚠️ Lintコマンドが設定されていません'));
            return true;
        }
        try {
            this.logger.info(chalk.blue('📋 Lintを実行中...'));
            const { stderr } = await execAsync(this.config.build.lintCommand, {
                cwd: this.config.paths.root,
                timeout: 60000
            });
            const success = stderr === '' || !stderr.includes('error');
            if (success) {
                this.logger.info(chalk.green('✅ Lint成功'));
            }
            else {
                this.logger.error(chalk.red('❌ Lint失敗:'), stderr);
            }
            return success;
        }
        catch (error) {
            this.logger.error(chalk.red('❌ Lint実行エラー:'), error);
            return false;
        }
    }
}
//# sourceMappingURL=ClaudeCodeService.js.map