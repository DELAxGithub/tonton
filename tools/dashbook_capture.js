const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  const url = process.env.DASHBOOK_URL || 'http://localhost:7357';
  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.screenshot({ path: 'dashbook_screenshot.png', fullPage: true });
  await browser.close();
})();
