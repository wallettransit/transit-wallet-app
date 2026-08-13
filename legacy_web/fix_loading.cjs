const fs = require('fs');
const path = require('path');

const files = {
  'src/features/onboarding/PaymentAccountScreen.tsx': (content) => content.replace(/const \{ user, updateUser, isLoading \} = useAuthStore\(\);/g, 'const { user, updateUser } = useAuthStore();'),
  'src/features/onboarding/VehicleScreen.tsx': (content) => content.replace(/const \{ user, updateUser, isLoading \} = useAuthStore\(\);/g, 'const { user, updateUser } = useAuthStore();')
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
