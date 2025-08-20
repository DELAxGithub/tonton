import { readFile, stat } from 'fs/promises';
import { resolve, relative } from 'path';
import { glob } from 'glob';
import chalk from 'chalk';
export class ContextCollector {
    config;
    logger;
    constructor(config, logger) {
        this.config = config;
        this.logger = logger;
    }
    async collectContext(issue) {
        this.logger.info(chalk.blue('📊 プロジェクトコンテキストを収集中...'));
        const files = await this.collectRelevantFiles(issue);
        const projectInfo = this.getProjectInfo();
        const issueContext = this.extractIssueContext(issue);
        return {
            files,
            projectInfo,
            issueContext
        };
    }
    async collectRelevantFiles(issue) {
        const files = [];
        const rootPath = this.config.paths.root;
        try {
            for (const pattern of this.config.context.files) {
                const matchedFiles = await glob(pattern, {
                    cwd: rootPath,
                    ignore: this.config.context.excludePatterns || []
                });
                for (const filePath of matchedFiles.slice(0, this.config.context.maxFiles)) {
                    try {
                        const absolutePath = resolve(rootPath, filePath);
                        const stats = await stat(absolutePath);
                        if (stats.size > 1024 * 1024) {
                            continue;
                        }
                        const content = await readFile(absolutePath, 'utf-8');
                        const fileType = this.determineFileType(filePath);
                        files.push({
                            path: absolutePath,
                            relativePath: relative(rootPath, absolutePath),
                            content,
                            size: stats.size,
                            type: fileType
                        });
                    }
                    catch (error) {
                        this.logger.warn(chalk.yellow(`⚠️ ファイル読み込みエラー: ${filePath}`), error);
                    }
                }
            }
            const relevantFiles = await this.findIssueRelevantFiles(issue, rootPath);
            for (const filePath of relevantFiles) {
                if (!files.some(f => f.relativePath === filePath)) {
                    try {
                        const absolutePath = resolve(rootPath, filePath);
                        const content = await readFile(absolutePath, 'utf-8');
                        const stats = await stat(absolutePath);
                        files.push({
                            path: absolutePath,
                            relativePath: filePath,
                            content,
                            size: stats.size,
                            type: this.determineFileType(filePath)
                        });
                    }
                    catch (error) {
                    }
                }
            }
        }
        catch (error) {
            this.logger.error(chalk.red('❌ ファイル収集エラー:'), error);
        }
        this.logger.info(chalk.green(`✅ ${files.length} ファイルを収集しました`));
        return files;
    }
    determineFileType(filePath) {
        const ext = filePath.toLowerCase();
        if (ext.endsWith('.swift'))
            return 'swift';
        if (ext.endsWith('.plist'))
            return 'plist';
        if (ext.endsWith('.entitlements'))
            return 'entitlements';
        if (ext.includes('.xcodeproj'))
            return 'xcodeproj';
        if (ext.endsWith('.md'))
            return 'markdown';
        return 'other';
    }
    async findIssueRelevantFiles(issue, rootPath) {
        const relevantFiles = [];
        const issueText = (issue.title + ' ' + (issue.body || '')).toLowerCase();
        const keywords = this.extractKeywords(issueText);
        try {
            const swiftFiles = await glob('**/*.swift', { cwd: rootPath });
            for (const file of swiftFiles) {
                const fileName = file.toLowerCase();
                if (keywords.some(keyword => fileName.includes(keyword))) {
                    relevantFiles.push(file);
                }
            }
            const healthAppFiles = [
                'HealthKitService.swift',
                'AIServiceManager.swift',
                'MealLoggingView.swift',
                'CalorieSavingsRecord.swift',
                'UserProfile.swift',
                'Info.plist'
            ];
            for (const file of healthAppFiles) {
                try {
                    const foundFiles = await glob(`**/${file}`, { cwd: rootPath });
                    relevantFiles.push(...foundFiles);
                }
                catch {
                }
            }
        }
        catch (error) {
            this.logger.warn(chalk.yellow('⚠️ 関連ファイル検索エラー:'), error);
        }
        return [...new Set(relevantFiles)];
    }
    extractKeywords(text) {
        const keywords = [];
        const healthKeywords = [
            'health', 'healthkit', 'meal', 'calorie', 'weight', 'ai', 'gemini',
            'swiftdata', 'cloudkit', 'savings', 'nutrition', 'camera', 'image'
        ];
        const iosKeywords = [
            'swift', 'swiftui', 'xcode', 'ios', 'build', 'simulator', 'app',
            'permission', 'privacy', 'accessibility', 'ui', 'view'
        ];
        const errorKeywords = [
            'error', 'bug', 'crash', 'fail', 'issue', 'problem', 'fix'
        ];
        const allKeywords = [...healthKeywords, ...iosKeywords, ...errorKeywords];
        for (const keyword of allKeywords) {
            if (text.includes(keyword.toLowerCase())) {
                keywords.push(keyword);
            }
        }
        return keywords;
    }
    getProjectInfo() {
        return {
            name: this.config.project.name,
            type: this.config.project.type,
            rootPath: this.config.paths.root,
            healthFeatures: this.config.healthAppFeatures,
            buildConfig: this.config.build
        };
    }
    extractIssueContext(issue) {
        return {
            number: issue.number,
            title: issue.title,
            body: issue.body || '',
            labels: issue.labels.map((label) => typeof label === 'string' ? label : label.name || ''),
            relevantFiles: []
        };
    }
}
//# sourceMappingURL=ContextCollector.js.map