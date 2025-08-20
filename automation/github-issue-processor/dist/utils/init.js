import { writeFile, copyFile, access } from 'fs/promises';
import { resolve } from 'path';
import chalk from 'chalk';
export async function initializeConfig() {
    console.log(chalk.blue('🔧 設定テンプレートを生成中...'));
    const envPath = resolve(process.cwd(), '.env');
    try {
        await access(envPath);
        console.log(chalk.yellow('⚠️ .envファイルは既に存在します。スキップします。'));
    }
    catch {
        try {
            await copyFile(resolve(process.cwd(), '.env.example'), envPath);
            console.log(chalk.green('✅ .envファイルを作成しました'));
            console.log(chalk.blue('📝 .envファイルを編集してGitHub Personal Access Tokenなどを設定してください'));
        }
        catch (error) {
            console.log(chalk.red('❌ .envファイル作成エラー:'), error);
        }
    }
    try {
        const { mkdir } = await import('fs/promises');
        await mkdir(resolve(process.cwd(), 'logs'), { recursive: true });
        console.log(chalk.green('✅ logsディレクトリを作成しました'));
    }
    catch (error) {
        console.log(chalk.yellow('⚠️ logsディレクトリ作成エラー:'), error);
    }
    try {
        const logFile = resolve(process.cwd(), 'logs/issue-processor.log');
        await writeFile(logFile, `# TonTon Issue Processor Log\\nInitialized: ${new Date().toISOString()}\\n`, 'utf-8');
        console.log(chalk.green('✅ 初期ログファイルを作成しました'));
    }
    catch (error) {
        console.log(chalk.yellow('⚠️ ログファイル作成エラー:'), error);
    }
    console.log(chalk.green('\\n✨ 初期化完了！'));
    console.log(chalk.blue('次のステップ:'));
    console.log(chalk.gray('1. .envファイルを編集'));
    console.log(chalk.gray('2. config/project-config.ymlを確認・調整'));
    console.log(chalk.gray('3. pnpm validate でセットアップを検証'));
    console.log(chalk.gray('4. pnpm process:once --dry-run でテスト実行'));
}
//# sourceMappingURL=init.js.map