const fs = require('fs');
let css = fs.readFileSync('src/index.css', 'utf8');

// Replace the font import
css = css.replace(
  /@import url\('https:\/\/fonts.googleapis.com\/css2\?family=Anton&family=Oswald.*?'\);/,
  "@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');"
);

// Remove specific font-family declarations so they inherit Inter
css = css.replace(/font-family:\s*['"]?Oswald['"]?(,\s*sans-serif)?;\s*/g, '');
css = css.replace(/font-family:\s*['"]?Anton['"]?(,\s*sans-serif)?;\s*/g, '');

// Update font weight for the display fonts that lost Anton's thickness
css = css.replace(/\.today-total\{\s*(font-size:38px;)/g, '.today-total{ font-weight:800; $1');
css = css.replace(/\.wallet-amount\{\s*(font-size:30px;)/g, '.wallet-amount{ font-weight:800; $1');
css = css.replace(/\.amount-display\{\s*(font-size:44px;)/g, '.amount-display{ font-weight:800; $1');
css = css.replace(/\.sidebar-brand\s*\{\s*(font-size: 24px;)/g, '.sidebar-brand { font-weight: 800; $1');

fs.writeFileSync('src/index.css', css);
console.log('CSS fonts purged successfully');
