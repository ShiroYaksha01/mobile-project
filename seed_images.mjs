// Clear all product images — let the Khmer gradient patterns show
import http from 'http';

const API = 'http://127.0.0.1:5248/api';

function req(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(API + path);
    const options = {
      method, hostname: url.hostname, port: url.port, path: url.pathname + url.search,
      headers: {
        'X-API-KEY': 'mobile-key123',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + TOKEN,
      }
    };
    const r = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch { resolve(data); } });
    });
    r.on('error', reject);
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

let TOKEN = '';

async function main() {
  // Login
  const login = await req('POST', '/auth/login', { email: 'sokha@example.com', password: 'password123' });
  TOKEN = login.data?.accessToken || '';
  console.log('Logged in');

  // Get all products
  const prods = await req('GET', '/products');
  const products = prods.data || [];
  console.log(`Found ${products.length} products`);

  // Update each product to have empty image (gradient pattern)
  for (const p of products) {
    await req('PUT', `/products/${p.id}`, {
      artisanId: p.artisanId,
      categoryId: p.categoryId,
      name: p.name,
      description: p.description || '',
      price: p.price,
      stockQty: p.stockQty || 10,
      image: '',  // Clear image → Khmer gradient pattern
      isAvailable: true,
    });
    console.log(`  Updated: ${p.name}`);
  }

  console.log('\nDone! All products now use Khmer gradient patterns.');
}

main().catch(e => console.error(e.message));
