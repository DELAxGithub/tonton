#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import { IssueProcessor, ProcessingOptions } from './processors/IssueProcessor.js';
import { ConfigManager } from './config/ConfigManager.js';
import { Logger } from './utils/Logger.js';
import { validateSetup } from './utils/setup-validator.js';

const program = new Command();

program
  .name('github-issue-processor')
  .description('🏥 TonTon iOS App - GitHub Issue自動処理システム')
  .version('1.0.0');

program
  .command('process')
  .description('継続的にIssueを監視・処理')
  .option('--dry-run', '実際の変更は適用せず、プレビューのみ')
  .option('--verbose', '詳細ログ出力')
  .action(async (options) => {
    try {
      const config = await ConfigManager.load();
      const logger = new Logger(config.logging);
      const processor = new IssueProcessor(config, logger);

      logger.info(chalk.green('🏥 TonTon Issue Processor - 継続監視モード開始'));
      
      if (options.dryRun) {
        logger.info(chalk.yellow('🔍 ドライランモード - 変更は適用されません'));
      }

      await processor.startContinuousProcessing({
        dryRun: options.dryRun,
        verbose: options.verbose
      });
    } catch (error) {
      console.error(chalk.red('❌ エラー:'), error);
      process.exit(1);
    }
  });

program
  .command('process-once')
  .description('一度だけIssueを処理')
  .option('--dry-run', '実際の変更は適用せず、プレビューのみ')
  .option('--verbose', '詳細ログ出力')
  .option('--issue <number>', '特定のIssue番号を処理')
  .action(async (options) => {
    try {
      const config = await ConfigManager.load();
      const logger = new Logger(config.logging);
      const processor = new IssueProcessor(config, logger);

      logger.info(chalk.green('🏥 TonTon Issue Processor - 単発処理モード'));
      
      if (options.dryRun) {
        logger.info(chalk.yellow('🔍 ドライランモード - 変更は適用されません'));
      }

      const processingOptions: ProcessingOptions = {
        dryRun: options.dryRun || false,
        verbose: options.verbose || false
      };
      
      if (options.issue) {
        processingOptions.issueNumber = parseInt(options.issue);
      }
      
      const result = await processor.processSingleRun(processingOptions);

      logger.info(chalk.green(`✅ 処理完了: ${result.processed} issues processed`));
    } catch (error) {
      console.error(chalk.red('❌ エラー:'), error);
      process.exit(1);
    }
  });

program
  .command('init')
  .description('設定ファイルのテンプレートを生成')
  .action(async () => {
    try {
      const { initializeConfig } = await import('./utils/init.js');
      await initializeConfig();
      console.log(chalk.green('✅ 設定テンプレートが生成されました'));
    } catch (error) {
      console.error(chalk.red('❌ エラー:'), error);
      process.exit(1);
    }
  });

program
  .command('validate')
  .description('セットアップを検証')
  .action(async () => {
    try {
      console.log(chalk.blue('🔍 TonTon Issue Processor セットアップを検証中...'));
      const isValid = await validateSetup();
      
      if (isValid) {
        console.log(chalk.green('✅ セットアップは正常です'));
      } else {
        console.log(chalk.red('❌ セットアップに問題があります'));
        process.exit(1);
      }
    } catch (error) {
      console.error(chalk.red('❌ エラー:'), error);
      process.exit(1);
    }
  });

program
  .command('status')
  .description('処理統計を表示')
  .action(async () => {
    try {
      const { showStatus } = await import('./utils/status.js');
      await showStatus();
    } catch (error) {
      console.error(chalk.red('❌ エラー:'), error);
      process.exit(1);
    }
  });

program
  .command('clean')
  .description('古いファイル・ブランチをクリーンアップ')
  .action(async () => {
    try {
      const { cleanupOldData } = await import('./utils/cleanup.js');
      await cleanupOldData();
      console.log(chalk.green('✅ クリーンアップ完了'));
    } catch (error) {
      console.error(chalk.red('❌ エラー:'), error);
      process.exit(1);
    }
  });

// エラーハンドリング
process.on('unhandledRejection', (reason, promise) => {
  console.error(chalk.red('❌ Unhandled Rejection at:'), promise, chalk.red('reason:'), reason);
  process.exit(1);
});

process.on('uncaughtException', (error) => {
  console.error(chalk.red('❌ Uncaught Exception:'), error);
  process.exit(1);
});

program.parse();