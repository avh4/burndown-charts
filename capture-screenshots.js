#!/usr/bin/env node

const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(path.join(__dirname, 'example', 'screenshots.html')));

  const elements = await page.$$('.screenshot');

  for (let i = 0; i < elements.length; i++) {
    const el = elements[i];
    const filename = await (await el.getProperty('id')).jsonValue();
    console.log(`Capturing ${filename}.png`);
    const screenshot = await page.screenshot({
      path: `${filename}.png`,
      clip: await el.boundingBox(),
    });

    await page.$eval(`#${filename}`, dom => {
      dom.parentNode.removeChild(dom);
    });
  }

  await browser.close();
})();
