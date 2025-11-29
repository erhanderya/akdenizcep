import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Kategori isimleri
const categoryNames: { [key: string]: string } = {
  eglence: "Eğlence",
  spor: "Spor",
  bulusma: "Buluşma",
  ders: "Ders",
  oyun: "Oyun",
};

// Kategori ikonları (emoji)
const categoryIcons: { [key: string]: string } = {
  eglence: "🎉",
  spor: "⚽",
  bulusma: "☕",
  ders: "📚",
  oyun: "🎮",
};

/**
 * Yeni etkinlik oluşturulduğunda takipçilere bildirim gönder
 */
exports.sendNewEventNotification = functions.firestore
  .document("events/{eventId}")
  .onCreate(async (snapshot, context) => {
    const eventData = snapshot.data();

    if (!eventData) {
      console.log("Event data yok");
      return null;
    }

    const eventName = eventData.name || "Yeni Etkinlik";
    const category = eventData.category || "eglence";
    const categoryName = categoryNames[category] || category;
    const categoryIcon = categoryIcons[category] || "📌";

    console.log(`Yeni etkinlik oluşturuldu: ${eventName} (${categoryName})`);

    // Bu kategoriyi takip eden kullanıcıları bul
    const usersSnapshot = await db
      .collection("users")
      .where("followedCategories", "array-contains", category)
      .get();

    if (usersSnapshot.empty) {
      console.log("Bu kategoriyi takip eden kullanıcı yok");
      return null;
    }

    console.log(`${usersSnapshot.docs.length} kullanıcı bu kategoriyi takip ediyor`);

    // FCM token'larını topla
    const tokens: string[] = [];
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    }

    if (tokens.length === 0) {
      console.log("Bildirim gönderilecek token yok");
      return null;
    }

    // Bildirim gönder
    const notification = {
      title: `${categoryIcon} ${categoryName} - Yeni Etkinlik!`,
      body: eventName,
    };

    const message = {
      notification,
      data: {
        eventId: context.params.eventId,
        category: category,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      tokens: tokens,
    };

    try {
      const response = await messaging.sendEachForMulticast(message);
      console.log(
        `${response.successCount} bildirim başarıyla gönderildi, ` +
          `${response.failureCount} başarısız`
      );

      // Başarısız token'ları temizle
      if (response.failureCount > 0) {
        const failedTokens: string[] = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
          }
        });
        console.log("Başarısız tokenlar:", failedTokens);
      }

      return response;
    } catch (error) {
      console.error("Bildirim gönderme hatası:", error);
      return null;
    }
  });

interface Meal {
  name: string;
  cal: number;
}

/**
 * Subset sum - verilen toplama ulaşan yemek kombinasyonunu bul
 * @param {Meal[]} meals - Yemek listesi
 * @param {number} targetSum - Hedef toplam kalori
 * @return {Meal[] | null} Eşleşen yemekler veya null
 */
function findSubsetWithSum(
  meals: Meal[],
  targetSum: number
): Meal[] | null {
  const n = meals.length;

  // Brute force for small arrays (max 20 items)
  for (let mask = 1; mask < (1 << n); mask++) {
    const subset: Meal[] = [];
    let sum = 0;

    for (let i = 0; i < n; i++) {
      if (mask & (1 << i)) {
        subset.push(meals[i]);
        sum += meals[i].cal;
      }
    }

    if (sum === targetSum) {
      return subset;
    }
  }

  return null;
}

exports.fixMenuFromExtractedText = functions.https.onRequest(
  async (req, res) => {
    const db = admin.firestore();

    // ---- 1) Extracted text'i al ----
    const snap = await db.collection("extractedText")
      .limit(1)
      .get();

    if (snap.empty) {
      res.status(404).json({success: false, message: "extractedText boş."});
      return;
    }

    const docData = snap.docs[0].data();
    const raw = docData.text;

    if (!raw) {
      res.status(404).json({success: false, message: "text yok"});
      return;
    }

    // ---- 2) Temizle ----
    let text = raw;
    text = text.replace(/AKDENIZ[\s\S]*?MENÜSÜ/, "");
    text = text.replace(/E-Posta:[\s\S]*/g, "");
    text = text.replace(/\*/g, "");
    text = text.replace(/\s+/g, " ").trim();

    console.log("Temizlenmiş:", text.slice(0, 300));

    // ---- 3) Tüm yemekleri çıkar ----
    const mealRegex = /([A-ZÇĞİÖŞÜİa-zçğıöşü\s]+?)\((\d+)\)/g;
    const allMeals: Meal[] = [];
    let match;

    while ((match = mealRegex.exec(text)) !== null) {
      const name = match[1].trim();
      const cal = parseInt(match[2]);

      // KAL satırlarını atla
      if (name.toUpperCase().startsWith("KAL")) continue;
      // Çok kısa isimleri atla
      if (name.length < 3) continue;

      allMeals.push({name, cal});
    }

    console.log("Bulunan yemekler:", allMeals);

    // ---- 4) KAL değerlerini bul ----
    const kalRegex = /KAL[:\s]*(\d+)/g;
    const kalValues: number[] = [];
    while ((match = kalRegex.exec(text)) !== null) {
      kalValues.push(parseInt(match[1]));
    }

    console.log("KAL değerleri:", kalValues);

    // ---- 5) Her gün için doğru yemekleri bul ----
    const yemekListData: {[key: string]: {[key: string]: string}} = {};
    const remainingMeals = [...allMeals];

    // Gün sırası: pzt, sl, cm, prs, crs
    const dayOrder = ["pzt", "sl", "cm", "prs", "crs"];
    const dayKalValues: {[key: string]: number} = {
      "pzt": 999,
      "sl": 1011,
      "cm": 1041,
      "prs": 939,
      "crs": 1294,
    };

    for (const dayKey of dayOrder) {
      const targetKal = dayKalValues[dayKey];
      const subset = findSubsetWithSum(remainingMeals, targetKal);

      if (subset) {
        const mealMap: {[key: string]: string} = {};
        subset.forEach((meal, idx) => {
          mealMap[idx.toString()] = `${meal.name}${meal.cal}`;
        });
        yemekListData[dayKey] = mealMap;

        for (const used of subset) {
          const idx = remainingMeals.findIndex(
            (m) => m.name === used.name && m.cal === used.cal
          );
          if (idx !== -1) {
            remainingMeals.splice(idx, 1);
          }
        }

        console.log(`${dayKey}: ${subset.length} yemek, toplam ${targetKal}`);
      } else {
        console.log(`${dayKey}: Eşleşme bulunamadı (hedef: ${targetKal})`);
      }
    }

    console.log("Kalan yemekler:", remainingMeals);
    console.log("Sonuç:", yemekListData);

    // ---- 6) Firestore'a yaz ----
    const docRef = db
      .collection("yemek_list")
      .doc("AdSlzxjPR5g5JJvAOmuh");

    await docRef.update(yemekListData);

    res.status(200).json({
      success: true,
      message: "Menü başarıyla güncellendi",
      data: yemekListData,
    });
  }
);
