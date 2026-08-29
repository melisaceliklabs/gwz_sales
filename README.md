# gwz_sales

## Proje Hakkında

GreenWeez satış ekibi için bir gösterge paneli hazırlama senaryosu kapsamında,
`gwz_sales` tablosu üzerinde SQL sorguları yazıyorum. Sorguları VS Code'da
geliştirip BigQuery'de test ediyorum.

BigQuery içinde sorgunun farklı sürümlerini kaydetmek yerine, SQL
dosyalarındaki değişiklikleri Git ile takip ediyorum.

Bu proje Workintech Veri Analitiği eğitimi kapsamında hazırlanmıştır.

## Veri Kaynağı

Veriler BigQuery'de barındırılıyor, repoda veri dosyası bulunmuyor.

**Tablo:** `data-analytics-469406.course14.gwz_sales`
(Workintech eğitim ortamında sağlanmıştır; konsol erişimi yetki gerektirir.)

**Boyut:** 1.486.388 satır

**Dönem:** 2021-03-01 – 2021-08-31 (184 gün)

Tarih aralığındaki tüm günlerin veride mevcut olduğunu `GENERATE_DATE_ARRAY`
ile ürettiğim takvimle karşılaştırarak doğruladım; eksik gün bulunmuyor. Veri
seti tam bir yılı kapsamadığı için mevsimsellik veya yıllık trend yorumu
yapılamaz.

### Kolonlar

| Kolon | Tip | Açıklama |
|---|---|---|
| `date_date` | DATE | Sipariş tarihi (saat bilgisi içermez) |
| `orders_id` | INTEGER | Sipariş numarası |
| `products_id` | INTEGER | Ürün numarası |
| `customers_id` | INTEGER | Müşteri numarası |
| `category_1`, `category_2`, `category_3` | STRING | Ürün kategorisi (3 seviye) |
| `code` | STRING | Ürün kodu |
| `promo_name` | STRING | Uygulanan promosyonun adı |
| `turnover_before_promo` | FLOAT | Promosyon öncesi tutar (brüt) |
| `turnover` | FLOAT | Promosyon sonrası tutar (net) |
| `purchase_cost` | FLOAT | Ürünün alış maliyeti |
| `qty` | INTEGER | Adet |

### Tablo yapısı hakkında not

Bir satır bir siparişi değil, **sipariş içindeki bir ürün satırını** temsil
ediyor. Toplam 1.486.388 satıra karşılık 178.974 farklı `orders_id` var; yani
sipariş başına ortalama ~8,3 ürün satırı düşüyor. Sipariş bazlı bir analiz
yapılacaksa önce `orders_id` üzerinden gruplama gerekir.

## Analiz Soruları

- **Günlük ciro nasıl değişiyor?**
  `date_date` bazında `turnover` toplanarak günlük net ciro serisi çıkarıldı.

- **Günlük satın alma maliyeti ne kadar?**
  Satış müdürünün talebi üzerine `purchase_cost` toplamı da sorguya eklendi.
  Ciro ile maliyet yan yana durduğu için günlük brüt kâr farkından
  hesaplanabilir.

## Bulgular

- Ciro hesabında `turnover` (promosyon sonrası net tutar) kullanıldı.
  `turnover_before_promo` brüt tutarı verdiği için kasaya giren parayı
  yansıtmıyor. İkisinin farkı promosyonların maliyetini gösteriyor — ayrı bir
  analiz konusu.

- `turnover` FLOAT tipinde olduğu için 1,4 milyon satırlık toplamda kayan
  nokta hataları birikiyor (ör. `90202.789999999528`). `ROUND` toplamdan
  **sonra** uygulandı; satır bazında yuvarlamak hatayı büyütürdü.

## Dosyalar

| Dosya | İçerik |
|---|---|
| `gwz_sales.sql` | Günlük ciro ve satın alma maliyeti (`date_date` bazında, en yeni tarih önce) |

## Çalışma Yöntemi

Değişiklikler doğrudan `main` üzerinde değil, feature dalları açılarak yapıldı:

- `main` — çalışır durumdaki sürüm
- `develop` — değişikliklerin biriktiği hazırlık dalı
- Feature dalları (`add_purchase_cost`, `sort_dates`) — tek bir değişiklik içerir

Akış: feature dalı aç → düzenle → commit → push → pull request → merge.
Merge sonrası feature dalları hem yerelde hem uzakta silindi.

Proje yönergesi GitHub Desktop kullanımını öneriyor; Linux kullandığım için
tüm Git işlemlerini Git CLI ve VS Code'un Source Control paneli ile yaptım.