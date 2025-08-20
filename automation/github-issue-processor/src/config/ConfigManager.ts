import { readFile } from 'fs/promises';
import { resolve } from 'path';
import YAML from 'yaml';
import { config } from 'dotenv';
import chalk from 'chalk';

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
    slack?: { enabled: boolean; webhook?: string };
    email?: { enabled: boolean; recipient?: string };
    console: { enabled: boolean; verbose: boolean };
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

export class ConfigManager {
  private static instance: ConfigManager;
  private config: ProjectConfig | null = null;

  static async load(): Promise<ProjectConfig> {
    if (!ConfigManager.instance) {
      ConfigManager.instance = new ConfigManager();
    }
    
    if (!ConfigManager.instance.config) {
      await ConfigManager.instance.loadConfig();
    }
    
    return ConfigManager.instance.config!;
  }

  private async loadConfig(): Promise<void> {
    // 環境変数を読み込み
    config();
    
    // 設定ファイルのパス
    const configPath = resolve(process.cwd(), 'config/project-config.yml');
    
    try {
      const configFile = await readFile(configPath, 'utf-8');
      const rawConfig = YAML.parse(configFile) as ProjectConfig;
      
      // 環境変数で設定を上書き
      this.config = this.mergeWithEnvironment(rawConfig);
      
      console.log(chalk.blue('📋 設定ファイル読み込み完了:'), chalk.gray(configPath));
    } catch (error) {
      throw new Error(`設定ファイルの読み込みに失敗しました: ${configPath}\n${error}`);
    }
  }

  private mergeWithEnvironment(config: ProjectConfig): ProjectConfig {
    const env = process.env;
    
    // 環境変数で設定を上書き
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
    
    // GitHub Token の検証
    if (!env.GITHUB_TOKEN) {
      throw new Error('GITHUB_TOKEN環境変数が設定されていません');
    }
    
    return config;
  }

  static getGitHubToken(): string {
    const token = process.env.GITHUB_TOKEN;
    if (!token) {
      throw new Error('GITHUB_TOKEN環境変数が設定されていません');
    }
    return token;
  }

  static getAnthropicApiKey(): string | undefined {
    return process.env.ANTHROPIC_API_KEY;
  }
}