import { readdir, unlink, stat } from 'fs/promises';
import { resolve } from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';
import chalk from 'chalk';
const execAsync = promisify(exec);
export async function cleanupOldData() {
    console.log(chalk.blue('🧹 古いデータをクリーンアップ中...'));
    await cleanupOldLogs();
    await cleanupTempFiles();
    await cleanupOldBranches();
    console.log(chalk.green('✅ クリーンアップ完了'));
}
async function cleanupOldLogs() {
    try {
        const logsDir = resolve(process.cwd(), 'logs');
        const files = await readdir(logsDir);
        const logFiles = files.filter(file => file.endsWith('.log'));
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - 7);
        let deletedCount = 0;
        for (const file of logFiles) {
            const filePath = resolve(logsDir, file);
            const stats = await stat(filePath);
            if (stats.mtime < cutoffDate && file !== 'issue-processor.log') {
                await unlink(filePath);
                deletedCount++;
            }
        }
        if (deletedCount > 0) {
            console.log(chalk.green(`✅ 古いログファイル ${deletedCount} 件を削除しました`));
        }
        else {
            console.log(chalk.gray('📋 削除対象のログファイルはありませんでした'));
        }
    }
    catch (error) {
        console.log(chalk.yellow('⚠️ ログファイルクリーンアップエラー:'), error);
    }
}
async function cleanupTempFiles() {
    try {
        const tempFiles = [
            '.temp-issue-context.md',
            '.temp-analysis-result.json',
            '.temp-fix-summary.md'
        ];
        let deletedCount = 0;
        for (const file of tempFiles) {
            try {
                const filePath = resolve(process.cwd(), '..', '..', file);
                await unlink(filePath);
                deletedCount++;
            }
            catch {
            }
        }
        if (deletedCount > 0) {
            console.log(chalk.green(`✅ 一時ファイル ${deletedCount} 件を削除しました`));
        }
        else {
            console.log(chalk.gray('📋 削除対象の一時ファイルはありませんでした'));
        }
    }
    catch (error) {
        console.log(chalk.yellow('⚠️ 一時ファイルクリーンアップエラー:'), error);
    }
}
async function cleanupOldBranches() {
    try {
        console.log(chalk.blue('🌿 古いGitブランチをクリーンアップ中...'));
        const { stdout } = await execAsync('git for-each-ref --format="%(refname:short) %(committerdate)" refs/heads/auto-fix/*', {
            cwd: resolve(process.cwd(), '..', '..')
        });
        const branches = stdout.trim().split('\\n').filter(line => line);
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - 14);
        let deletedCount = 0;
        for (const branchLine of branches) {
            const [branchName, ...dateParts] = branchLine.split(' ');
            const branchDate = new Date(dateParts.join(' '));
            if (branchDate < cutoffDate) {
                try {
                    await execAsync(`git branch -D ${branchName}`, {
                        cwd: resolve(process.cwd(), '..', '..')
                    });
                    deletedCount++;
                }
                catch {
                }
            }
        }
        if (deletedCount > 0) {
            console.log(chalk.green(`✅ 古いブランチ ${deletedCount} 件を削除しました`));
        }
        else {
            console.log(chalk.gray('📋 削除対象のブランチはありませんでした'));
        }
    }
    catch (error) {
        console.log(chalk.yellow('⚠️ Gitブランチクリーンアップをスキップしました'));
    }
}
//# sourceMappingURL=cleanup.js.map