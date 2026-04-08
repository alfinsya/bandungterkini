const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'article', 'berita1.html');
const content = fs.readFileSync(filePath, 'utf8');
const metaMatch = content.match(/<div[^>]*class="[^\"]*mb-3[^\"]*"[^>]*>([\s\S]*?)<\/div>/i);
console.log('metaMatch', !!metaMatch);
if (metaMatch) {
  console.log('snippet', metaMatch[1].slice(0, 200));
  const catMatch = metaMatch[1].match(/<a[^>]*class="[^\"]*badge[^\"]*"[^>]*>([^<]+)<\/a>/i);
  const dateMatch = metaMatch[1].match(/<a[^>]*class="[^\"]*text-body[^\"]*"[^>]*>([^<]+)<\/a>/i);
  console.log('catMatch', catMatch ? catMatch[1] : 'none');
  console.log('dateMatch', dateMatch ? dateMatch[1] : 'none');
}
