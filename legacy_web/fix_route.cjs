const fs = require('fs');
const path = require('path');

const filePath = path.join('C:\\Users\\akinrodolu.olajide\\Documents\\transitwallet\\src\\features\\onboarding\\RouteScreen.tsx');
let content = fs.readFileSync(filePath, 'utf8');
content = content.replace(/<div className="stop-edit-num">\{i \+ 1\}<\/div>/g, '<div className="stop-edit-num">{index + 1}</div>');
fs.writeFileSync(filePath, content);
console.log('Fixed RouteScreen.tsx');
