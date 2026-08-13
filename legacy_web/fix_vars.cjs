const fs = require('fs');
const path = require('path');

const files = {
  'src/components/MapBackground.tsx': (content) => content.replace(/const onUnmount = useCallback\(function callback\(map: any\) \{/g, 'const onUnmount = useCallback(function callback(_map: any) {'),
  'src/features/dashboard/HomeScreen.tsx': (content) => content.replace(/import \{ useNavigate \} from 'react-router-dom';\n/g, ''),
  'src/features/onboarding/RouteScreen.tsx': (content) => content.replace(/<div className="stop-edit-num">\{i \+ 1\}<\/div>/g, '<div className="stop-edit-num">{index + 1}</div>'),
  'src/features/wallet/WithdrawAmtScreen.tsx': (content) => content.replace(/const fmt = \(n: number\) => n.toLocaleString\(\);\n/g, '')
};

for (const [file, replacer] of Object.entries(files)) {
  const fullPath = path.join('C:\\Users\\akinrodolu.olajide\\Documents\\transitwallet', file);
  if (fs.existsSync(fullPath)) {
    let content = fs.readFileSync(fullPath, 'utf8');
    content = replacer(content);
    fs.writeFileSync(fullPath, content);
    console.log('Fixed', file);
  }
}
