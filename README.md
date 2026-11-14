# FPS Cleaner – Arma 3 FPS artırıcı (CBA gerekli)

Sunucu tarafında terrain objelerini (süs objeleri, çalı/ağaç kümeleri, yol kenarı) gizleyen/silen, yıkılmayı engelleyen
ve terrain/atmosfer/geometri ayarlarını CBA menüsünden yönetmenizi sağlayan bir mod.

> **Önemli:** Kod Arma 3 içinde çalıştırılarak test edilemedi (geliştirme ortamında oyun yok). Sadece
> `tools/check_sqf.py` ile sözdizimi/tanım tutarlılığı denetlendi. İlk denemeyi önce tek kişilik/Eden'de yapın,
> RPT dosyasında `[FPSC]` satırlarına bakın, hata çıkarsa bana iletin.

## Kurulum (Mikero araçlarıyla)
1. `addons/fpsc_main` klasörünün **içeriğini** `P:\z\fpsc\addons\fpsc_main` altına kopyalayın (`$PBOPREFIX$` = `z\fpsc\addons\fpsc_main`,
   `config.cpp` yolları da buna göre; klasör yolu önekle birebir aynı olmalı) ve **pboProject** ile paketleyin. Çıkan `fpsc_main.pbo`
   dosyasını `@FPS_Cleaner/addons/` altına koyun, `mod.cpp` dosyasını `@FPS_Cleaner/` altına kopyalayın.
2. `@CBA_A3` ile birlikte hem **sunucuya** hem **oyunculara** yükleyin (ayarlar menüsü ve terrain/geometri ayarları istemcide çalışır).
3. İsteğe bağlı: `userconfig/fpsc/hide_list.txt` ve `userconfig/cba_settings.sqf.example` dosyalarını sunucudaki `userconfig` klasörüne kopyalayın.

## Özellikler → CBA ayarları (Ayarlar › Eklenti Ayarları › FPS Cleaner)
| # | İstek | Ayar |
|---|-------|------|
| 1 | JBAD/CUP vb. objelerin classname'ini bulma | Tarama aracı (aşağıda) |
| 2 | Süs objelerini sunucu tarafından silme | **2 Süs objeleri**: liste + `hideObjectGlobal` |
| 3 | Kümeleri seyreltip tamamen silme | **3 Kümeler**: % slider (100 = küme tamamen silinir), hücre boyutu, min. obje |
| 4 | Atmosfer yaşamı + terrain grid | **6 Terrain**: atmosfer yaşamını kapat, atmosfer sesleri, terrain grid (50 … 3.125) |
| 5 | Yol kenarı objeleri, menzil slider'ı | **4 Yol kenarı**: 0–60 m slider + tür seçimi |
| 6 | Yıkılmayı engelleyen simülasyon ayarı | **5 Yıkılma / simülasyon**: `allowDamage false` (+ isteğe bağlı `enableSimulationGlobal false`) |
| 7 | Poligon azaltan geometri ayarı | **7 Geometri**: obje ve gölge çizim mesafesi (aşağıdaki nota bakın) |

### Geometri/poligon hakkında dürüst not
Arma 3'te script ile bir modelin poligonları **düzenlenemez** (LOD'lar p3d içindedir). Mod bunun yerine çizilen poligon
sayısını düşürür: obje/gölge çizim mesafesi (`setObjectViewDistance`), terrain grid (`setTerrainGrid`) ve asıl büyük kazanç
olan **objeleri hiç çizmemek** (süs listesi, küme seyreltme, yol kenarı). Gerçek mesh sadeleştirme için modellerin Object
Builder/Blender'da yeniden yapılması gerekir.

## Classname bulma (debug)
Debug konsolunda **Local Exec**:
```sqf
[300, "jbad,cup"] spawn FPSC_fnc_scan;   // çevrendeki 300 m, sadece jbad/cup eşleşmeleri
[0, "jbad"] spawn FPSC_fnc_scan;         // tüm harita (yavaş)
[] spawn FPSC_fnc_inspect;               // nişangahtaki obje
copyToClipboard FPSC_lastScanList;       // taramadaki girişler, virgülle ayrılmış
```
Kısayollar: **Ctrl+Shift+O** = 300 m tara, **Ctrl+Shift+I** = nişangahtaki objeyi incele (CBA tuş ayarlarından değiştirilebilir).

Çıktı üç yere gider: RPT (`[FPSC][SCAN]` satırları), panoya ve sohbete. Her satır: `adet | model dosyası | classname'ler | mod/addon | tam yol`.
Üstte klasör/PBO öneki özeti (a3 / cup / jbad …) bulunur; mevcut liste tarafından zaten eşleşenler `HIDE` ile işaretlenir.

### Süs listesi sözdizimi
`jbad_barrel_01` classname **veya** model dosyası (tam eşleşme) · `jbad_*` / `*bottle*` içeriyorsa eşleşir · `!jbad_house_01` asla gizleme.
Liste CBA kutusuna ya da `userconfig/fpsc/hide_list.txt` dosyasına yazılır (dosyada satır sonunda `\` kullanmayın, `/` kullanın).
Bir classname girdiğinizde mod onun `model` yolunu da bulur; aynı modeli kullanan terrain objeleri de silinir.

## Nasıl çalışır / performans
* Sunucu, oyuncuların çevresindeki haritayı ~250 m'lik parçalar halinde, kare başına en fazla `bütçe` ms kullanarak işler;
  oyuncu ilerledikçe yeni parçalar eklenir. `Yarıçap = 0` tüm haritayı işler (başlangıçta yavaş).
* Ayar değişince önce eski değişiklikler geri alınır, sonra yeniden uygulanır. Küme seçimi konuma göre deterministiktir.
* **Silme yöntemi**: *Sunucu* = `hideObjectGlobal` (AI/çarpışma dahil herkes için kalkar, sunucu FPS'ine de yarar, ama on binlerce obje JIP/ağ
  yükü yaratabilir). *Yerel* = her oyuncu kendisi gizler (ağ yükü yok, sunucuda objeler durur).
* `Yıkılmayı engelle › + binalar` ve `simülasyonu kapat` büyük haritalarda ağırdır; önce bitki/küçük objelerle deneyin.
* Yol kenarı menzili yol **orta çizgisine** göre ölçülür.

## Sınırlar
Terrain/atmosfer/geometri ayarları istemci ayarıdır (sunucu zorlayamaz). Sunucu ayarları için admin olmak ya da `cba_settings.sqf`
kullanmak gerekir. `tools/check_sqf.py` tam bir SQF ayrıştırıcısı değildir.
