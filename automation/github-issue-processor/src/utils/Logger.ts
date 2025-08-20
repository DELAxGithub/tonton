import { appendFile, mkdir } from 'fs/promises';
import { dirname, resolve } from 'path';
import chalk from 'chalk';

export interface LoggingConfig {
  level: string;
  file: string;
  maxFileSize: string;
  maxFiles: number;
  console: boolean;
}

export class Logger {
  private logLevels = {
    error: 0,
    warn: 1,
    info: 2,
    debug: 3
  };

  private currentLevel: number;

  constructor(private config: LoggingConfig) {
    this.currentLevel = this.logLevels[config.level as keyof typeof this.logLevels] || this.logLevels.info;
    this.ensureLogDirectory();
  }

  private async ensureLogDirectory(): Promise<void> {
    try {
      const logDir = dirname(resolve(this.config.file));
      await mkdir(logDir, { recursive: true });
    } catch (error) {
      // ディレクトリ作成エラーは無視
    }
  }

  error(message: string, error?: any): void {
    this.log('error', message, error);
  }

  warn(message: string, details?: any): void {
    this.log('warn', message, details);
  }

  info(message: string, details?: any): void {
    this.log('info', message, details);
  }

  debug(message: string, details?: any): void {
    this.log('debug', message, details);
  }

  private log(level: keyof typeof this.logLevels, message: string, details?: any): void {
    const levelNum = this.logLevels[level];
    
    if (levelNum > this.currentLevel) {
      return;
    }

    const timestamp = new Date().toISOString();
    const formattedMessage = `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    
    // コンソール出力
    if (this.config.console) {
      this.outputToConsole(level, formattedMessage, details);
    }

    // ファイル出力
    this.outputToFile(formattedMessage, details);
  }

  private outputToConsole(level: keyof typeof this.logLevels, message: string, details?: any): void {
    let coloredMessage: string;
    
    switch (level) {
      case 'error':
        coloredMessage = chalk.red(message);
        break;
      case 'warn':
        coloredMessage = chalk.yellow(message);
        break;
      case 'info':
        coloredMessage = chalk.blue(message);
        break;
      case 'debug':
        coloredMessage = chalk.gray(message);
        break;
      default:
        coloredMessage = message;
    }

    console.log(coloredMessage);
    
    if (details) {
      console.log(chalk.gray(JSON.stringify(details, null, 2)));
    }
  }

  private async outputToFile(message: string, details?: any): Promise<void> {
    try {
      let logEntry = message;
      
      if (details) {
        logEntry += '\\n' + JSON.stringify(details, null, 2);
      }
      
      logEntry += '\\n';
      
      await appendFile(resolve(this.config.file), logEntry, 'utf-8');
    } catch (error) {
      // ファイル書き込みエラーは無視（無限ループを避けるため）
    }
  }

  async rotateLogs(): Promise<void> {
    // 簡単なログローテーション実装
    // 実際の運用では winston などのライブラリを使用することを推奨
    try {
      // ここでログローテーションロジックを実装
      // 今回は簡略化
      this.parseMaxFileSize(this.config.maxFileSize);
    } catch (error) {
      this.warn('ログローテーションエラー', error);
    }
  }

  private parseMaxFileSize(sizeStr: string): number {
    const match = sizeStr.match(/^(\\d+)(\\w+)$/i);
    if (!match) return 10 * 1024 * 1024; // デフォルト 10MB

    const size = parseInt(match[1], 10);
    const unit = match[2].toLowerCase();

    switch (unit) {
      case 'kb':
        return size * 1024;
      case 'mb':
        return size * 1024 * 1024;
      case 'gb':
        return size * 1024 * 1024 * 1024;
      default:
        return size;
    }
  }
}