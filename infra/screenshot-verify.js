/**
 * Prisma - verificacao visual real de uma landing publicada.
 *
 * Corre no servidor (Puppeteer local nao tem sentido: precisa da rede/Chrome
 * do droplet, nao da maquina do operador). Tira screenshots full-page a
 * 320/380/768/1440/1920, mede scrollWidth vs clientWidth (deteta overflow
 * horizontal da pagina) e, se existir um `.filmstrip`, confirma que o
 * overflow horizontal fica contido nele (nao na pagina).
 *
 * Uso (dentro do container ghcr.io/puppeteer/puppeteer, ver AGENT.md):
 *   node screenshot-verify.js <url1>=<slug1> [<url2>=<slug2> ...]
 *
 * Duas notas de quem já foi mordido por isto:
 * 1. Chrome faz upgrade automatico de http:// para https:// (HTTPS-Upgrades)
 *    e falha em silencio (ERR_BLOCKED_BY_CLIENT) num host sem TLS como este.
 *    Por isso o --disable-features abaixo.
 * 2. `loading="lazy"` e correto para visitantes reais, mas um resize
 *    instantaneo para full-page (o que fullPage:true faz) nao da tempo ao
 *    browser de decidir carregar imagens fora do viewport inicial -- e
 *    scroll vertical da pagina NAO dispara lazy-load dentro de um
 *    `.filmstrip` com overflow-x proprio. Por isso forcamos eager antes de
 *    capturar: queremos a pagina fiel para verificacao, nao simular scroll.
 */
const puppeteer = require('puppeteer');

const WIDTHS = [320, 380, 768, 1440, 1920];
const OUT_DIR = process.env.OUT_DIR || '/out';

function parseTargets(argv) {
  return argv.slice(2).map((arg) => {
    const eq = arg.lastIndexOf('=');
    if (eq === -1) throw new Error(`argumento invalido (esperado url=slug): ${arg}`);
    return { url: arg.slice(0, eq), slug: arg.slice(eq + 1) };
  });
}

(async () => {
  const targets = parseTargets(process.argv);
  if (!targets.length) {
    console.error('Uso: node screenshot-verify.js <url1>=<slug1> [<url2>=<slug2> ...]');
    process.exit(1);
  }

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-features=HttpsUpgrades,HttpsFirstBalancedModeAutoEnable']
  });
  const results = [];

  for (const target of targets) {
    for (const width of WIDTHS) {
      const page = await browser.newPage();
      await page.setViewport({ width, height: 1000 });
      await page.goto(target.url, { waitUntil: 'networkidle0', timeout: 60000 });
      await page.evaluate(() => document.fonts.ready);
      await page.evaluate(() => document.querySelectorAll('img[loading="lazy"]').forEach((img) => { img.loading = 'eager'; }));

      const scrollHeight = await page.evaluate(() => document.body.scrollHeight);
      for (let y = 0; y < scrollHeight; y += 500) {
        await page.evaluate((yy) => window.scrollTo(0, yy), y);
        await new Promise((r) => setTimeout(r, 220));
      }
      await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
      await new Promise((r) => setTimeout(r, 400));

      const hasFilmstrip = await page.evaluate(() => !!document.querySelector('.filmstrip'));
      if (hasFilmstrip) {
        await page.evaluate(async () => {
          const el = document.querySelector('.filmstrip');
          const maxScroll = el.scrollWidth - el.clientWidth;
          const hStep = Math.max(200, Math.floor(el.clientWidth / 2));
          for (let x = 0; x <= maxScroll; x += hStep) {
            el.scrollLeft = x;
            await new Promise((r) => setTimeout(r, 180));
          }
          el.scrollLeft = maxScroll;
          await new Promise((r) => setTimeout(r, 300));
          el.scrollLeft = 0;
        });
        await new Promise((r) => setTimeout(r, 400));
      }

      await page.waitForFunction(
        () => Array.from(document.querySelectorAll('img')).every((img) => !img.hasAttribute('src') || img.complete),
        { timeout: 30000 }
      ).catch(async () => {
        const pending = await page.evaluate(() => Array.from(document.querySelectorAll('img')).filter((img) => img.hasAttribute('src') && !img.complete).map((img) => img.src));
        console.log(`  aviso: timeout a esperar imagens em ${target.slug}-${width} -- pendentes: ${JSON.stringify(pending)}`);
      });

      await page.evaluate(() => window.scrollTo(0, 0));
      await new Promise((r) => setTimeout(r, 400));

      const metrics = await page.evaluate(() => {
        const doc = document.documentElement;
        const filmstrip = document.querySelector('.filmstrip');
        return {
          scrollWidth: doc.scrollWidth,
          clientWidth: doc.clientWidth,
          filmstripScrollWidth: filmstrip ? filmstrip.scrollWidth : null,
          filmstripClientWidth: filmstrip ? filmstrip.clientWidth : null
        };
      });
      const overflow = metrics.scrollWidth > metrics.clientWidth;
      results.push({ slug: target.slug, width, ...metrics, pageOverflowHorizontal: overflow });

      const fileName = `${target.slug}-${width}.png`;
      await page.screenshot({ path: `${OUT_DIR}/${fileName}`, fullPage: true });
      console.log(`OK ${fileName} | scrollWidth=${metrics.scrollWidth} clientWidth=${metrics.clientWidth} overflow=${overflow} | filmstrip scrollWidth=${metrics.filmstripScrollWidth} clientWidth=${metrics.filmstripClientWidth}`);

      await page.close();
    }
  }

  await browser.close();
  require('fs').writeFileSync(`${OUT_DIR}/_metrics.json`, JSON.stringify(results, null, 2));
  console.log('DONE');
})().catch((e) => { console.error('FAILED', e); process.exit(1); });
