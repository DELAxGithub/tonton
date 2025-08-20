import { readFile, stat } from 'fs/promises';
import { resolve, relative } from 'path';
import { glob } from 'glob';
import chalk from 'chalk';
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

export class ContextCollector {
  constructor(
    private config: ProjectConfig,
    private logger: Logger
  ) {}

  async collectContext(issue: any): Promise<ProjectContext> {
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

  private async collectRelevantFiles(issue: any): Promise<ContextFile[]> {
    const files: ContextFile[] = [];
    const rootPath = this.config.paths.root;

    try {
      // 設定されたファイルパターンに基づいてファイルを検索
      for (const pattern of this.config.context.files) {
        const matchedFiles = await glob(pattern, {
          cwd: rootPath,
          ignore: this.config.context.excludePatterns || []
        });

        for (const filePath of matchedFiles.slice(0, this.config.context.maxFiles)) {
          try {
            const absolutePath = resolve(rootPath, filePath);
            const stats = await stat(absolutePath);

            // ファイルサイズをチェック (1MB以下のみ)
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
          } catch (error) {
            this.logger.warn(chalk.yellow(`⚠️ ファイル読み込みエラー: ${filePath}`), error);
          }
        }
      }

      // Issueに関連するファイルを優先的に含める
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
          } catch (error) {
            // ファイルが存在しない場合は無視
          }
        }
      }
    } catch (error) {
      this.logger.error(chalk.red('❌ ファイル収集エラー:'), error);
    }

    this.logger.info(chalk.green(`✅ ${files.length} ファイルを収集しました`));
    return files;
  }

  private determineFileType(filePath: string): ContextFile['type'] {
    const ext = filePath.toLowerCase();
    
    if (ext.endsWith('.swift')) return 'swift';
    if (ext.endsWith('.plist')) return 'plist';
    if (ext.endsWith('.entitlements')) return 'entitlements';
    if (ext.includes('.xcodeproj')) return 'xcodeproj';
    if (ext.endsWith('.md')) return 'markdown';
    
    return 'other';
  }

  private async findIssueRelevantFiles(issue: any, rootPath: string): Promise<string[]> {
    const relevantFiles: string[] = [];
    const issueText = (issue.title + ' ' + (issue.body || '')).toLowerCase();

    // キーワードベースでファイルを検索
    const keywords = this.extractKeywords(issueText);
    
    try {
      // Swift ファイルを検索
      const swiftFiles = await glob('**/*.swift', { cwd: rootPath });
      
      for (const file of swiftFiles) {
        const fileName = file.toLowerCase();
        
        // ファイル名がキーワードに関連している場合
        if (keywords.some(keyword => fileName.includes(keyword))) {
          relevantFiles.push(file);
        }
      }

      // TonTon健康アプリ固有のファイルを追加
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
        } catch {
          // ファイルが見つからない場合は無視
        }
      }
    } catch (error) {
      this.logger.warn(chalk.yellow('⚠️ 関連ファイル検索エラー:'), error);
    }

    return [...new Set(relevantFiles)]; // 重複を除去
  }

  private extractKeywords(text: string): string[] {
    const keywords: string[] = [];
    
    // TonTon Health App関連キーワード
    const healthKeywords = [
      'health', 'healthkit', 'meal', 'calorie', 'weight', 'ai', 'gemini',
      'swiftdata', 'cloudkit', 'savings', 'nutrition', 'camera', 'image'
    ];

    // iOS/Swift関連キーワード  
    const iosKeywords = [
      'swift', 'swiftui', 'xcode', 'ios', 'build', 'simulator', 'app',
      'permission', 'privacy', 'accessibility', 'ui', 'view'
    ];

    // エラー関連キーワード
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

  private getProjectInfo(): ProjectInfo {
    return {
      name: this.config.project.name,
      type: this.config.project.type,
      rootPath: this.config.paths.root,
      healthFeatures: this.config.healthAppFeatures,
      buildConfig: this.config.build
    };
  }

  private extractIssueContext(issue: any): IssueContext {
    return {
      number: issue.number,
      title: issue.title,
      body: issue.body || '',
      labels: issue.labels.map((label: any) => 
        typeof label === 'string' ? label : label.name || ''
      ),
      relevantFiles: [] // これは後で設定される
    };
  }
}