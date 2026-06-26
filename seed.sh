#!/usr/bin/env bash
# Seed script for Souvenir Collection
# Run: bash seed.sh
set -e

API="http://127.0.0.1:5248/api"
H_KEY="X-API-KEY: mobile-key123"
CT="Content-Type: application/json"

# Helper: extract JSON field using node
jq() {
  node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.data?.${1} ?? '')"
}

echo "============================================"
echo "  Seeding Souvenir Collection Database"
echo "============================================"

# ── Step 1: Login ──
echo ""
echo "--- Step 1: Login ---"
LOGIN=$(curl -s -H "$H_KEY" -H "$CT" \
  -d '{"email":"sokha@example.com","password":"password123"}' \
  "$API/auth/login")
echo "Login: $(echo "$LOGIN" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.success)")"

TOKEN=$(echo "$LOGIN" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.accessToken ?? '')")
AUTH="Authorization: Bearer $TOKEN"

# Get user ID via /auth/me
ME=$(curl -s -H "$H_KEY" -H "$AUTH" "$API/auth/me")
USER_ID=$(echo "$ME" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? '')")
echo "USER_ID = $USER_ID"

# ── Step 2: Create Categories ──
echo ""
echo "--- Step 2: Create Categories ---"
cats=("Textile" "Silver" "Wood" "Ceramics" "Jewelry")
declare -A CAT_IDS
for c in "${cats[@]}"; do
  RESP=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" \
    -d "{\"name\":\"$c\",\"image\":\"\"}" "$API/categories")
  CID=$(echo "$RESP" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
  CAT_IDS["$c"]="$CID"
  echo "  $c → $CID"
done

# ── Step 3: Create Artisans ──
echo ""
echo "--- Step 3: Create Artisans ---"

A1=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "displayName":"Sokunthea Silk Weaver","region":"Siem Reap","craftType":"Textile",
  "bio":"Third-generation silk weaver preserving traditional Khmer ikat patterns since 1985.",
  "profilePhotoUrl":"https://images.unsplash.com/photo-1590736961830-e1a2b3c4d5e6?w=400",
  "shopAddress":"Wat Damnak Village, Siem Reap","lat":13.3671,"lng":103.8632
}' "$API/artisans")
ART1=$(echo "$A1" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Artisan 1 (Textile) → $ART1"

A2=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "displayName":"Dara Silver Workshop","region":"Phnom Penh","craftType":"Silver",
  "bio":"Master silversmith crafting intricate jewelry and ceremonial bowls with 99.9% pure Cambodian silver.",
  "profilePhotoUrl":"https://images.unsplash.com/photo-1580870069867-74c5c1e4d9a7?w=400",
  "shopAddress":"Russian Market Area, Phnom Penh","lat":11.5365,"lng":104.9190
}' "$API/artisans")
ART2=$(echo "$A2" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Artisan 2 (Silver) → $ART2"

A3=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "displayName":"Bunna Wood Carving","region":"Kampong Thom","craftType":"Wood",
  "bio":"Hand-carved wooden sculptures inspired by Angkorian bas-reliefs and Buddhist teachings.",
  "profilePhotoUrl":"https://images.unsplash.com/photo-1565193566173-7a0af2bf2306?w=400",
  "shopAddress":"Sambor Village, Kampong Thom","lat":12.7116,"lng":104.8891
}' "$API/artisans")
ART3=$(echo "$A3" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Artisan 3 (Wood) → $ART3"

A4=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "displayName":"Maly Ceramic Studio","region":"Kampong Chhnang","craftType":"Ceramics",
  "bio":"Hand-thrown pottery using locally sourced clay and traditional wood-fired kilns.",
  "profilePhotoUrl":"https://images.unsplash.com/photo-1565193566173-7a0af2bf2306?w=400",
  "shopAddress":"Andoung Snay Village, Kampong Chhnang","lat":12.2540,"lng":104.6660
}' "$API/artisans")
ART4=$(echo "$A4" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Artisan 4 (Ceramics) → $ART4"

# ── Step 4: Create Products ──
echo ""
echo "--- Step 4: Create Products ---"

P1=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART1\",\"categoryId\":\"${CAT_IDS[Textile]}\",
  \"name\":\"Handwoven Ikat Silk Scarf\",
  \"description\":\"Luxurious handwoven scarf using traditional Khmer ikat techniques. Dyed with natural indigo and prohut bark.\",
  \"price\":45.00,\"stockQty\":15,
  \"image\":\"https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=600\",
  \"isAvailable\":true
}" "$API/products")
P1_ID=$(echo "$P1" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 1 → $P1_ID"

P2=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART1\",\"categoryId\":\"${CAT_IDS[Textile]}\",
  \"name\":\"Cotton Krama Scarf\",
  \"description\":\"The iconic Cambodian krama — a multipurpose cotton scarf worn by Khmer people for centuries.\",
  \"price\":12.00,\"stockQty\":50,
  \"image\":\"https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600\",
  \"isAvailable\":true
}" "$API/products")
P2_ID=$(echo "$P2" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 2 → $P2_ID"

P3=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART2\",\"categoryId\":\"${CAT_IDS[Silver]}\",
  \"name\":\"Silver Elephant Pendant\",
  \"description\":\"Handcrafted 99.9% pure silver pendant depicting a walking elephant. Hand-chiseled details.\",
  \"price\":68.00,\"stockQty\":8,
  \"image\":\"https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=600\",
  \"isAvailable\":true
}" "$API/products")
P3_ID=$(echo "$P3" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 3 → $P3_ID"

P4=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART2\",\"categoryId\":\"${CAT_IDS[Jewelry]}\",
  \"name\":\"Apsara Silver Bracelet\",
  \"description\":\"Intricate bracelet inspired by Apsara celestial dancers of Angkor Wat. Hand-engraved floral motifs.\",
  \"price\":95.00,\"stockQty\":5,
  \"image\":\"https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600\",
  \"isAvailable\":true
}" "$API/products")
P4_ID=$(echo "$P4" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 4 → $P4_ID"

P5=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART3\",\"categoryId\":\"${CAT_IDS[Wood]}\",
  \"name\":\"Angkor Wat Wood Panel\",
  \"description\":\"Hand-carved rosewood wall panel depicting the iconic Angkor Wat temple. Intricate bas-relief style.\",
  \"price\":150.00,\"stockQty\":3,
  \"image\":\"https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=600\",
  \"isAvailable\":true
}" "$API/products")
P5_ID=$(echo "$P5" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 5 → $P5_ID"

P6=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART3\",\"categoryId\":\"${CAT_IDS[Wood]}\",
  \"name\":\"Buddha Face Wall Hanging\",
  \"description\":\"Serene Buddha face carved from reclaimed mahogany. Finished with natural beeswax.\",
  \"price\":85.00,\"stockQty\":6,
  \"image\":\"https://images.unsplash.com/photo-1508182319732-8e0e2e7c78e3?w=600\",
  \"isAvailable\":true
}" "$API/products")
P6_ID=$(echo "$P6" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 6 → $P6_ID"

P7=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"artisanId\":\"$ART4\",\"categoryId\":\"${CAT_IDS[Ceramics]}\",
  \"name\":\"Khmer Lotus Tea Set\",
  \"description\":\"Hand-thrown ceramic tea set with lotus petal design. Includes teapot and 4 cups.\",
  \"price\":72.00,\"stockQty\":10,
  \"image\":\"https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600\",
  \"isAvailable\":true
}" "$API/products")
P7_ID=$(echo "$P7" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Product 7 → $P7_ID"

# ── Step 5: Create Collections ──
echo ""
echo "--- Step 5: Create Collections ---"

C1=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "title":"Angkor Collection","slug":"angkor-collection",
  "description":"Pieces inspired by the temples of Angkor — from sandstone hues to Apsara motifs.",
  "type":"Featured",
  "image":"https://images.unsplash.com/photo-1580618672591-ebc3f7a3b9cb?w=800"
}' "$API/collections")
COL1=$(echo "$C1" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Collection 1 → $COL1"

C2=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "title":"Silk & Weave Heritage","slug":"silk-weave-heritage",
  "description":"Centuries-old weaving traditions from Cambodia rural provinces. Hand-dyed silks and cotton kramas.",
  "type":"Textile",
  "image":"https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=800"
}' "$API/collections")
COL2=$(echo "$C2" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Collection 2 → $COL2"

C3=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "title":"Silver & Gold Craft","slug":"silver-gold-craft",
  "description":"Precious metalwork from Cambodia finest silversmiths. Necklaces, bracelets, ceremonial bowls.",
  "type":"Jewelry",
  "image":"https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=800"
}' "$API/collections")
COL3=$(echo "$C3" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Collection 3 → $COL3"

# ── Step 6: Add Products to Collections ──
echo ""
echo "--- Step 6: Add Products to Collections ---"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/collections/$COL1/products?productId=$P5_ID" > /dev/null && echo "  + P5 → Angkor Collection"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/collections/$COL1/products?productId=$P6_ID" > /dev/null && echo "  + P6 → Angkor Collection"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/collections/$COL2/products?productId=$P1_ID" > /dev/null && echo "  + P1 → Silk & Weave"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/collections/$COL2/products?productId=$P2_ID" > /dev/null && echo "  + P2 → Silk & Weave"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/collections/$COL3/products?productId=$P3_ID" > /dev/null && echo "  + P3 → Silver & Gold"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/collections/$COL3/products?productId=$P4_ID" > /dev/null && echo "  + P4 → Silver & Gold"

# ── Step 7: Verify Artisans ──
echo ""
echo "--- Step 7: Verify Artisans ---"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/artisans/$ART1/verify" > /dev/null && echo "  Verified: $ART1"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/artisans/$ART2/verify" > /dev/null && echo "  Verified: $ART2"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/artisans/$ART3/verify" > /dev/null && echo "  Verified: $ART3"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/artisans/$ART4/verify" > /dev/null && echo "  Verified: $ART4"

# ── Step 8: Create Quiz ──
echo ""
echo "--- Step 8: Create Quiz ---"

Q1=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" \
  -d '{"questionText":"What type of gift are you looking for?","displayOrder":1}' "$API/quiz")
Q1_ID=$(echo "$Q1" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Question 1 → $Q1_ID"

curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q1_ID\",\"answerText\":\"Something to wear\",\"tags\":\"textile,scarf,clothing\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Something to wear"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q1_ID\",\"answerText\":\"Home decoration\",\"tags\":\"wood,ceramics,decor\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Home decoration"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q1_ID\",\"answerText\":\"Jewelry or accessory\",\"tags\":\"silver,jewelry,pendant,bracelet\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Jewelry or accessory"

Q2=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" \
  -d '{"questionText":"What is your budget?","displayOrder":2}' "$API/quiz")
Q2_ID=$(echo "$Q2" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Question 2 → $Q2_ID"

curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q2_ID\",\"answerText\":\"Under \$25\",\"tags\":\"budget,scarf,krama\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Under \$25"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q2_ID\",\"answerText\":\"\$25–\$100\",\"tags\":\"mid,pendant,tea,bracelet\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: \$25–\$100"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q2_ID\",\"answerText\":\"Over \$100\",\"tags\":\"premium,panel,silver\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Over \$100"

Q3=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" \
  -d '{"questionText":"Who is the gift for?","displayOrder":3}' "$API/quiz")
Q3_ID=$(echo "$Q3" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Question 3 → $Q3_ID"

curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q3_ID\",\"answerText\":\"Family member\",\"tags\":\"scarf,tea,traditional\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Family member"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q3_ID\",\"answerText\":\"Friend\",\"tags\":\"pendant,bracelet,silver\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Friend"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q3_ID\",\"answerText\":\"Myself\",\"tags\":\"panel,scarf,decor\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Myself"

Q4=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" \
  -d '{"questionText":"What style do they prefer?","displayOrder":4}' "$API/quiz")
Q4_ID=$(echo "$Q4" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Question 4 → $Q4_ID"

curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q4_ID\",\"answerText\":\"Traditional & cultural\",\"tags\":\"silk,wood,krama,ikat\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Traditional & cultural"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q4_ID\",\"answerText\":\"Modern & minimalist\",\"tags\":\"silver,ceramic,tea\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Modern & minimalist"
curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{\"questionId\":\"$Q4_ID\",\"answerText\":\"Bold & artistic\",\"tags\":\"ikat,pendant,panel\"}" "$API/quiz/answer" > /dev/null && echo "    Answer: Bold & artistic"

# ── Step 9: Create Promotions ──
echo ""
echo "--- Step 9: Create Promotions ---"

PR1=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "title":"Welcome 15% Off","code":"WELCOME15",
  "description":"New customer discount — 15% off your first purchase.",
  "image":"","discountType":"Percentage","discount":15,"usageLimit":100,
  "startDate":"2026-06-01T00:00:00Z","endDate":"2026-12-31T23:59:59Z"
}' "$API/promotions")
PR1_ID=$(echo "$PR1" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Promotion 1 → $PR1_ID"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/promotions/$PR1_ID/activate" > /dev/null && echo "    Activated!"

PR2=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d '{
  "title":"$10 Off Orders Over $50","code":"KHMR10",
  "description":"Save $10 when you spend $50 or more on any Khmer handmade products.",
  "image":"","discountType":"FixedAmount","discount":10,"usageLimit":50,
  "startDate":"2026-06-01T00:00:00Z","endDate":"2026-09-30T23:59:59Z"
}' "$API/promotions")
PR2_ID=$(echo "$PR2" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Promotion 2 → $PR2_ID"
curl -s -H "$H_KEY" -H "$AUTH" -X POST "$API/promotions/$PR2_ID/activate" > /dev/null && echo "    Activated!"

# ── Step 10: Create Reviews ──
echo ""
echo "--- Step 10: Create Reviews ---"
R1=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"userId\":\"$USER_ID\",\"productId\":\"$P1_ID\",
  \"reviewText\":\"Absolutely stunning scarf! The colors are even more vibrant in person. You can feel the craftsmanship.\",
  \"rating\":5,\"image\":\"\"
}" "$API/reviews")
R1_ID=$(echo "$R1" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")
echo "  Review 1 → $R1_ID"

R2=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"userId\":\"$USER_ID\",\"productId\":\"$P3_ID\",
  \"reviewText\":\"Beautiful silver pendant, arrived in a lovely gift box. Perfect present for my sister.\",
  \"rating\":5,\"image\":\"\"
}" "$API/reviews")
echo "  Review 2 → $(echo "$R2" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")"

R3=$(curl -s -H "$H_KEY" -H "$CT" -H "$AUTH" -d "{
  \"userId\":\"$USER_ID\",\"productId\":\"$P5_ID\",
  \"reviewText\":\"The carving detail is incredible. Looks amazing on my wall. Shipping was fast too.\",
  \"rating\":4,\"image\":\"\"
}" "$API/reviews")
echo "  Review 3 → $(echo "$R3" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.stdout.write(d.data?.id ?? 'FAIL')")"

echo ""
echo "============================================"
echo "  ✅ SEEDING COMPLETE!"
echo "============================================"
echo ""
echo "Summary of created IDs:"
echo "  USER_ID  = $USER_ID"
echo "  CATEGORIES = ${CAT_IDS[*]}"
echo "  ARTISANS   = $ART1 $ART2 $ART3 $ART4"
echo "  PRODUCTS   = $P1_ID $P2_ID $P3_ID $P4_ID $P5_ID $P6_ID $P7_ID"
echo "  COLLECTIONS = $COL1 $COL2 $COL3"
echo "  QUIZ Qs    = $Q1_ID $Q2_ID $Q3_ID $Q4_ID"
echo "  PROMOTIONS = $PR1_ID $PR2_ID"
echo ""
echo "Restart your Flutter app to see all the data!"
