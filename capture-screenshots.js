#!/usr/bin/env node

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(path.join(__dirname, 'example', 'screenshots.html')));

  const elements = await page.$$('.screenshot');

  for (let i = 0; i < elements.length; i++) {
    const el = elements[i];
    const filename = await (await el.getProperty('id')).jsonValue();

    const isAnimatedGif = filename.match(/-[0-9]+$/);

    if (isAnimatedGif) {
      console.log(`Capturing ${filename}.png`);
      const screenshot = await page.screenshot({
        path: `${filename}.png`,
        clip: await el.boundingBox(),
      });
    } else {
      console.log(`Capturing ${filename}.svg`);
      const html = await page.$eval(`#${filename} svg`, dom => {
        return dom.outerHTML;
      });
      fs.writeFileSync(`${filename}.svg`, svgFile(html));
    }

    await page.$eval(`#${filename}`, dom => {
      dom.parentNode.removeChild(dom);
    });
  }

  await browser.close();
})();

function svgFile(xml) {
  const header = '<?xml version="1.0" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';
  return header + xml.replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" ');
}
