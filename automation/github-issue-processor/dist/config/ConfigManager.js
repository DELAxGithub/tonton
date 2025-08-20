import { readFile } from 'fs/promises';
import { resolve } from 'path';
import YAML from 'yaml';
import { config } from 'dotenv';
import chalk from 'chalk';
export class ConfigManager {
    static instance;
    config = null;
    static async load() {
        if (!ConfigManager.instance) {
            ConfigManager.instance = new ConfigManager();
        }
        if (!ConfigManager.instance.config) {
            await ConfigManager.instance.loadConfig();
        }
        return ConfigManager.instance.config;
    }
    async loadConfig() {
        config();
        const configPath = resolve(process.cwd(), 'config/project-config.yml');
        try {
            const configFile = await readFile(configPath, 'utf-8');
            const rawConfig = YAML.parse(configFile);
            this.config = this.mergeWithEnvironment(rawConfig);
            console.log(chalk.blue('📋 設定ファイル読み込み完了:'), chalk.gray(configPath));
        }
        catch (error) {
            throw new Error(`設定ファイルの読み込みに失敗しました: ${configPath}\n${error}`);
        }
    }
    mergeWithEnvironment(config) {
        const env = process.env;
        if (env.GITHUB_ISSUE_OWNER) {
            config.issueRepository.owner = env.GITHUB_ISSUE_OWNER;
        }
        if (env.GITHUB_ISSUE_REPO) {
            config.issueRepository.name = env.GITHUB_ISSUE_REPO;
        }
        if (env.GITHUB_TARGET_OWNER) {
            config.targetRepository.owner = env.GITHUB_TARGET_OWNER;
        }
        if (env.GITHUB_TARGET_REPO) {
            config.targetRepository.name = env.GITHUB_TARGET_REPO;
        }
        if (env.PROJECT_ROOT) {
            config.paths.root = env.PROJECT_ROOT;
        }
        if (env.LOG_LEVEL) {
            config.logging.level = env.LOG_LEVEL;
        }
        if (env.VERBOSE_LOGGING === 'true') {
            config.notifications.console.verbose = true;
        }
        if (env.MAX_CONCURRENT_ISSUES) {
            config.issueProcessing.maxConcurrentIssues = parseInt(env.MAX_CONCURRENT_ISSUES, 10);
        }
        if (env.CONTEXT_MAX_FILES) {
            config.context.maxFiles = parseInt(env.CONTEXT_MAX_FILES, 10);
        }
        if (env.PROCESSING_TIMEOUT_MS) {
            config.errorHandling.timeoutMs = parseInt(env.PROCESSING_TIMEOUT_MS, 10);
        }
        if (!env.GITHUB_TOKEN) {
            throw new Error('GITHUB_TOKEN環境変数が設定されていません');
        }
        return config;
    }
    static getGitHubToken() {
        const token = process.env.GITHUB_TOKEN;
        if (!token) {
            throw new Error('GITHUB_TOKEN環境変数が設定されていません');
        }
        return token;
    }
    static getAnthropicApiKey() {
        return process.env.ANTHROPIC_API_KEY;
    }
}
//# sourceMappingURL=ConfigManager.js.map