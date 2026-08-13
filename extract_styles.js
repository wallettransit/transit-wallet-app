const fs = require('fs');
const data = JSON.parse(fs.readFileSync('figma_file.json', 'utf8'));

const targetScreens = [
  'group-ride-home',
  'group-ride-pickup',
  'group-ride-destination',
  'group-ride-date-time',
  'group-ride-available-groups',
  'group-ride-details',
  'group-ride-fare-review',
  'group-ride-payment',
  'group-ride-confirmed'
];

const found = {};
function findNode(node) {
  if (targetScreens.includes(node.name)) {
    found[node.name] = node;
  }
  if (node.children) node.children.forEach(findNode);
}
findNode(data.document);

function getStyles(node, depth = 0) {
  if (depth > 6) return '';
  let styles = [];
  
  if (node.type === 'TEXT') {
    const style = node.style;
    const txt = node.characters.replace(/\n/g, '\\n');
    styles.push('TEXT: "' + txt + '"');
    if (style) {
      styles.push('  font: ' + style.fontFamily + ' ' + style.fontWeight + ' ' + style.fontSize + 'px');
      if (style.lineHeightPx) styles.push('  lineHeight: ' + style.lineHeightPx.toFixed(1) + 'px');
      if (style.letterSpacing) styles.push('  letterSpacing: ' + style.letterSpacing);
    }
    if (node.fills && node.fills.length > 0 && node.fills[0].color) {
      const c = node.fills[0].color;
      styles.push('  color: rgba(' + Math.round(c.r*255) + ',' + Math.round(c.g*255) + ',' + Math.round(c.b*255) + ',' + (c.a||1).toFixed(2) + ')');
    }
  } else if (['FRAME', 'COMPONENT', 'INSTANCE', 'RECTANGLE'].includes(node.type)) {
    styles.push('BOX: ' + node.name);
    if (node.absoluteBoundingBox) {
      styles.push('  size: ' + node.absoluteBoundingBox.width + 'x' + node.absoluteBoundingBox.height);
    }
    if (node.cornerRadius) styles.push('  radius: ' + node.cornerRadius);
    if (node.paddingTop) styles.push('  pad: ' + node.paddingTop + ' ' + node.paddingRight + ' ' + node.paddingBottom + ' ' + node.paddingLeft);
    if (node.itemSpacing) styles.push('  gap: ' + node.itemSpacing);
    if (node.layoutMode) styles.push('  layout: ' + node.layoutMode + ' align: ' + node.primaryAxisAlignItems + ' ' + node.counterAxisAlignItems);
    if (node.fills && node.fills.length > 0 && node.fills[0].color) {
      const c = node.fills[0].color;
      styles.push('  bg: rgba(' + Math.round(c.r*255) + ',' + Math.round(c.g*255) + ',' + Math.round(c.b*255) + ',' + (c.a||1).toFixed(2) + ')');
    }
    if (node.strokes && node.strokes.length > 0 && node.strokes[0].color) {
      const c = node.strokes[0].color;
      styles.push('  border: rgba(' + Math.round(c.r*255) + ',' + Math.round(c.g*255) + ',' + Math.round(c.b*255) + ',' + (c.a||1).toFixed(2) + ') width: ' + node.strokeWeight);
    }
  }
  
  if (node.children) {
    node.children.forEach(c => {
      const sub = getStyles(c, depth + 1);
      if (sub) styles.push('  ' + sub.replace(/\n/g, '\n  '));
    });
  }
  return styles.join('\n');
}

const allStyles = {};
for (const name of targetScreens) {
  if (found[name]) {
    allStyles[name] = getStyles(found[name]);
  }
}
fs.writeFileSync('figma_exact_styles.txt', JSON.stringify(allStyles, null, 2));
console.log('Saved to figma_exact_styles.txt');
