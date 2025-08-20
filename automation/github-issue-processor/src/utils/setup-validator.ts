import { access } from 'fs/promises';
import { resolve } from 'path';
import { spawn } from 'child_process';
import chalk from 'chalk';
import { ConfigManager } from '../config/ConfigManager.js';

const execCommand = (command: string, args: string[] = []): Promise<{ code: number; stdout: string; stderr: string }> => {
  return new Promise((resolve) => {
    const child = spawn(command, args, { stdio: 'pipe' });
    
    let stdout = '';
    let stderr = '';
    
    child.stdout.on('data', (data) => {
      stdout += data.toString();
    });
    
    child.stderr.on('data', (data) => {
      stderr += data.toString();
    });
    
    child.on('close', (code) => {
      resolve({ code: code || 0, stdout, stderr });
    });
    
    child.on('error', (error) => {
      resolve({ code: 1, stdout: '', stderr: error.message });
    });
  });
};

export async function validateSetup(): Promise<boolean> {
  let isValid = true;

  console.log(chalk.blue('🔍 TonTon Issue Processor セットアップ検証中...\\n'));

  // 1. 必要なツールの確認
  console.log(chalk.blue('📋 必要ツールの確認:'));
  
  const tools = [
    { name: 'Node.js', command: 'node', args: ['--version'], required: true },
    { name: 'pnpm', command: 'pnpm', args: ['--version'], required: true },
    { name: 'Git', command: 'git', args: ['--version'], required: true },
    { name: 'Claude Code CLI', command: 'claude', args: ['--version'], required: true },
    { name: 'Xcode', command: 'xcodebuild', args: ['-version'], required: true },
    { name: 'SwiftLint', command: 'swiftlint', args: ['version'], required: false }
  ];

  for (const tool of tools) {
    try {
      const result = await execCommand(tool.command, tool.args);
      
      if (result.code === 0) {
        const version = (result.stdout || result.stderr).trim().split('\\n')[0];
        console.log(chalk.green(`✅ ${tool.name}: ${version}`));
      } else {
        if (tool.required) {
          console.log(chalk.red(`❌ ${tool.name}: インストールされていません`));
          isValid = false;
        } else {
          console.log(chalk.yellow(`⚠️ ${tool.name}: インストールされていません (オプション)`));
        }
      }
    } catch (error) {
      if (tool.required) {
        console.log(chalk.red(`❌ ${tool.name}: 確認エラー - ${error}`));
        isValid = false;
      } else {
        console.log(chalk.yellow(`⚠️ ${tool.name}: 確認エラー (オプション)`));
      }
    }
  }

  console.log('');

  // 2. 設定ファイルの確認
  console.log(chalk.blue('📄 設定ファイルの確認:'));
  
  try {
    const config = await ConfigManager.load();
    console.log(chalk.green('✅ project-config.yml: 読み込み成功'));
    
    // プロジェクトルートの確認
    try {
      await access(config.paths.root);
      console.log(chalk.green(`✅ プロジェクトルート: ${config.paths.root}`));
    } catch (error) {
      console.log(chalk.red(`❌ プロジェクトルートが見つかりません: ${config.paths.root}`));
      isValid = false;
    }
    
  } catch (error) {
    console.log(chalk.red(`❌ 設定ファイル読み込みエラー: ${error}`));
    isValid = false;
  }

  // 3. 環境変数の確認
  console.log(chalk.blue('🔑 環境変数の確認:'));
  
  const envVars = [
    { name: 'GITHUB_TOKEN', required: true },
    { name: 'ANTHROPIC_API_KEY', required: false },
    { name: 'PROJECT_ROOT', required: false }
  ];

  for (const envVar of envVars) {
    const value = process.env[envVar.name];
    
    if (value) {
      const maskedValue = envVar.name.includes('TOKEN') || envVar.name.includes('KEY') 
        ? `${value.substring(0, 8)}...` 
        : value;
      console.log(chalk.green(`✅ ${envVar.name}: ${maskedValue}`));
    } else {
      if (envVar.required) {
        console.log(chalk.red(`❌ ${envVar.name}: 設定されていません`));
        isValid = false;
      } else {
        console.log(chalk.gray(`⚪ ${envVar.name}: 設定なし (オプション)`));
      }
    }
  }

  console.log('');

  // 4. GitHub接続の確認
  console.log(chalk.blue('🔗 GitHub接続の確認:'));
  
  if (process.env.GITHUB_TOKEN) {
    try {
      const result = await execCommand('curl', [
        '-H', `Authorization: token ${process.env.GITHUB_TOKEN}`,
        '-s', 'https://api.github.com/user'
      ]);
      
      if (result.code === 0 && !result.stderr.includes('Bad credentials')) {
        console.log(chalk.green('✅ GitHub認証: 成功'));
      } else {
        console.log(chalk.red('❌ GitHub認証: 失敗'));
        isValid = false;
      }
    } catch (error) {
      console.log(chalk.yellow('⚠️ GitHub接続確認をスキップしました'));
    }
  }

  // 5. TonTonプロジェクトの確認
  console.log(chalk.blue('🏥 TonTonプロジェクトの確認:'));
  
  try {
    const config = await ConfigManager.load();
    
    // Xcodeプロジェクトファイルの確認
    const xcodeProjectPath = resolve(config.paths.root, 'Tonton/Tonton.xcodeproj');
    try {
      await access(xcodeProjectPath);
      console.log(chalk.green('✅ Xcodeプロジェクト: 見つかりました'));
    } catch (error) {
      console.log(chalk.red('❌ Xcodeプロジェクト: 見つかりません'));
      isValid = false;
    }

    // CLAUDE.mdの確認
    const claudeMdPath = resolve(config.paths.root, 'CLAUDE.md');
    try {
      await access(claudeMdPath);
      console.log(chalk.green('✅ CLAUDE.md: 見つかりました'));
    } catch (error) {
      console.log(chalk.yellow('⚠️ CLAUDE.md: 見つかりません (推奨)'));
    }

    // 重要なSwiftファイルの確認
    const importantFiles = [
      'Tonton/Tonton/TonTonApp.swift',
      'Tonton/Tonton/Views/HomeView.swift'
    ];

    let foundFiles = 0;
    for (const file of importantFiles) {
      try {
        await access(resolve(config.paths.root, file));
        foundFiles++;
      } catch (error) {
        // ファイルが見つからなくても続行
      }
    }

    if (foundFiles > 0) {
      console.log(chalk.green(`✅ TonTon Swiftファイル: ${foundFiles}/${importantFiles.length} ファイル確認`));
    } else {
      console.log(chalk.yellow('⚠️ TonTon Swiftファイル: 確認できませんでした'));
    }

  } catch (error) {
    console.log(chalk.red('❌ TonTonプロジェクト確認エラー'));
    isValid = false;
  }

  console.log('\\n' + '='.repeat(50));
  
  if (isValid) {
    console.log(chalk.green('✅ セットアップ検証: 全て正常です'));
    console.log(chalk.blue('🚀 次のコマンドでテスト実行が可能です:'));
    console.log(chalk.gray('   pnpm process:once --dry-run'));
  } else {
    console.log(chalk.red('❌ セットアップ検証: 問題があります'));
    console.log(chalk.blue('🔧 上記のエラーを修正してから再実行してください'));
  }

  return isValid;
}