# Builds Food_Nutrition_Reference_Expanded.xlsx from the original
# Food Nutrition Reference schema, expanded to ~500 foods.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$outXlsx = Join-Path $root "Food_Nutrition_Reference_Expanded.xlsx"
$outCsv = Join-Path $root "Food_Nutrition_Reference_Expanded.csv"

function Pct([double]$g, [double]$kcalPerG, [double]$cal) {
  if ($cal -le 0) { return 0 }
  return [math]::Round(100.0 * $g * $kcalPerG / $cal, 1)
}

$foods = New-Object System.Collections.Generic.List[object]
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

function Add-Food {
  param($Name, $Serving, $Cal, $P, $F, $C, $Nutrients, $Category)
  if (-not $seen.Add($Name)) { return }
  $cal = [double]$Cal; $p = [double]$P; $f = [double]$F; $c = [double]$C
  $foods.Add([pscustomobject]@{
    Name = $Name
    Serving = $Serving
    Calories = [math]::Round($cal, 0)
    Protein = [math]::Round($p, 1)
    Fat = [math]::Round($f, 1)
    Carbs = [math]::Round($c, 1)
    PctProtein = (Pct $p 4 $cal)
    PctFat = (Pct $f 9 $cal)
    PctCarbs = (Pct $c 4 $cal)
    Nutrients = $Nutrients
    Category = $Category
  })
}

# Original 67 from the template tab
$orig = Import-Csv -LiteralPath (Join-Path $root "notion-import\Notion_Food_Nutrition_Reference.csv")
foreach ($r in $orig) {
  Add-Food $r.Name $r."Typical Serving" $r.Calories $r."Protein (g)" $r."Fat (g)" $r."Carbs (g)" $r."Top Nutrients" $r.Category
}

# Extra foods: Name|Serving|Cal|P|F|C|Nutrients|Category
$extra = @'
Chicken drumstick (skin-on, roasted)|1 drumstick ~100 g cooked|216|27.0|11.2|0|Niacin, Selenium, Vitamin B6, Phosphorus, Zinc|Protein
Chicken wing (roasted)|100 g cooked|203|30.5|8.1|0|Niacin, Selenium, Phosphorus, Vitamin B6, Zinc|Protein
Ground chicken (cooked)|100 g|189|27.0|8.2|0|Niacin, Selenium, Vitamin B6, Phosphorus, Zinc|Protein
Rotisserie chicken (mixed meat)|100 g|190|22.0|10.0|0|Niacin, Selenium, Vitamin B6, Phosphorus, Protein|Protein
Chicken liver (cooked)|100 g|167|24.5|6.5|1.0|Vitamin A, Folate, Iron, B12, Choline|Protein
Duck breast (roasted, skin on)|100 g|201|23.5|11.2|0|Iron, Selenium, Niacin, B12, Phosphorus|Protein
Turkey thigh (roasted)|100 g|187|27.7|8.3|0|Selenium, Niacin, Zinc, Phosphorus, B6|Protein
Ground turkey 93% lean (cooked)|100 g|150|29.0|3.5|0|Selenium, Niacin, B6, Phosphorus, Zinc|Protein
Turkey sausage (cooked)|100 g|196|22.0|11.0|1.0|Protein, Selenium, Sodium, Phosphorus, Zinc|Protein
Beef tenderloin (grilled)|100 g|227|29.0|12.0|0|Zinc, B12, Selenium, Niacin, Iron|Protein
NY strip steak (grilled)|100 g|247|28.0|14.0|0|Zinc, B12, Selenium, Niacin, Iron|Protein
T-bone steak (grilled)|100 g|247|24.0|16.0|0|Zinc, B12, Selenium, Niacin, Iron|Protein
Flank steak (grilled)|100 g|192|28.0|8.2|0|Zinc, B12, Selenium, Niacin, Iron|Protein
Skirt steak (grilled)|100 g|220|26.0|12.0|0|Zinc, B12, Iron, Selenium, Niacin|Protein
Chuck roast (braised)|100 g|250|26.0|16.0|0|Zinc, B12, Iron, Selenium, Niacin|Protein
Brisket (braised)|100 g|289|25.0|21.0|0|Zinc, B12, Iron, Selenium, Niacin|Protein
Short ribs (braised)|100 g|273|27.0|18.0|0|Zinc, B12, Iron, Selenium, Niacin|Protein
Ground beef 90/10 (cooked)|100 g|217|26.0|12.0|0|Zinc, B12, Iron, Selenium, Niacin|Protein
Ground beef 93/7 (cooked)|100 g|182|25.0|8.0|0|Zinc, B12, Iron, Selenium, Niacin|Protein
Beef liver (pan-fried)|100 g|175|27.0|5.0|4.0|Vitamin A, B12, Iron, Copper, Folate|Protein
Beef heart (cooked)|100 g|165|28.0|6.0|0|B12, Iron, Zinc, Selenium, Riboflavin|Protein
Corned beef (cooked)|100 g|251|18.0|19.0|0.5|Sodium, Zinc, B12, Iron, Selenium|Protein
Pastrami (sliced)|100 g|146|21.0|6.0|0.5|Protein, Sodium, Zinc, B12, Iron|Protein
Roast beef (deli)|100 g|115|19.0|4.0|0.5|Protein, Zinc, B12, Sodium, Iron|Protein
Beef jerky|28 g (1 oz)|116|9.4|7.3|3.1|Protein, Zinc, Iron, Sodium, Phosphorus|Protein
Bison (ground, cooked)|100 g|179|25.0|9.0|0|Iron, Zinc, B12, Selenium, Protein|Protein
Venison (roasted)|100 g|158|30.0|3.2|0|Iron, B12, Protein, Niacin, Zinc|Protein
Elk (roasted)|100 g|146|30.0|1.9|0|Iron, Protein, B12, Niacin, Zinc|Protein
Pork tenderloin (roasted)|100 g|143|26.0|3.5|0|Thiamin, Selenium, B6, Niacin, Zinc|Protein
Pork shoulder (roasted)|100 g|292|23.0|22.0|0|Thiamin, Selenium, Zinc, Niacin, B6|Protein
Pork loin (roasted)|100 g|201|27.0|9.5|0|Thiamin, Selenium, Niacin, B6, Zinc|Protein
Pork sausage (cooked)|100 g|325|19.0|27.0|1.4|Thiamin, Selenium, Sodium, Fat, Protein|Protein
Italian sausage (cooked)|100 g|346|14.0|31.0|4.0|Thiamin, Sodium, Fat, Protein, Selenium|Protein
Chorizo (cooked)|100 g|455|24.0|38.0|1.9|Fat, Protein, Sodium, Iron, Zinc|Protein
Ham (sliced, extra lean)|100 g|145|21.0|6.0|1.5|Protein, Sodium, Thiamin, Selenium, Phosphorus|Protein
Canadian bacon|100 g|185|20.0|8.5|1.3|Protein, Sodium, Thiamin, Selenium, Phosphorus|Protein
Pork belly (cooked)|100 g|518|9.0|53.0|0|Fat, Thiamin, Selenium, Sodium, Protein|Protein
Baby back ribs (cooked)|100 g|292|24.0|21.0|0|Protein, Fat, Zinc, Selenium, B12|Protein
Prosciutto|28 g (1 oz)|70|8.0|4.2|0|Protein, Sodium, Zinc, B12, Phosphorus|Protein
Salami|28 g (1 oz)|119|6.4|10.4|0.3|Fat, Sodium, Protein, Zinc, B12|Protein
Pepperoni|28 g (1 oz)|138|5.4|13.0|1.0|Fat, Sodium, Protein, Zinc, Iron|Protein
Lamb leg (roasted)|100 g|258|25.0|17.0|0|B12, Zinc, Selenium, Niacin, Iron|Protein
Rack of lamb (roasted)|100 g|290|24.0|21.0|0|B12, Zinc, Selenium, Niacin, Iron|Protein
Lamb shoulder (braised)|100 g|276|25.0|19.0|0|B12, Zinc, Selenium, Niacin, Iron|Protein
Goat (roasted)|100 g|143|27.0|3.0|0|Iron, Protein, B12, Potassium, Zinc|Protein
Rabbit (stewed)|100 g|173|33.0|3.5|0|Protein, B12, Niacin, Phosphorus, Iron|Protein
Duck egg|1 large (~70 g)|130|9.0|9.6|1.0|Choline, B12, Selenium, Vitamin A, Fat|Protein
Egg whites|100 g|52|11.0|0.2|0.7|Protein, Riboflavin, Potassium, Selenium|Protein
Egg yolk|1 large (~17 g)|55|2.7|4.5|0.6|Choline, Vitamin A, D, B12, Selenium|Protein
Quail eggs|3 eggs (~27 g)|42|3.5|3.0|0.1|Choline, B12, Selenium, Iron, Vitamin A|Protein
Trout (cooked)|100 g|190|23.0|10.0|0|Omega-3, B12, Selenium, Niacin, Phosphorus|Protein
Rainbow trout (cooked)|100 g|168|24.0|7.0|0|Omega-3, B12, Selenium, Niacin, Phosphorus|Protein
Halibut (cooked)|100 g|140|27.0|2.9|0|Selenium, B12, Niacin, Phosphorus, Magnesium|Protein
Haddock (cooked)|100 g|90|20.0|0.6|0|Selenium, B12, Phosphorus, Iodine, Protein|Protein
Tilapia (cooked)|100 g|128|26.0|2.7|0|Selenium, B12, Niacin, Phosphorus, Protein|Protein
Catfish (cooked)|100 g|144|18.0|7.0|0|B12, Phosphorus, Selenium, Niacin, Protein|Protein
Sea bass (cooked)|100 g|124|24.0|2.6|0|Selenium, B12, Phosphorus, Protein, Niacin|Protein
Red snapper (cooked)|100 g|128|26.0|1.7|0|Selenium, B12, Potassium, Protein, Niacin|Protein
Mahi-mahi (cooked)|100 g|109|24.0|0.9|0|Selenium, B12, Niacin, Potassium, Protein|Protein
Swordfish (cooked)|100 g|172|23.0|8.0|0|Selenium, B12, Omega-3, Niacin, Phosphorus|Protein
Anchovies (canned in oil, drained)|28 g (1 oz)|60|8.0|2.8|0|Omega-3, Calcium, Niacin, Selenium, Sodium|Protein
Herring (cooked)|100 g|203|23.0|12.0|0|Omega-3, D, B12, Selenium, Niacin|Protein
Smoked salmon|100 g|117|18.0|4.3|0|Omega-3, B12, Sodium, Selenium, Vitamin D|Protein
Smoked trout|100 g|132|21.0|5.0|0|Omega-3, B12, Sodium, Selenium, Niacin|Protein
Crab (cooked)|100 g|87|18.0|1.1|0|B12, Selenium, Copper, Zinc, Protein|Protein
Lobster (cooked)|100 g|89|19.0|0.9|0.5|Copper, Selenium, B12, Zinc, Protein|Protein
Scallops (cooked)|100 g|111|20.0|0.8|5.4|B12, Phosphorus, Selenium, Protein, Magnesium|Protein
Mussels (cooked)|100 g|86|12.0|2.2|7.4|B12, Manganese, Iron, Selenium, Omega-3|Protein
Clams (cooked)|100 g|86|15.0|1.0|3.0|B12, Iron, Selenium, Manganese, Protein|Protein
Oysters (cooked)|100 g|81|9.0|2.3|4.9|Zinc, B12, Copper, Iron, Selenium|Protein
Crawfish (cooked)|100 g|82|17.0|1.0|0|Protein, Selenium, B12, Phosphorus, Copper|Protein
Squid (cooked)|100 g|92|16.0|1.4|3.1|Copper, Selenium, B12, Phosphorus, Protein|Protein
Octopus (cooked)|100 g|82|15.0|1.0|2.2|B12, Iron, Selenium, Copper, Protein|Protein
Collagen peptides|1 scoop (10 g)|35|9.0|0|0|Glycine, Proline, Hydroxyproline, Protein|Protein
Whey protein isolate|1 scoop (30 g)|110|25.0|0.5|1.0|Complete protein, BCAAs, Calcium, Leucine|Protein
Casein protein|1 scoop (30 g)|120|24.0|1.0|3.0|Slow-digesting protein, Calcium, Phosphorus|Protein
Tofu (firm)|100 g|144|17.0|9.0|3.0|Calcium, Iron, Isoflavones, Protein, Manganese|Protein
Tempeh|100 g|193|19.0|11.0|9.0|Protein, Fiber, Probiotics, Iron, Magnesium|Protein
Edamame (shelled, cooked)|100 g|121|12.0|5.0|9.0|Folate, Protein, Fiber, Vitamin K, Manganese|Protein
Turkey bacon (cooked)|2 slices (~16 g)|70|4.0|5.0|0.5|Protein, Sodium, Selenium, Phosphorus|Protein
Chicken sausage|100 g|172|18.0|10.0|2.0|Protein, Sodium, Niacin, Selenium, Phosphorus|Protein
Ground pork (cooked)|100 g|297|26.0|21.0|0|Thiamin, Selenium, Zinc, B12, Niacin|Protein
Beef tongue (cooked)|100 g|284|19.0|22.0|0|B12, Zinc, Iron, Choline, Fat|Protein
Kielbasa|100 g|309|12.0|27.0|2.2|Fat, Sodium, Protein, Selenium, Zinc|Protein
Hot dog (beef)|1 frank (~45 g)|150|5.0|13.0|2.0|Sodium, Fat, Protein, Zinc, B12|Protein
Canned chicken|100 g|165|25.0|7.0|0|Protein, Niacin, Selenium, Phosphorus, Sodium|Protein
Canned salmon|100 g|136|20.0|5.5|0|Omega-3, Calcium (with bones), D, B12, Selenium|Protein
Avocado oil|1 Tbsp (14 g)|124|0|14.0|0|Monounsaturated fat, Vitamin E, Heat-stable fat|Healthy Fat
Sesame oil|1 Tbsp (14 g)|120|0|13.6|0|Sesame lignans, Vitamin E, Unsaturated fat|Healthy Fat
Walnut oil|1 Tbsp (14 g)|120|0|13.6|0|Omega-3 (ALA), Vitamin E, Unsaturated fat|Healthy Fat
Flaxseed oil|1 Tbsp (14 g)|120|0|13.6|0|Omega-3 (ALA), Unsaturated fat|Healthy Fat
Lard (pork fat)|1 Tbsp (13 g)|115|0|13.0|0|Monounsaturated fat, Saturated fat, Vitamin D (small)|Healthy Fat
Beef tallow|1 Tbsp (13 g)|115|0|13.0|0|Saturated fat, Stearic acid, Fat-soluble vitamins|Healthy Fat
Duck fat|1 Tbsp (13 g)|115|0|13.0|0|Monounsaturated fat, Saturated fat, Flavor compounds|Healthy Fat
Bacon grease|1 Tbsp (13 g)|116|0|13.0|0|Saturated & monounsaturated fat, Sodium (small)|Healthy Fat
Coconut cream|2 Tbsp (30 g)|100|1.0|10.0|2.0|MCTs, Lauric acid, Saturated fat|Healthy Fat
Pesto (basil)|2 Tbsp (30 g)|160|3.0|15.0|3.0|Monounsaturated fat, Vitamin K, Calcium, Vitamin E|Healthy Fat
Tahini|1 Tbsp (15 g)|89|3.0|8.0|3.0|Copper, Manganese, Calcium, Healthy fats|Healthy Fat
Ranch dressing (full-fat)|2 Tbsp (30 g)|140|1.0|14.0|2.0|Fat, Sodium, Vitamin K (small)|Healthy Fat
Caesar dressing|2 Tbsp (30 g)|160|1.0|17.0|1.0|Fat, Sodium, Anchovy umami|Healthy Fat
Olive-oil vinaigrette|2 Tbsp (30 g)|140|0|15.0|1.0|Monounsaturated fat, Polyphenols, Vitamin E|Healthy Fat
Guacamole|2 Tbsp (30 g)|50|0.6|4.5|2.8|Potassium, Fiber, Monounsaturated fat, Folate|Healthy Fat
Olives (Kalamata)|10 olives (~30 g)|60|0.4|6.0|1.5|Monounsaturated fat, Polyphenols, Sodium, Vitamin E|Healthy Fat
Cocoa butter|1 Tbsp (14 g)|120|0|14.0|0|Saturated fat, Stearic acid, Cocoa compounds|Healthy Fat
Macadamia oil|1 Tbsp (14 g)|120|0|14.0|0|Monounsaturated fat, Palmitoleic acid, Vitamin E|Healthy Fat
Mozzarella (whole milk)|28 g (1 oz)|85|6.3|6.3|0.6|Calcium, Protein, Phosphorus, B12, Vitamin A|Dairy
Fresh mozzarella|28 g (1 oz)|70|5.0|5.0|0.5|Calcium, Protein, Phosphorus, B12|Dairy
Swiss cheese|28 g (1 oz)|111|8.0|9.0|0.4|Calcium, Protein, B12, Phosphorus, Vitamin A|Dairy
Gouda|28 g (1 oz)|101|7.0|8.0|0.6|Calcium, Protein, Phosphorus, B12, Vitamin A|Dairy
Brie|28 g (1 oz)|95|6.0|8.0|0.1|Vitamin A, Protein, Calcium, B12, Fat|Dairy
Camembert|28 g (1 oz)|85|6.0|7.0|0.1|Vitamin A, Protein, Calcium, B12, Fat|Dairy
Goat cheese (chevre)|28 g (1 oz)|76|5.0|6.0|0.3|Protein, Calcium, Vitamin A, Copper, Phosphorus|Dairy
Ricotta (whole milk)|100 g|174|11.0|13.0|3.0|Calcium, Protein, Selenium, Phosphorus, B12|Dairy
Provolone|28 g (1 oz)|98|7.0|7.5|0.6|Calcium, Protein, Phosphorus, B12, Vitamin A|Dairy
Muenster|28 g (1 oz)|104|6.6|8.5|0.3|Calcium, Protein, Vitamin A, Phosphorus, B12|Dairy
Colby Jack|28 g (1 oz)|110|6.8|9.0|0.7|Calcium, Protein, Vitamin A, Phosphorus, B12|Dairy
Pepper Jack|28 g (1 oz)|110|7.0|9.0|0.4|Calcium, Protein, Vitamin A, Phosphorus, B12|Dairy
Halloumi|28 g (1 oz)|90|6.0|7.0|0.5|Calcium, Protein, Sodium, Phosphorus, B12|Dairy
Manchego|28 g (1 oz)|110|7.0|9.0|0.4|Calcium, Protein, Phosphorus, Vitamin A, B12|Dairy
Pecorino Romano|28 g (1 oz)|110|8.0|8.0|1.0|Calcium, Protein, Sodium, Phosphorus, B12|Dairy
String cheese|1 stick (28 g)|80|7.0|6.0|1.0|Calcium, Protein, Phosphorus, B12|Dairy
Whole milk|1 cup (244 g)|149|8.0|8.0|12.0|Calcium, B12, Riboflavin, Phosphorus, Vitamin D (if fortified)|Dairy
2% milk|1 cup (244 g)|122|8.0|5.0|12.0|Calcium, B12, Riboflavin, Phosphorus, Protein|Dairy
Skim milk|1 cup (245 g)|83|8.0|0.2|12.0|Calcium, B12, Riboflavin, Protein, Phosphorus|Dairy
Kefir (plain, whole)|1 cup (243 g)|160|9.0|8.0|12.0|Probiotics, Calcium, Protein, B12, Phosphorus|Dairy
Plain yogurt (whole)|170 g (6 oz)|138|8.0|7.0|11.0|Calcium, Probiotics, Protein, B12, Phosphorus|Dairy
Mascarpone|2 Tbsp (28 g)|120|2.0|12.0|1.0|Fat, Vitamin A, Calcium (small)|Dairy
Quark|100 g|67|12.0|0.2|4.0|Protein, Calcium, Phosphorus, B12, Riboflavin|Dairy
Paneer|28 g (1 oz)|90|6.0|7.0|1.0|Protein, Calcium, Fat, Phosphorus|Dairy
Half-and-half|2 Tbsp (30 g)|40|1.0|3.5|1.0|Fat, Vitamin A, Calcium (small)|Dairy
Whipped cream|2 Tbsp (10 g)|26|0.3|2.6|0.4|Fat, Vitamin A|Dairy
Buttermilk|1 cup (245 g)|98|8.0|2.2|12.0|Calcium, Protein, Riboflavin, Phosphorus, B12|Dairy
Evaporated milk|2 Tbsp (32 g)|42|2.0|2.4|3.2|Calcium, Protein, Phosphorus, B12|Dairy
American cheese|1 slice (21 g)|70|4.0|5.5|1.5|Calcium, Sodium, Protein, Vitamin A, Phosphorus|Dairy
Asiago|28 g (1 oz)|110|8.0|8.0|1.0|Calcium, Protein, Phosphorus, B12|Dairy
Havarti|28 g (1 oz)|110|6.0|9.0|0.4|Calcium, Protein, Vitamin A, Phosphorus, Fat|Dairy
Gruyere|28 g (1 oz)|117|8.0|9.0|0.1|Calcium, Protein, Phosphorus, B12, Vitamin A|Dairy
Cashews|28 g (1 oz)|157|5.2|12.4|8.6|Copper, Magnesium, Manganese, Phosphorus, Healthy fats|Nuts & Seeds
Pistachios|28 g (1 oz)|159|6.0|12.9|8.0|B6, Copper, Manganese, Thiamin, Fiber|Nuts & Seeds
Hazelnuts|28 g (1 oz)|178|4.2|17.2|4.7|Vitamin E, Manganese, Copper, Magnesium, Healthy fats|Nuts & Seeds
Brazil nuts|28 g (1 oz / ~6 nuts)|187|4.1|19.0|3.5|Selenium (very high), Magnesium, Copper, Thiamin, Healthy fats|Nuts & Seeds
Peanuts (dry roasted)|28 g (1 oz)|166|6.9|14.1|6.1|Niacin, Folate, Manganese, Protein, Healthy fats|Nuts & Seeds
Peanut butter (no sugar)|2 Tbsp (32 g)|190|7.0|16.0|7.0|Niacin, Magnesium, Protein, Healthy fats, Vitamin E|Nuts & Seeds
Sunflower seeds (hulled)|28 g (1 oz)|165|5.5|14.1|6.8|Vitamin E, Selenium, Copper, Manganese, Healthy fats|Nuts & Seeds
Pumpkin seeds (pepitas)|28 g (1 oz)|158|8.5|13.9|3.0|Magnesium, Zinc, Iron, Protein, Healthy fats|Nuts & Seeds
Flaxseed (ground)|2 Tbsp (14 g)|75|2.6|6.0|4.0|Omega-3 (ALA), Fiber, Lignans, Magnesium, Thiamin|Nuts & Seeds
Poppy seeds|1 Tbsp (9 g)|46|1.6|3.7|2.5|Calcium, Manganese, Copper, Magnesium, Fiber|Nuts & Seeds
Coconut flakes (unsweetened)|28 g (1 oz)|187|2.0|18.0|7.0|MCTs, Fiber, Manganese, Copper, Healthy fats|Nuts & Seeds
Chestnuts (roasted)|28 g (1 oz)|70|0.9|0.6|15.0|Vitamin C, Folate, Manganese, Fiber, Copper|Nuts & Seeds
Cashew butter|2 Tbsp (32 g)|190|5.0|16.0|9.0|Copper, Magnesium, Healthy fats, Phosphorus|Nuts & Seeds
Sunflower seed butter|2 Tbsp (32 g)|200|5.5|16.0|8.0|Vitamin E, Magnesium, Healthy fats, Protein|Nuts & Seeds
Pecan butter|2 Tbsp (32 g)|210|3.0|21.0|4.0|Manganese, Copper, Healthy fats, Thiamin|Nuts & Seeds
Macadamia butter|2 Tbsp (32 g)|230|2.5|24.0|4.0|Monounsaturated fat, Manganese, Thiamin, Copper|Nuts & Seeds
Walnut halves extra|14 halves (28 g)|185|4.3|18.5|3.9|ALA omega-3, Manganese, Copper, Magnesium, Polyphenols|Nuts & Seeds
Hemp hearts extra|3 Tbsp (30 g)|166|9.5|14.6|2.6|Complete protein, Magnesium, Iron, Zinc, Omega-3 & 6|Nuts & Seeds
Chia pudding base (dry chia)|2 Tbsp (24 g)|116|4.0|7.4|10.0|Fiber, ALA, Calcium, Magnesium, Phosphorus|Nuts & Seeds
Sesame tahini extra|2 Tbsp (30 g)|178|5.0|16.0|6.0|Copper, Manganese, Calcium, Iron, Healthy fats|Nuts & Seeds
Pine nuts extra|2 Tbsp (18 g)|120|2.5|12.0|2.4|Manganese, Vitamin E, Magnesium, Zinc, Healthy fats|Nuts & Seeds
Watermelon seeds|28 g (1 oz)|158|8.0|13.0|4.0|Magnesium, Zinc, Iron, Protein, Healthy fats|Nuts & Seeds
Beet greens (cooked)|100 g|27|2.6|0.2|5.5|Vitamin K, Vitamin A, Potassium, Magnesium, Folate|Vegetable
Bok choy (cooked)|100 g|12|1.6|0.2|1.8|Vitamin A, C, K, Folate, Calcium|Vegetable
Broccolini (cooked)|100 g|35|3.0|0.4|6.0|Vitamin C, K, Folate, Fiber, Potassium|Vegetable
Broccoli rabe (cooked)|100 g|33|4.0|0.5|3.0|Vitamin K, A, C, Folate, Calcium|Vegetable
Napa cabbage (raw)|100 g|16|1.2|0.2|3.2|Vitamin C, K, Folate, Fiber|Vegetable
Red cabbage (raw)|100 g|31|1.4|0.2|7.4|Vitamin C, K, Anthocyanins, Fiber, Folate|Vegetable
Savoy cabbage (cooked)|100 g|24|1.8|0.1|5.4|Vitamin K, C, Folate, Fiber|Vegetable
Carrot (raw)|1 medium (61 g)|25|0.6|0.1|6.0|Vitamin A, Biotin, Fiber, Potassium, Vitamin K|Vegetable
Carrot (cooked)|100 g|35|0.8|0.2|8.2|Vitamin A, Fiber, Potassium, Biotin, Vitamin K|Vegetable
Cauliflower rice (cooked)|100 g|25|2.0|0.3|5.0|Vitamin C, K, Folate, Fiber, Choline|Vegetable
Chard (cooked)|100 g|20|1.9|0.1|4.1|Vitamin K, A, C, Magnesium, Potassium|Vegetable
Collard greens (cooked)|100 g|33|2.7|0.6|5.6|Vitamin K, A, C, Calcium, Folate|Vegetable
Eggplant (cooked)|100 g|35|0.8|0.2|8.7|Fiber, Manganese, Potassium, B6, Antioxidants|Vegetable
Endive (raw)|100 g|17|1.3|0.2|3.4|Vitamin K, Folate, A, Fiber|Vegetable
Fennel (raw)|100 g|31|1.2|0.2|7.3|Vitamin C, Potassium, Fiber, Folate, Manganese|Vegetable
Garlic (raw)|3 cloves (9 g)|13|0.6|0.0|3.0|Allicin, Manganese, B6, Vitamin C, Selenium|Vegetable
Ginger (raw)|1 Tbsp (6 g)|5|0.1|0.1|1.1|Gingerols, Potassium, Magnesium|Vegetable
Green onion / scallion|100 g|32|1.8|0.2|7.3|Vitamin K, C, A, Folate, Fiber|Vegetable
Jalapeño (raw)|1 pepper (14 g)|4|0.2|0.1|0.9|Vitamin C, Capsaicin, Vitamin A, B6|Vegetable
Leek (cooked)|100 g|31|0.8|0.2|7.6|Vitamin K, A, Manganese, Folate, Fiber|Vegetable
Mustard greens (cooked)|100 g|26|2.6|0.4|4.5|Vitamin K, A, C, Folate, Calcium|Vegetable
Okra (cooked)|100 g|33|1.9|0.2|7.5|Vitamin C, K, Folate, Fiber, Magnesium|Vegetable
Onion (raw)|100 g|40|1.1|0.1|9.3|Vitamin C, B6, Folate, Fiber, Antioxidants|Vegetable
Onion (cooked)|100 g|44|1.4|0.2|10.1|Vitamin C, B6, Folate, Fiber|Vegetable
Parsnip (cooked)|100 g|71|1.3|0.3|17.0|Fiber, Vitamin C, Folate, Manganese, Potassium|Vegetable
Peas (green, cooked)|100 g|84|5.4|0.2|16.0|Vitamin K, C, Folate, Fiber, Protein|Vegetable
Bell pepper (red, raw)|100 g|31|1.0|0.3|6.0|Vitamin C, A, B6, Folate, Antioxidants|Vegetable
Bell pepper (green, raw)|100 g|20|0.9|0.2|4.6|Vitamin C, B6, Folate, Vitamin K|Vegetable
Bell pepper (yellow, raw)|100 g|27|1.0|0.2|6.3|Vitamin C, B6, Folate, Potassium|Vegetable
Pumpkin (cooked)|100 g|20|0.7|0.1|5.0|Vitamin A, C, Potassium, Fiber, Copper|Vegetable
Radish (raw)|100 g|16|0.7|0.1|3.4|Vitamin C, Potassium, Fiber, Folate|Vegetable
Rutabaga (cooked)|100 g|39|1.3|0.2|8.9|Vitamin C, Potassium, Fiber, Folate, Manganese|Vegetable
Spaghetti squash (cooked)|100 g|31|0.6|0.6|7.0|Vitamin C, B6, Fiber, Manganese, Potassium|Vegetable
Summer squash (cooked)|100 g|20|0.9|0.3|4.3|Vitamin C, Manganese, Potassium, Fiber, B6|Vegetable
Sweet potato (baked, with skin)|100 g|90|2.0|0.2|21.0|Vitamin A, C, Potassium, Fiber, B6|Vegetable
White potato (baked, with skin)|100 g|93|2.5|0.1|21.0|Potassium, Vitamin C, B6, Fiber, Magnesium|Vegetable
Turnip (cooked)|100 g|22|0.7|0.1|5.1|Vitamin C, Fiber, Potassium, Folate|Vegetable
Turnip greens (cooked)|100 g|20|1.1|0.2|4.4|Vitamin K, A, C, Folate, Calcium|Vegetable
Watercress (raw)|100 g|11|2.3|0.1|1.3|Vitamin K, A, C, Calcium, Antioxidants|Vegetable
Yellow squash (raw)|100 g|16|1.2|0.2|3.4|Vitamin C, Manganese, Potassium, Fiber|Vegetable
Artichoke (cooked)|1 medium (120 g)|64|3.5|0.4|14.0|Fiber, Folate, Magnesium, Vitamin C, Antioxidants|Vegetable
Artichoke hearts (canned)|100 g|53|2.9|0.2|12.0|Fiber, Folate, Vitamin C, Magnesium, Iron|Vegetable
Beet (cooked)|100 g|44|1.7|0.2|10.0|Folate, Manganese, Potassium, Fiber, Nitrates|Vegetable
Corn (yellow, cooked)|100 g|96|3.4|1.5|21.0|Folate, Thiamin, Fiber, Magnesium, Antioxidants|Vegetable
Jicama (raw)|100 g|38|0.7|0.1|9.0|Vitamin C, Fiber, Potassium, Folate|Vegetable
Kohlrabi (raw)|100 g|27|1.7|0.1|6.2|Vitamin C, Fiber, Potassium, B6, Folate|Vegetable
Radicchio (raw)|100 g|23|1.4|0.3|4.5|Vitamin K, Antioxidants, Folate, Copper|Vegetable
Shallot (raw)|100 g|72|2.5|0.1|17.0|Vitamin B6, C, Manganese, Folate, Fiber|Vegetable
Snow peas (raw)|100 g|42|2.8|0.2|7.6|Vitamin C, K, Folate, Fiber, Iron|Vegetable
Sugar snap peas (raw)|100 g|42|2.8|0.2|7.5|Vitamin C, K, Folate, Fiber, Iron|Vegetable
Tomatillo (raw)|100 g|32|1.0|1.0|5.8|Vitamin C, K, Potassium, Fiber, Niacin|Vegetable
Cherry tomato|100 g|18|0.9|0.2|3.9|Vitamin C, Lycopene, Potassium, Vitamin A|Vegetable
Sun-dried tomato|28 g (1 oz)|72|4.0|0.8|16.0|Potassium, Iron, Lycopene, Fiber, Vitamin C|Vegetable
Kimchi|100 g|15|1.1|0.5|2.4|Probiotics, Vitamin C, K, Fiber, Sodium|Vegetable
Sauerkraut|100 g|19|0.9|0.1|4.3|Probiotics, Vitamin C, K, Fiber, Sodium|Vegetable
Pickle (dill, no sugar)|1 spear (30 g)|4|0.2|0.1|0.8|Sodium, Vitamin K, Probiotics (if fermented)|Vegetable
Alfalfa sprouts|100 g|23|4.0|0.7|2.1|Vitamin K, C, Folate, Protein, Copper|Vegetable
Bean sprouts (mung)|100 g|30|3.0|0.2|5.9|Vitamin C, Folate, Protein, Fiber, K|Vegetable
Dandelion greens (raw)|100 g|45|2.7|0.7|9.2|Vitamin K, A, C, Calcium, Iron|Vegetable
Parsley (raw)|1/2 cup (30 g)|11|0.9|0.2|1.9|Vitamin K, C, A, Folate, Iron|Vegetable
Cilantro (raw)|1/2 cup (8 g)|2|0.2|0.0|0.3|Vitamin K, A, Antioxidants|Vegetable
Basil (fresh)|1/4 cup (6 g)|1|0.2|0.0|0.2|Vitamin K, A, Manganese, Antioxidants|Vegetable
Dill (fresh)|1 Tbsp (1 g)|0|0.0|0.0|0.1|Vitamin A, C, Calcium (small)|Vegetable
Mint (fresh)|2 Tbsp (4 g)|2|0.1|0.0|0.3|Vitamin A, Antioxidants, Menthol compounds|Vegetable
Rosemary (fresh)|1 Tbsp (2 g)|2|0.1|0.1|0.4|Antioxidants, Iron, Calcium (small)|Vegetable
Thyme (fresh)|1 Tbsp (2 g)|2|0.1|0.0|0.5|Vitamin C, Iron, Manganese, Antioxidants|Vegetable
Oregano (dried)|1 tsp (1 g)|3|0.1|0.0|0.7|Antioxidants, Vitamin K, Iron, Calcium|Vegetable
Seaweed (nori)|1 sheet (3 g)|10|1.6|0.1|1.1|Iodine, Vitamin A, C, Folate, Protein|Vegetable
Wakame (rehydrated)|100 g|45|3.0|0.6|9.1|Iodine, Folate, Magnesium, Calcium, Fiber|Vegetable
Kelp (raw)|100 g|43|1.7|0.6|9.6|Iodine, Folate, Calcium, Magnesium, Iron|Vegetable
Hearts of palm|100 g|28|2.5|0.6|4.6|Potassium, Fiber, Copper, Zinc, Iron|Vegetable
Bamboo shoots (canned)|100 g|12|1.5|0.3|2.0|Potassium, Fiber, B6, Copper|Vegetable
Daikon radish (raw)|100 g|18|0.6|0.1|4.1|Vitamin C, Potassium, Fiber, Folate|Vegetable
Lotus root (cooked)|100 g|74|2.6|0.1|17.0|Vitamin C, Fiber, Potassium, B6, Copper|Vegetable
Chayote (cooked)|100 g|24|0.8|0.5|5.1|Vitamin C, Folate, Fiber, Zinc, Potassium|Vegetable
Pattypan squash (cooked)|100 g|18|1.0|0.2|3.9|Vitamin C, Fiber, Manganese, Potassium|Vegetable
Acorn squash (baked)|100 g|56|1.1|0.1|15.0|Vitamin C, A, Potassium, Fiber, Magnesium|Vegetable
Butternut squash (baked)|100 g|45|1.0|0.1|12.0|Vitamin A, C, Potassium, Fiber, Magnesium|Vegetable
Delicata squash (baked)|100 g|40|1.0|0.2|9.0|Vitamin A, C, Potassium, Fiber|Vegetable
Kabocha squash (baked)|100 g|40|1.5|0.1|9.0|Vitamin A, C, Fiber, Potassium, Iron|Vegetable
Fiddlehead ferns (cooked)|100 g|34|4.6|0.4|5.5|Vitamin A, C, Antioxidants, Iron, Manganese|Vegetable
Nopales / cactus (cooked)|100 g|16|1.4|0.1|3.3|Fiber, Vitamin C, Magnesium, Calcium, Antioxidants|Vegetable
Taro leaf (cooked)|100 g|37|3.0|0.7|6.0|Vitamin A, C, Calcium, Iron, Fiber|Vegetable
Cassava / yuca (cooked)|100 g|160|1.4|0.3|38.0|Vitamin C, Potassium, Manganese, Fiber|Vegetable
Plantain (cooked)|100 g|122|1.3|0.2|32.0|Vitamin A, C, Potassium, B6, Fiber|Vegetable
Apple (with skin)|1 medium (182 g)|95|0.5|0.3|25.0|Fiber, Vitamin C, Potassium, Polyphenols|Fruit
Granny Smith apple|1 medium (180 g)|94|0.5|0.3|24.0|Fiber, Vitamin C, Polyphenols, Potassium|Fruit
Banana|1 medium (118 g)|105|1.3|0.4|27.0|Potassium, Vitamin B6, Vitamin C, Fiber, Manganese|Fruit
Blueberries|1 cup (148 g)|84|1.1|0.5|21.0|Vitamin C, K, Manganese, Fiber, Anthocyanins|Fruit
Strawberries|1 cup (152 g)|49|1.0|0.5|12.0|Vitamin C, Manganese, Folate, Fiber, Antioxidants|Fruit
Raspberries|1 cup (123 g)|64|1.5|0.8|15.0|Fiber, Vitamin C, Manganese, K, Antioxidants|Fruit
Blackberries|1 cup (144 g)|62|2.0|0.7|14.0|Vitamin C, K, Fiber, Manganese, Antioxidants|Fruit
Cranberries (raw)|1 cup (100 g)|46|0.4|0.1|12.0|Vitamin C, Fiber, Manganese, Antioxidants|Fruit
Cherries|1 cup (154 g)|97|1.6|0.3|25.0|Vitamin C, Potassium, Fiber, Antioxidants|Fruit
Grapes (red)|1 cup (151 g)|104|1.1|0.2|27.0|Vitamin K, C, Potassium, Polyphenols|Fruit
Orange|1 medium (131 g)|62|1.2|0.2|15.0|Vitamin C, Folate, Potassium, Fiber, Thiamin|Fruit
Clementine|1 fruit (74 g)|35|0.6|0.1|9.0|Vitamin C, Folate, Potassium, Fiber|Fruit
Grapefruit (pink)|1/2 fruit (123 g)|52|0.9|0.2|13.0|Vitamin C, A, Fiber, Potassium, Lycopene|Fruit
Lemon (juice)|1 lemon (48 g juice)|12|0.2|0.1|4.0|Vitamin C, Citric acid, Potassium|Fruit
Lime (juice)|1 lime (30 g juice)|8|0.1|0.0|2.8|Vitamin C, Citric acid, Potassium|Fruit
Kiwi|1 medium (69 g)|42|0.8|0.4|10.0|Vitamin C, K, Fiber, Potassium, Folate|Fruit
Mango|1 cup (165 g)|99|1.4|0.6|25.0|Vitamin C, A, Folate, Fiber, Copper|Fruit
Pineapple|1 cup (165 g)|82|0.9|0.2|22.0|Vitamin C, Manganese, B6, Fiber, Copper|Fruit
Papaya|1 cup (145 g)|62|0.7|0.4|16.0|Vitamin C, A, Folate, Fiber, Potassium|Fruit
Watermelon|1 cup (152 g)|46|0.9|0.2|12.0|Vitamin C, A, Lycopene, Potassium, Hydration|Fruit
Cantaloupe|1 cup (160 g)|54|1.3|0.3|13.0|Vitamin A, C, Potassium, Folate, Hydration|Fruit
Honeydew|1 cup (177 g)|64|1.0|0.2|16.0|Vitamin C, Potassium, Folate, Hydration|Fruit
Peach|1 medium (150 g)|59|1.4|0.4|14.0|Vitamin C, A, Fiber, Potassium, Niacin|Fruit
Nectarine|1 medium (142 g)|62|1.5|0.5|15.0|Vitamin C, A, Fiber, Potassium, Niacin|Fruit
Plum|1 fruit (66 g)|30|0.5|0.2|8.0|Vitamin C, K, Potassium, Fiber, Antioxidants|Fruit
Apricot|1 fruit (35 g)|17|0.5|0.1|4.0|Vitamin A, C, Potassium, Fiber|Fruit
Pear|1 medium (178 g)|101|0.6|0.2|27.0|Fiber, Vitamin C, K, Potassium, Copper|Fruit
Avocado extra (whole)|1 medium (136 g edible)|227|2.7|21.0|12.0|Monounsaturated fat, Fiber, Potassium, Folate, Vitamin K|Fruit
Coconut meat (fresh)|1 oz (28 g)|99|0.9|9.4|4.3|MCTs, Fiber, Manganese, Copper, Selenium|Fruit
Dates (Medjool)|1 date (24 g)|66|0.4|0.0|18.0|Potassium, Copper, Fiber, Magnesium, B6|Fruit
Figs (fresh)|1 medium (50 g)|37|0.4|0.2|10.0|Fiber, Potassium, Calcium, Magnesium, Vitamin K|Fruit
Prunes|5 prunes (42 g)|100|1.0|0.1|26.0|Fiber, Potassium, Vitamin K, Copper, Antioxidants|Fruit
Raisins|1 oz (28 g)|85|0.9|0.1|22.0|Potassium, Copper, Iron, Fiber, B6|Fruit
Pomegranate arils|1/2 cup (87 g)|72|1.5|1.0|16.0|Vitamin C, K, Folate, Fiber, Polyphenols|Fruit
Passion fruit|1 fruit (18 g pulp)|17|0.4|0.1|4.2|Vitamin C, Fiber, A, Potassium|Fruit
Guava|1 fruit (55 g)|37|1.4|0.5|8.0|Vitamin C, Fiber, Folate, Potassium, Lycopene|Fruit
Lychee|10 fruits (96 g)|66|0.8|0.4|17.0|Vitamin C, Copper, Potassium, Fiber, B6|Fruit
Starfruit|1 medium (91 g)|28|1.0|0.3|6.0|Vitamin C, Fiber, Potassium, Antioxidants|Fruit
Dragon fruit|1 cup (227 g)|136|3.0|0.4|29.0|Fiber, Vitamin C, Iron, Magnesium, Antioxidants|Fruit
Persimmon|1 fruit (168 g)|118|1.0|0.3|31.0|Vitamin A, C, Fiber, Manganese, Antioxidants|Fruit
Black currants|1 cup (112 g)|71|1.6|0.5|17.0|Vitamin C, Antioxidants, Potassium, Fiber|Fruit
Gooseberries|1 cup (150 g)|66|1.3|0.9|15.0|Vitamin C, Fiber, Manganese, Potassium|Fruit
Mulberries|1 cup (140 g)|60|2.0|0.5|14.0|Vitamin C, Iron, Fiber, K, Antioxidants|Fruit
Acai puree (unsweetened)|100 g|70|2.0|5.0|4.0|Anthocyanins, Fiber, Vitamin A, Healthy fats|Fruit
Lemon zest|1 Tbsp (6 g)|3|0.1|0.0|1.0|Vitamin C, Flavonoids, Aromatic oils|Fruit
Black beans (cooked)|100 g|132|8.9|0.5|24.0|Fiber, Folate, Manganese, Magnesium, Iron|Legume
Pinto beans (cooked)|100 g|143|9.0|0.7|26.0|Fiber, Folate, Manganese, Potassium, Iron|Legume
Kidney beans (cooked)|100 g|127|8.7|0.5|23.0|Fiber, Folate, Manganese, Iron, Potassium|Legume
Navy beans (cooked)|100 g|140|8.2|0.6|26.0|Fiber, Folate, Manganese, Magnesium, Iron|Legume
Cannellini beans (cooked)|100 g|139|9.7|0.4|25.0|Fiber, Folate, Iron, Magnesium, Potassium|Legume
Garbanzo beans / chickpeas (cooked)|100 g|164|8.9|2.6|27.0|Folate, Fiber, Manganese, Iron, Protein|Legume
Lentils (cooked)|100 g|116|9.0|0.4|20.0|Folate, Fiber, Iron, Manganese, Protein|Legume
Red lentils (cooked)|100 g|116|9.0|0.4|20.0|Folate, Fiber, Iron, Manganese, Protein|Legume
Green lentils (cooked)|100 g|116|9.0|0.4|20.0|Folate, Fiber, Iron, Manganese, Protein|Legume
Split peas (cooked)|100 g|118|8.3|0.4|21.0|Fiber, Folate, Manganese, Protein, Potassium|Legume
Black-eyed peas (cooked)|100 g|116|7.7|0.5|21.0|Folate, Fiber, Iron, Potassium, Protein|Legume
Lima beans (cooked)|100 g|115|7.8|0.4|21.0|Fiber, Folate, Manganese, Potassium, Iron|Legume
Soybeans (cooked)|100 g|173|16.6|9.0|10.0|Complete protein, Iron, Folate, Magnesium, Fiber|Legume
Hummus|2 Tbsp (30 g)|70|2.0|5.0|6.0|Fiber, Iron, Folate, Healthy fats, Protein|Legume
Refried beans|100 g|91|5.4|2.0|14.0|Fiber, Folate, Iron, Potassium, Protein|Legume
Baked beans (canned)|100 g|94|4.8|0.4|21.0|Fiber, Folate, Iron, Sodium, Protein|Legume
Mung beans (cooked)|100 g|105|7.0|0.4|19.0|Folate, Fiber, Magnesium, Potassium, Protein|Legume
Adzuki beans (cooked)|100 g|128|7.5|0.1|25.0|Fiber, Folate, Manganese, Potassium, Iron|Legume
Fava beans (cooked)|100 g|110|7.6|0.4|19.0|Folate, Fiber, Manganese, Protein, Iron|Legume
Lupini beans (cooked)|100 g|119|16.0|2.4|10.0|Protein, Fiber, Folate, Magnesium, Iron|Legume
Peanuts (boiled)|28 g (1 oz)|90|4.0|6.0|6.0|Protein, Niacin, Folate, Magnesium, Healthy fats|Legume
Brown rice (cooked)|100 g|123|2.7|1.0|26.0|Manganese, Magnesium, B6, Fiber, Selenium|Grain
White rice (cooked)|100 g|130|2.7|0.3|28.0|Manganese, Selenium, B6, Folate, Thiamin|Grain
Wild rice (cooked)|100 g|101|4.0|0.3|21.0|Magnesium, Phosphorus, Zinc, Folate, Fiber|Grain
Quinoa (cooked)|100 g|120|4.4|1.9|21.0|Complete protein, Magnesium, Fiber, Folate, Manganese|Grain
Oats (dry, rolled)|40 g (1/2 cup)|150|5.0|3.0|27.0|Fiber (beta-glucan), Manganese, Phosphorus, Magnesium, Iron|Grain
Oatmeal (cooked)|1 cup (234 g)|166|6.0|3.6|28.0|Fiber, Manganese, Phosphorus, Magnesium, Iron|Grain
Barley (pearled, cooked)|100 g|123|2.3|0.4|28.0|Fiber, Selenium, Manganese, Niacin, Magnesium|Grain
Farro (cooked)|100 g|127|5.0|0.8|26.0|Fiber, Magnesium, Zinc, Protein, B vitamins|Grain
Bulgur (cooked)|100 g|83|3.1|0.2|19.0|Fiber, Manganese, Magnesium, Iron, Protein|Grain
Couscous (cooked)|100 g|112|3.8|0.2|23.0|Selenium, Protein, B vitamins, Manganese|Grain
Millet (cooked)|100 g|119|3.5|1.0|24.0|Magnesium, Phosphorus, Fiber, Manganese, Copper|Grain
Buckwheat groats (cooked)|100 g|92|3.4|0.6|20.0|Magnesium, Fiber, Copper, Manganese, Protein|Grain
Amaranth (cooked)|100 g|102|3.8|1.6|19.0|Manganese, Magnesium, Phosphorus, Iron, Protein|Grain
Teff (cooked)|100 g|101|3.9|0.7|20.0|Iron, Calcium, Protein, Fiber, Magnesium|Grain
Sorghum (cooked)|100 g|109|3.6|1.1|24.0|Magnesium, Fiber, Phosphorus, Iron, B vitamins|Grain
Corn tortilla|1 tortilla (24 g)|52|1.4|0.7|11.0|Magnesium, Fiber, Phosphorus, B vitamins|Grain
Flour tortilla|1 medium (45 g)|140|4.0|3.5|24.0|Selenium, Folate, Thiamin, Iron, Protein|Grain
Whole wheat bread|1 slice (32 g)|81|4.0|1.1|14.0|Fiber, Selenium, Manganese, B vitamins, Protein|Grain
Sourdough bread|1 slice (32 g)|87|3.0|0.6|17.0|Selenium, Folate, B vitamins, Protein|Grain
Rye bread|1 slice (32 g)|83|2.7|1.1|15.0|Fiber, Manganese, Selenium, B vitamins|Grain
Bagel (plain)|1 small (70 g)|190|7.0|1.2|37.0|Selenium, Folate, Thiamin, Manganese, Protein|Grain
Pasta (cooked wheat)|100 g|131|5.0|1.1|25.0|Selenium, Folate, Thiamin, Protein, Manganese|Grain
Whole wheat pasta (cooked)|100 g|124|5.3|0.8|26.0|Fiber, Selenium, Manganese, Protein, Folate|Grain
Egg noodles (cooked)|100 g|138|4.5|2.1|25.0|Selenium, B vitamins, Protein, Phosphorus|Grain
Polenta / cornmeal (cooked)|100 g|70|1.7|0.3|15.0|Iron, Magnesium, B vitamins, Fiber|Grain
Popcorn (air-popped)|3 cups (24 g)|93|3.0|1.1|19.0|Fiber, Magnesium, Phosphorus, Antioxidants|Grain
Wheat bran|2 Tbsp (8 g)|17|1.2|0.3|5.0|Fiber, Magnesium, Selenium, Manganese, Phosphorus|Grain
Wheat germ|2 Tbsp (14 g)|52|3.3|1.4|7.0|Folate, Vitamin E, Zinc, Magnesium, Protein|Grain
Coffee (black)|1 cup (240 ml)|2|0.3|0.0|0.0|Antioxidants, Potassium, Magnesium, Caffeine|Other
Espresso|1 shot (30 ml)|3|0.1|0.0|0.0|Antioxidants, Caffeine, Potassium|Other
Green tea|1 cup (240 ml)|2|0.0|0.0|0.5|Catechins, L-theanine, Antioxidants, Fluoride|Other
Black tea|1 cup (240 ml)|2|0.0|0.0|0.7|Flavonoids, Antioxidants, Manganese, Caffeine|Other
Herbal tea|1 cup (240 ml)|2|0.0|0.0|0.5|Hydration, Herb-specific antioxidants|Other
Bone broth extra|1 cup (240 ml)|45|9.0|0.5|0.5|Collagen, Minerals, Amino acids, Hydration|Other
Chicken broth (low sodium)|1 cup (240 ml)|15|1.0|0.5|1.0|Sodium (varies), Hydration, Flavor compounds|Other
Beef broth|1 cup (240 ml)|17|3.0|0.5|0.1|Sodium, Protein (small), Minerals, Hydration|Other
Coconut water|1 cup (240 ml)|46|1.7|0.5|9.0|Potassium, Magnesium, Hydration, Vitamin C (small)|Other
Sparkling water|1 cup (240 ml)|0|0|0|0|Hydration, none (unflavored)|Other
Mustard (yellow)|1 tsp (5 g)|3|0.2|0.2|0.3|Turmeric, Sodium, Vinegar compounds|Other
Dijon mustard|1 tsp (5 g)|5|0.3|0.3|0.5|Sodium, Vinegar compounds, Selenium (small)|Other
Hot sauce|1 tsp (5 g)|1|0.1|0.0|0.2|Capsaicin, Sodium, Vitamin C (small)|Other
Soy sauce|1 Tbsp (16 g)|9|1.3|0.0|0.8|Sodium, Umami, Small protein|Other
Coconut aminos|1 Tbsp (15 g)|10|0.0|0.0|2.0|Sodium (less than soy), Amino acids (small)|Other
Apple cider vinegar|1 Tbsp (15 g)|3|0.0|0.0|0.1|Acetic acid, Potassium (small)|Other
White vinegar|1 Tbsp (15 g)|3|0.0|0.0|0.0|Acetic acid|Other
Balsamic vinegar|1 Tbsp (16 g)|14|0.1|0.0|2.7|Polyphenols, Acetic acid, Small carbs|Other
Tomato paste|2 Tbsp (33 g)|27|1.4|0.2|6.0|Lycopene, Potassium, Vitamin C, Iron|Other
Marinara sauce (no sugar added)|1/2 cup (125 g)|70|2.0|3.0|8.0|Lycopene, Vitamin C, Potassium, Fiber|Other
Salsa (fresh)|2 Tbsp (30 g)|10|0.4|0.1|2.0|Vitamin C, Lycopene, Potassium, Fiber|Other
Guacamole extra|1/4 cup (60 g)|96|1.2|8.8|5.2|Potassium, Fiber, Folate, Monounsaturated fat|Other
Hummus extra|1/4 cup (60 g)|140|4.0|10.0|12.0|Fiber, Iron, Folate, Protein, Healthy fats|Other
Tzatziki|2 Tbsp (30 g)|30|1.5|2.0|2.0|Calcium, Protein, Probiotics, Vitamin A|Other
Soy sauce tamari|1 Tbsp (16 g)|10|1.9|0.0|1.0|Sodium, Umami, Protein (small)|Other
Fish sauce|1 tsp (6 g)|6|1.0|0.0|0.6|Sodium, Umami, B12 (small)|Other
Worcestershire sauce|1 tsp (5 g)|5|0.0|0.0|1.0|Sodium, Umami, Small carbs|Other
Capers|1 Tbsp (9 g)|2|0.2|0.1|0.4|Sodium, Vitamin K, Fiber (small)|Other
Horseradish|1 tsp (5 g)|2|0.1|0.0|0.5|Glucosinolates, Vitamin C (small)|Other
Wasabi paste|1 tsp (5 g)|10|0.2|0.3|1.5|Isothiocyanates, Sodium|Other
Mayonnaise (conventional)|1 Tbsp (14 g)|94|0.1|10.0|0.1|Fat, Vitamin E, Vitamin K (small)|Other
Ketchup|1 Tbsp (17 g)|17|0.2|0.0|4.5|Lycopene, Sodium, Small sugars|Other
BBQ sauce|2 Tbsp (34 g)|58|0.3|0.2|14.0|Sodium, Lycopene, Sugars|Other
Honey|1 Tbsp (21 g)|64|0.1|0.0|17.0|Sugars, Trace minerals, Antioxidants (small)|Other
Maple syrup|1 Tbsp (20 g)|52|0.0|0.0|13.0|Manganese, Zinc, Sugars|Other
Stevia (powder)|1 packet (1 g)|0|0|0|1.0|Zero-calorie sweetener|Other
Monk fruit sweetener|1 tsp (4 g)|0|0|0|0|Zero-calorie sweetener|Other
Erythritol|1 tsp (4 g)|0|0|0|4.0|Sugar alcohol (near-zero net energy)|Other
Dark chocolate 70%|2 squares (~20 g)|120|1.6|8.5|9.0|Flavonoids, Iron, Magnesium, Copper, Antioxidants|Other
Cocoa powder (unsweetened)|1 Tbsp (5 g)|12|1.0|0.7|3.0|Flavonoids, Magnesium, Iron, Copper, Fiber|Other
Gelatin (dry)|1 Tbsp (7 g)|23|6.0|0|0|Collagen amino acids, Protein|Other
Nutritional yeast|2 Tbsp (16 g)|60|8.0|1.0|5.0|B vitamins (often B12 fortified), Protein, Fiber|Other
Psyllium husk|1 Tbsp (5 g)|18|0.1|0.1|4.0|Soluble fiber, Satiety support|Other
Chia extra (2 Tbsp)|2 Tbsp (24 g)|116|4.0|7.4|10.0|Fiber, ALA, Calcium, Magnesium, Phosphorus|Other
Flax extra (2 Tbsp)|2 Tbsp (14 g)|75|2.6|6.0|4.0|ALA, Fiber, Lignans, Magnesium|Other
Whey extra (2 scoops note)|1 scoop (30 g) isolate|110|25.0|0.5|1.0|Complete protein, BCAAs, Calcium|Other
Electrolyte mix (unsweetened)|1 serving in water|10|0|0|2.0|Sodium, Potassium, Magnesium, Hydration|Other
Pickle juice|2 Tbsp (30 g)|2|0.1|0.0|0.4|Sodium, Electrolytes, Vinegar|Other
Olives extra (green)|5 large (~20 g)|30|0.2|3.0|1.0|Monounsaturated fat, Sodium, Vitamin E, Polyphenols|Other
Sunflower oil|1 Tbsp (14 g)|120|0|13.6|0|Vitamin E, Polyunsaturated fat|Other
Canola oil|1 Tbsp (14 g)|124|0|14.0|0|Vitamin E, Unsaturated fat|Other
Grapeseed oil|1 Tbsp (14 g)|120|0|13.6|0|Vitamin E, Polyunsaturated fat|Other
Red wine vinegar|1 Tbsp (15 g)|3|0.0|0.0|0.1|Acetic acid, Polyphenols (small)|Other
Rice vinegar|1 Tbsp (15 g)|5|0.0|0.0|1.0|Acetic acid, Small carbs|Other
Sesame oil extra (toasted)|1 tsp (5 g)|40|0|4.5|0|Sesame lignans, Flavor compounds, Fat|Other
Chili oil|1 tsp (5 g)|40|0|4.5|0.2|Capsaicin, Fat, Flavor compounds|Other
Ghee extra|1 tsp (5 g)|45|0|5.0|0|Fat-soluble vitamins, Clarified butter fat|Other
Butter extra|1 tsp (5 g)|36|0|4.0|0|Vitamin A, Saturated fat|Other
Salt (sea)|1/4 tsp (1.5 g)|0|0|0|0|Sodium, Trace minerals (varies)|Other
Black pepper|1 tsp (2 g)|6|0.2|0.1|1.5|Piperine, Manganese, Vitamin K (small)|Other
Paprika|1 tsp (2 g)|6|0.3|0.3|1.2|Vitamin A, Antioxidants, Iron (small)|Other
Cumin (ground)|1 tsp (2 g)|8|0.4|0.5|0.9|Iron, Manganese, Antioxidants|Other
Turmeric (ground)|1 tsp (2 g)|8|0.3|0.2|1.4|Curcumin, Iron, Manganese, Antioxidants|Other
Cinnamon|1 tsp (3 g)|6|0.1|0.0|2.1|Antioxidants, Manganese, Calcium (small)|Other
Chili powder|1 tsp (3 g)|8|0.4|0.4|1.4|Vitamin A, Capsaicin, Iron|Other
Garlic powder|1 tsp (3 g)|10|0.5|0.0|2.2|Allicin compounds, B6, Manganese|Other
Onion powder|1 tsp (2 g)|8|0.2|0.0|1.9|Vitamin C (small), B6, Antioxidants|Other
Everything bagel seasoning|1 tsp (3 g)|10|0.4|0.6|1.0|Sesame, Onion, Garlic, Sodium|Other
Beef stick (sugar-free)|1 stick (28 g)|90|6.0|7.0|1.0|Protein, Fat, Sodium, Zinc, B12|Other
Salami extra (2 slices)|2 slices (18 g)|70|4.0|6.0|0.2|Fat, Sodium, Protein, Zinc|Other
'@

foreach ($line in ($extra -split "`n")) {
  $line = $line.Trim()
  if (-not $line) { continue }
  $p = $line.Split('|')
  if ($p.Count -lt 8) { continue }
  Add-Food $p[0] $p[1] $p[2] $p[3] $p[4] $p[5] $p[6] $p[7]
}

Write-Host ("Food count after extras: " + $foods.Count)

$more = @'
Chicken tenderloin (cooked)|100 g|173|26.0|7.0|0|Niacin, Selenium, B6, Phosphorus, Protein|Protein
Chicken gizzards (cooked)|100 g|154|30.0|2.7|0|Protein, B12, Iron, Zinc, Selenium|Protein
Ground turkey 85% (cooked)|100 g|213|27.0|12.0|0|Selenium, Niacin, Zinc, Phosphorus, B6|Protein
Cornish hen (roasted)|100 g|220|24.0|13.0|0|Niacin, Selenium, B6, Phosphorus, Zinc|Protein
Pheasant (roasted)|100 g|239|32.0|12.0|0|Protein, Niacin, Phosphorus, Selenium, B6|Protein
Goose (roasted)|100 g|305|25.0|22.0|0|Protein, Iron, B12, Selenium, Fat|Protein
Frog legs (cooked)|100 g|73|16.4|0.3|0|Protein, Potassium, Phosphorus, Selenium, Niacin|Protein
Eel (cooked)|100 g|236|24.0|15.0|0|Omega-3, B12, A, Phosphorus, Selenium|Protein
Grouper (cooked)|100 g|118|25.0|1.3|0|Selenium, B12, Protein, Potassium, Niacin|Protein
Perch (cooked)|100 g|117|25.0|1.2|0|Selenium, B12, Phosphorus, Protein, Niacin|Protein
Pike (cooked)|100 g|113|25.0|0.9|0|Selenium, B12, Phosphorus, Protein, Niacin|Protein
Pollock (cooked)|100 g|92|20.0|1.0|0|Selenium, B12, Phosphorus, Protein, Iodine|Protein
Rockfish (cooked)|100 g|121|24.0|2.0|0|Selenium, B12, Protein, Phosphorus, Niacin|Protein
Sole / flounder (cooked)|100 g|86|15.0|2.4|0|Selenium, B12, Phosphorus, Protein, Niacin|Protein
Whitefish (cooked)|100 g|172|24.0|7.5|0|B12, Selenium, Phosphorus, Niacin, Protein|Protein
Carp (cooked)|100 g|162|23.0|7.2|0|Phosphorus, B12, Selenium, Protein, Potassium|Protein
Sablefish / black cod (cooked)|100 g|250|17.0|20.0|0|Omega-3, Vitamin D, Selenium, B12, Fat|Protein
Yellowtail (cooked)|100 g|146|24.0|5.2|0|Selenium, B12, Niacin, Protein, Phosphorus|Protein
King crab (cooked)|100 g|82|18.0|1.3|0|B12, Zinc, Copper, Selenium, Protein|Protein
Snow crab (cooked)|100 g|90|18.5|1.2|0|B12, Zinc, Copper, Selenium, Protein|Protein
Dungeness crab (cooked)|100 g|86|17.0|1.0|0.8|B12, Zinc, Copper, Selenium, Protein|Protein
Abalone (cooked)|100 g|105|17.0|0.8|6.0|Selenium, B12, Protein, Iron, Magnesium|Protein
Conch (cooked)|100 g|130|26.0|1.2|1.7|Protein, B12, Iron, Magnesium, Selenium|Protein
Sea urchin (uni)|100 g|120|13.0|3.0|3.0|Omega-3, B12, Zinc, Selenium, Protein|Protein
Caviar / fish roe|1 Tbsp (16 g)|42|4.0|2.9|0.6|Omega-3, B12, Selenium, Choline, Sodium|Protein
Icelandic yogurt (skyr)|170 g (6 oz)|110|19.0|0.4|7.0|Protein, Calcium, Probiotics, B12, Phosphorus|Dairy
Labneh|28 g (1 oz)|50|2.5|4.0|1.5|Protein, Calcium, Probiotics, Fat, Phosphorus|Dairy
Queso fresco|28 g (1 oz)|80|6.0|6.0|1.0|Calcium, Protein, Phosphorus, B12|Dairy
Cotija|28 g (1 oz)|110|7.0|9.0|1.0|Calcium, Protein, Sodium, Phosphorus|Dairy
Oaxaca cheese|28 g (1 oz)|85|6.0|6.5|0.5|Calcium, Protein, Phosphorus, B12|Dairy
Burrata|28 g (1 oz)|90|4.0|8.0|0.5|Calcium, Fat, Protein, Vitamin A, Phosphorus|Dairy
Goat milk|1 cup (244 g)|168|9.0|10.0|11.0|Calcium, Protein, Phosphorus, B2, Potassium|Dairy
A2 whole milk|1 cup (244 g)|149|8.0|8.0|12.0|Calcium, B12, Riboflavin, Phosphorus, Protein|Dairy
Lactose-free whole milk|1 cup (244 g)|149|8.0|8.0|12.0|Calcium, B12, Riboflavin, Phosphorus, Protein|Dairy
Sheep milk yogurt|170 g (6 oz)|160|8.0|10.0|8.0|Calcium, Protein, Fat, B12, Phosphorus|Dairy
Brown butter|1 tsp (5 g)|45|0|5.0|0|Fat-soluble vitamins, Butyrate, Saturated fat|Healthy Fat
Walnut pesto|2 Tbsp (30 g)|170|3.0|16.0|3.0|ALA, Vitamin K, Healthy fats, Calcium|Healthy Fat
Chili crisp|1 Tbsp (15 g)|90|1.0|9.0|2.0|Fat, Capsaicin, Sodium, Flavor compounds|Healthy Fat
Duck confit fat portion|1 Tbsp (13 g)|115|0|13.0|0|Monounsaturated fat, Saturated fat|Healthy Fat
Pistachio butter|2 Tbsp (32 g)|180|6.0|14.0|8.0|B6, Copper, Healthy fats, Protein, Fiber|Nuts & Seeds
Hazelnut butter|2 Tbsp (32 g)|200|4.0|18.0|6.0|Vitamin E, Manganese, Healthy fats, Copper|Nuts & Seeds
Tiger nuts|28 g (1 oz)|140|1.0|7.0|19.0|Fiber, Magnesium, Iron, Potassium, Vitamin E|Nuts & Seeds
Hickory nuts|28 g (1 oz)|193|3.6|18.2|5.2|Manganese, Healthy fats, Magnesium, Thiamin|Nuts & Seeds
Beechnuts|28 g (1 oz)|164|1.8|14.0|9.5|Manganese, Healthy fats, Potassium, Fiber|Nuts & Seeds
Lotus seeds (roasted)|28 g (1 oz)|94|4.0|0.6|18.0|Magnesium, Potassium, Protein, Fiber, Phosphorus|Nuts & Seeds
Broccoli slaw (raw)|100 g|25|2.0|0.3|5.0|Vitamin C, K, Fiber, Folate, Potassium|Vegetable
Cauliflower mash (plain cooked)|100 g|23|1.8|0.5|4.1|Vitamin C, K, Folate, Fiber, Choline|Vegetable
Riced broccoli (cooked)|100 g|30|2.5|0.3|6.0|Vitamin C, K, Folate, Fiber, Potassium|Vegetable
Shishito peppers (cooked)|100 g|27|1.0|0.3|6.0|Vitamin C, B6, Fiber, Antioxidants|Vegetable
Poblano pepper (raw)|100 g|20|0.9|0.2|4.6|Vitamin C, B6, A, Fiber|Vegetable
Serrano pepper (raw)|1 pepper (6 g)|2|0.1|0.0|0.4|Vitamin C, Capsaicin, B6|Vegetable
Habanero (raw)|1 pepper (4.5 g)|2|0.1|0.0|0.4|Vitamin C, Capsaicin, A|Vegetable
Banana pepper (raw)|100 g|27|1.7|0.5|5.3|Vitamin C, B6, Fiber, Folate|Vegetable
Pepperoncini|5 peppers (30 g)|8|0.3|0.1|1.6|Vitamin C, Sodium, Fiber|Vegetable
Green tomato (raw)|100 g|23|1.2|0.2|5.1|Vitamin C, K, Potassium, Fiber|Vegetable
Roma tomato|1 medium (62 g)|11|0.5|0.1|2.4|Vitamin C, Lycopene, Potassium, A|Vegetable
Beefsteak tomato|1 slice (20 g)|4|0.2|0.0|0.8|Vitamin C, Lycopene, Potassium|Vegetable
Cucumber English|100 g|15|0.7|0.1|3.6|Vitamin K, Potassium, Hydration|Vegetable
Kirby cucumber|1 small (80 g)|12|0.5|0.1|2.9|Vitamin K, Potassium, Hydration|Vegetable
Iceberg lettuce|100 g|14|0.9|0.1|3.0|Vitamin K, A, Folate, Hydration|Vegetable
Butter lettuce|100 g|13|1.4|0.2|2.2|Vitamin K, A, Folate, Hydration|Vegetable
Little gem lettuce|100 g|16|1.2|0.3|3.0|Vitamin K, A, Folate, Fiber|Vegetable
Mizuna|100 g|23|2.2|0.3|3.7|Vitamin A, C, K, Folate, Calcium|Vegetable
Tatsoi|100 g|20|2.2|0.3|3.0|Vitamin A, C, K, Calcium, Folate|Vegetable
Water spinach / ong choy (cooked)|100 g|19|2.6|0.2|3.1|Vitamin A, C, Iron, Calcium, Folate|Vegetable
Amaranth leaves (cooked)|100 g|21|2.1|0.2|4.0|Vitamin A, C, Calcium, Iron, Folate|Vegetable
Pumpkin leaves (cooked)|100 g|19|2.7|0.2|3.4|Vitamin A, C, Calcium, Iron, Folate|Vegetable
Sorrel (raw)|100 g|22|2.0|0.7|3.2|Vitamin C, A, Magnesium, Oxalates, Fiber|Vegetable
Purslane (raw)|100 g|16|1.3|0.4|3.4|Omega-3 (ALA), Vitamin A, C, Magnesium|Vegetable
Lamb's lettuce / mache|100 g|21|2.0|0.4|3.6|Vitamin A, C, Iron, Folate, Omega-3 (small)|Vegetable
Cress (garden)|100 g|32|2.6|0.7|5.5|Vitamin K, A, C, Calcium, Antioxidants|Vegetable
Chicory greens (raw)|100 g|23|1.7|0.3|4.7|Vitamin K, A, Folate, Manganese, Fiber|Vegetable
Escarole (raw)|100 g|17|1.2|0.2|3.3|Vitamin A, K, Folate, Fiber|Vegetable
Frisee|100 g|17|1.3|0.2|3.3|Vitamin A, K, Folate, Fiber|Vegetable
Belgian endive extra|1 head (53 g)|9|0.7|0.1|1.8|Vitamin K, Folate, A, Fiber|Vegetable
Celery root / celeriac (cooked)|100 g|42|1.5|0.3|9.2|Vitamin K, C, Phosphorus, Fiber, Potassium|Vegetable
Sunchoke / Jerusalem artichoke (raw)|100 g|73|2.0|0.0|17.0|Iron, Potassium, Fiber (inulin), B1, Phosphorus|Vegetable
Yacon (raw)|100 g|54|0.3|0.1|13.0|Fiber (FOS), Potassium, Antioxidants|Vegetable
Burdock root (cooked)|100 g|89|1.8|0.1|21.0|Fiber, Potassium, Magnesium, Folate, Antioxidants|Vegetable
Salsify (cooked)|100 g|82|3.3|0.2|19.0|Fiber, Vitamin C, Potassium, Iron, B6|Vegetable
Oca|100 g|61|1.1|0.6|13.0|Vitamin C, Fiber, Potassium, Iron|Vegetable
Ulluco|100 g|74|2.6|0.5|14.0|Protein (for a tuber), Vitamin C, Fiber, Iron|Vegetable
Mashua|100 g|50|1.5|0.6|10.0|Vitamin C, Antioxidants, Fiber|Vegetable
Chinese broccoli / gai lan (cooked)|100 g|26|1.6|0.7|3.8|Vitamin A, C, K, Calcium, Folate|Vegetable
Chinese mustard greens (cooked)|100 g|15|1.6|0.2|2.6|Vitamin A, C, K, Calcium, Folate|Vegetable
Yardlong beans (cooked)|100 g|47|2.8|0.1|9.2|Vitamin C, A, Folate, Fiber, Magnesium|Vegetable
Winged beans (cooked)|100 g|49|7.0|1.0|4.0|Protein, Fiber, Vitamin C, Iron, Folate|Vegetable
Bitter melon (cooked)|100 g|19|0.8|0.2|4.3|Vitamin C, Fiber, Folate, Potassium, Antioxidants|Vegetable
Luffa / sponge gourd (cooked)|100 g|20|1.2|0.2|4.3|Vitamin C, Fiber, Potassium, Folate|Vegetable
Bottle gourd (cooked)|100 g|15|0.6|0.0|3.4|Vitamin C, Potassium, Fiber, Magnesium|Vegetable
Ivy gourd (raw)|100 g|18|1.5|0.1|3.1|Vitamin C, A, Fiber, Iron|Vegetable
Tinda (cooked)|100 g|21|1.4|0.2|4.0|Vitamin C, Fiber, Potassium|Vegetable
Drumstick / moringa pods (cooked)|100 g|37|2.1|0.2|8.5|Vitamin C, A, Calcium, Iron, Fiber|Vegetable
Moringa leaves (raw)|100 g|64|9.4|1.4|8.3|Vitamin A, C, Calcium, Iron, Protein|Vegetable
Fenugreek leaves (cooked)|100 g|34|4.4|0.9|6.0|Iron, Fiber, Protein, Vitamin C, Calcium|Vegetable
Methi sprouts|100 g|20|3.0|0.5|3.0|Iron, Fiber, Protein, Vitamin C|Vegetable
Banana blossom (cooked)|100 g|51|1.7|0.6|11.0|Fiber, Potassium, Magnesium, Vitamin C|Vegetable
Jackfruit (young, cooked)|100 g|95|1.7|0.6|23.0|Vitamin C, Potassium, Fiber, B6, Magnesium|Fruit
Breadfruit (cooked)|100 g|108|1.1|0.2|27.0|Vitamin C, Potassium, Fiber, Thiamin, Magnesium|Fruit
Soursop|100 g|66|1.0|0.3|17.0|Vitamin C, Fiber, Potassium, B6, Magnesium|Fruit
Cherimoya|100 g|75|1.6|0.7|18.0|Vitamin C, B6, Fiber, Potassium, Magnesium|Fruit
Atemoya|100 g|94|2.1|0.6|22.0|Vitamin C, Fiber, Potassium, B6|Fruit
Longan|100 g|60|1.3|0.1|15.0|Vitamin C, Copper, Potassium, Riboflavin|Fruit
Rambutan|100 g|82|0.7|0.2|21.0|Vitamin C, Copper, Fiber, Manganese|Fruit
Mangosteen|100 g|73|0.4|0.6|18.0|Vitamin C, Fiber, Folate, Antioxidants|Fruit
Durian|100 g|147|1.5|5.3|27.0|Fiber, Potassium, B6, Vitamin C, Healthy fats (small)|Fruit
Jackfruit ripe|100 g|95|1.7|0.6|23.0|Vitamin C, Potassium, Fiber, B6|Fruit
Tamarind|1 Tbsp pulp (15 g)|36|0.4|0.1|9.0|Magnesium, Potassium, Iron, B vitamins, Fiber|Fruit
Jujube (fresh)|100 g|79|1.2|0.2|20.0|Vitamin C, Potassium, Fiber, Antioxidants|Fruit
Loquat|100 g|47|0.4|0.2|12.0|Vitamin A, Potassium, Fiber, Vitamin B6|Fruit
Quince (cooked)|100 g|57|0.4|0.1|15.0|Vitamin C, Fiber, Copper, Potassium|Fruit
Medlar|100 g|47|0.5|0.2|12.0|Vitamin C, Fiber, Potassium|Fruit
Rowan berries|100 g|50|0.8|0.5|10.0|Vitamin C, Antioxidants, Fiber|Fruit
Elderberries (raw)|100 g|73|0.7|0.5|18.0|Vitamin C, Fiber, Antioxidants, B6|Fruit
Aronia / chokeberry|100 g|47|1.4|0.5|10.0|Anthocyanins, Vitamin C, Fiber, Manganese|Fruit
Sea buckthorn berries|100 g|82|1.4|5.4|6.3|Vitamin C, Vitamin E, Omega-7, Antioxidants|Fruit
Camu camu|100 g|17|0.4|0.2|4.0|Vitamin C (very high), Antioxidants, Potassium|Fruit
Acerola|100 g|32|0.4|0.3|8.0|Vitamin C (very high), Vitamin A, Antioxidants|Fruit
Rose hips|100 g|162|1.6|0.3|38.0|Vitamin C, Fiber, Vitamin A, Antioxidants|Fruit
Hawthorn berries|100 g|55|0.5|0.6|14.0|Fiber, Antioxidants, Vitamin C|Fruit
Barberries|100 g|83|1.1|0.4|18.0|Vitamin C, Fiber, Antioxidants, Iron|Fruit
Goji berries (dried)|28 g (1 oz)|98|4.0|0.3|21.0|Vitamin A, C, Fiber, Iron, Antioxidants|Fruit
Golden berries / Inca|28 g (1 oz)|76|1.5|0.6|16.0|Vitamin A, C, Fiber, Antioxidants|Fruit
White beans (cooked)|100 g|139|9.7|0.4|25.0|Fiber, Folate, Iron, Magnesium, Potassium|Legume
Cranberry beans (cooked)|100 g|136|9.3|0.5|24.0|Fiber, Folate, Manganese, Iron, Potassium|Legume
Pink beans (cooked)|100 g|149|9.1|0.5|28.0|Fiber, Folate, Potassium, Iron, Magnesium|Legume
Yellow split peas (cooked)|100 g|118|8.3|0.4|21.0|Fiber, Folate, Protein, Manganese, Potassium|Legume
Chana dal (cooked)|100 g|135|7.0|2.0|22.0|Fiber, Folate, Protein, Manganese, Iron|Legume
Moth beans (cooked)|100 g|104|7.8|0.6|18.0|Protein, Fiber, Iron, Folate, Magnesium|Legume
Horse gram (cooked)|100 g|119|8.0|0.5|21.0|Protein, Iron, Fiber, Calcium, Folate|Legume
Pigeon peas (cooked)|100 g|121|6.8|0.4|23.0|Folate, Fiber, Magnesium, Potassium, Protein|Legume
Bambara groundnuts (cooked)|100 g|190|7.0|6.0|26.0|Protein, Fiber, Magnesium, Potassium, Healthy fats|Legume
Winged bean seeds (cooked)|100 g|147|11.0|5.0|15.0|Protein, Fiber, Vitamin E, Minerals|Legume
Sorghum popped|1 cup (20 g)|76|2.5|0.8|16.0|Magnesium, Fiber, Phosphorus, Iron, B vitamins|Grain
Freekeh (cooked)|100 g|115|4.5|1.0|22.0|Fiber, Protein, Magnesium, Lutein, Iron|Grain
Spelt (cooked)|100 g|127|5.5|0.9|26.0|Fiber, Manganese, Phosphorus, Protein, Magnesium|Grain
Kamut (cooked)|100 g|132|6.0|0.9|28.0|Selenium, Protein, Fiber, Magnesium, Zinc|Grain
Einkorn (cooked)|100 g|148|6.0|2.0|28.0|Protein, Fiber, Lutein, Magnesium, Zinc|Grain
Triticale (cooked)|100 g|132|5.0|1.0|28.0|Manganese, Fiber, Protein, Phosphorus, Magnesium|Grain
Rye berries (cooked)|100 g|121|4.0|1.0|25.0|Fiber, Manganese, Phosphorus, Magnesium, Protein|Grain
Hominy (cooked)|100 g|72|1.5|0.9|14.0|Fiber, Magnesium, B vitamins, Iron|Grain
Grits (cooked)|100 g|71|1.7|0.5|16.0|Iron, B vitamins, Magnesium, Selenium|Grain
Cream of wheat (cooked)|100 g|50|1.8|0.2|11.0|Iron (if fortified), B vitamins, Selenium|Grain
Rice noodles (cooked)|100 g|109|0.9|0.2|25.0|Selenium, Manganese, Small protein|Grain
Soba noodles (cooked)|100 g|99|5.1|0.1|21.0|Protein, Manganese, Thiamin, Magnesium, Fiber|Grain
Udon noodles (cooked)|100 g|99|2.6|0.2|22.0|Selenium, Thiamin, Small protein|Grain
Somen noodles (cooked)|100 g|131|4.0|0.2|28.0|Selenium, Thiamin, Manganese|Grain
Shirataki noodles|100 g|9|0.2|0.0|3.0|Glucomannan fiber, Very low calorie|Grain
Kelp noodles|100 g|6|0.5|0.1|1.0|Iodine, Low calorie, Minerals|Vegetable
Hearts of palm pasta|100 g|18|1.5|0.2|4.0|Potassium, Fiber, Low calorie|Vegetable
Zucchini noodles (raw)|100 g|17|1.2|0.3|3.1|Vitamin C, Potassium, Manganese, Fiber|Vegetable
Carrot noodles (raw)|100 g|41|0.9|0.2|10.0|Vitamin A, Fiber, Biotin, Potassium|Vegetable
Coconut flour|2 Tbsp (14 g)|60|3.0|2.0|8.0|Fiber, MCTs, Manganese, Iron|Other
Almond flour|2 Tbsp (14 g)|80|3.0|7.0|3.0|Vitamin E, Magnesium, Healthy fats, Fiber|Other
Psyllium extra|2 Tbsp (10 g)|36|0.2|0.2|8.0|Soluble fiber, Satiety|Other
Ground flax extra|3 Tbsp (21 g)|112|3.9|9.0|6.0|ALA, Fiber, Lignans, Magnesium|Other
Hemp protein powder|1 scoop (30 g)|110|15.0|3.0|8.0|Plant protein, Magnesium, Iron, Fiber, Zinc|Other
Pea protein powder|1 scoop (30 g)|120|24.0|2.0|1.0|Plant protein, Iron, BCAAs|Other
Soy protein isolate|1 scoop (30 g)|110|25.0|1.0|1.0|Plant protein, Calcium (often), Iron|Other
Egg white protein powder|1 scoop (30 g)|110|24.0|0.5|2.0|Complete protein, B2, Potassium|Other
Beef protein isolate|1 scoop (30 g)|110|24.0|1.5|1.0|Protein, Amino acids, Iron (small)|Other
MCT powder|1 Tbsp (10 g)|70|0|7.0|2.0|Medium-chain triglycerides, Rapid fat energy|Healthy Fat
Cacao nibs|1 Tbsp (7 g)|35|1.0|3.0|2.0|Flavonoids, Magnesium, Iron, Fiber, Antioxidants|Other
Carob powder|1 Tbsp (6 g)|13|0.3|0.0|5.0|Fiber, Calcium, Antioxidants|Other
Molasses|1 Tbsp (20 g)|58|0.0|0.0|15.0|Iron, Potassium, Magnesium, Calcium, B6|Other
Brown sugar|1 Tbsp (12 g)|52|0|0|13.0|Sugars, Trace minerals (small)|Other
White sugar|1 Tbsp (12 g)|49|0|0|13.0|Sugars only|Other
Coconut sugar|1 Tbsp (12 g)|45|0|0|12.0|Sugars, Small minerals|Other
Agave nectar|1 Tbsp (21 g)|64|0|0|16.0|Sugars, Fructose|Other
Date syrup|1 Tbsp (20 g)|55|0.2|0.0|14.0|Potassium, Sugars, Trace minerals|Other
Apple sauce (unsweetened)|100 g|42|0.2|0.1|11.0|Vitamin C, Fiber, Potassium|Fruit
Tomato juice|1 cup (243 g)|41|1.8|0.1|10.0|Lycopene, Vitamin C, Potassium, A|Other
Vegetable juice (low sodium)|1 cup (240 g)|50|2.0|0.2|11.0|Vitamin A, C, Potassium, Antioxidants|Other
Kombucha (plain)|1 cup (240 ml)|30|0.0|0.0|7.0|Acids, Trace probiotics, Small sugars|Other
Kefir water|1 cup (240 ml)|10|0.0|0.0|2.0|Probiotics, Hydration, Small acids|Other
Coconut kefir|1 cup (240 ml)|45|1.0|2.0|6.0|Probiotics, MCTs (if coconut), Hydration|Other
Aloe juice|1/2 cup (120 ml)|15|0.0|0.0|4.0|Hydration, Polysaccharides|Other
Wheatgrass juice|1 oz (30 ml)|5|0.5|0.0|0.6|Chlorophyll, Vitamin A, C, Iron (small)|Other
Beet juice|1/2 cup (120 ml)|50|1.0|0.1|12.0|Nitrates, Folate, Potassium, Antioxidants|Other
Celery juice|1 cup (240 ml)|42|2.0|0.5|9.0|Vitamin K, Potassium, Hydration|Other
Lemon water|1 cup with 1 Tbsp juice|4|0.0|0.0|1.0|Vitamin C, Hydration, Citric acid|Other
Mineral water|1 cup (240 ml)|0|0|0|0|Hydration, Trace minerals (varies)|Other
Club soda|1 cup (240 ml)|0|0|0|0|Hydration, Sodium (varies)|Other
Tonic water|1 cup (240 ml)|83|0|0|21.0|Sugars, Quinine, Sodium|Other
Cola (regular)|1 can (355 ml)|140|0|0|39.0|Sugars, Phosphoric acid, Caffeine|Other
Cola (diet)|1 can (355 ml)|0|0|0|0|Caffeine, Artificial sweeteners, Phosphoric acid|Other
Orange juice|1 cup (248 g)|112|1.7|0.5|26.0|Vitamin C, Folate, Potassium, Thiamin|Fruit
Apple juice|1 cup (248 g)|114|0.2|0.3|28.0|Potassium, Vitamin C (if fortified)|Fruit
Cranberry juice unsweetened|1 cup (253 g)|116|1.0|0.3|31.0|Vitamin C, Antioxidants, Potassium|Fruit
Grape juice|1 cup (253 g)|152|1.4|0.3|37.0|Potassium, Vitamin C, Polyphenols|Fruit
Prune juice|1 cup (256 g)|182|1.6|0.1|45.0|Potassium, Fiber (small), Vitamin K, Iron|Fruit
Chocolate milk (whole)|1 cup (250 g)|208|8.0|8.5|26.0|Calcium, Protein, B12, Phosphorus, Sugars|Dairy
Eggnog|1/2 cup (123 g)|179|5.0|9.5|17.0|Calcium, Protein, Vitamin A, Cholesterol, Sugars|Dairy
Hot cocoa (with milk)|1 cup (250 g)|190|9.0|6.0|27.0|Calcium, Protein, Flavonoids, Phosphorus, Sugars|Dairy
Matcha (prepared, 1 tsp powder)|1 tsp powder in water (2 g)|5|0.3|0.0|1.0|Catechins, L-theanine, Antioxidants, Caffeine|Other
Chicory coffee (prepared)|1 cup (240 ml)|5|0.2|0.0|1.0|Inulin (small), Caffeine-free roast flavor|Other
Barley tea|1 cup (240 ml)|2|0.0|0.0|0.5|Hydration, Roast barley flavor|Other
Rooibos tea|1 cup (240 ml)|2|0.0|0.0|0.4|Antioxidants, Caffeine-free, Minerals (small)|Other
Yerba mate|1 cup (240 ml)|3|0.0|0.0|0.6|Caffeine, Antioxidants, Potassium (small)|Other
'@

foreach ($line in ($more -split "`n")) {
  $line = $line.Trim()
  if (-not $line) { continue }
  $p = $line.Split('|')
  if ($p.Count -lt 8) { continue }
  Add-Food $p[0] $p[1] $p[2] $p[3] $p[4] $p[5] $p[6] $p[7]
}

Write-Host ("Food count total: " + $foods.Count)

$sorted = $foods | Sort-Object Category, Name

# CSV
$csvLines = New-Object System.Collections.Generic.List[string]
$csvLines.Add('"Food Item","Typical Serving","Calories","Protein (g)","Fat (g)","Carbs (g)","% Protein","% Fat","% Carbs","Top 5 Nutrients / Highlights","Category"')
foreach ($f in $sorted) {
  $vals = @(
    $f.Name, $f.Serving, $f.Calories, $f.Protein, $f.Fat, $f.Carbs,
    $f.PctProtein, $f.PctFat, $f.PctCarbs, $f.Nutrients, $f.Category
  ) | ForEach-Object { '"' + ([string]$_ -replace '"','""') + '"' }
  $csvLines.Add(($vals -join ","))
}
[IO.File]::WriteAllLines($outCsv, $csvLines, [Text.UTF8Encoding]::new($false))
Write-Host "Wrote CSV $outCsv"

# Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$wb = $excel.Workbooks.Add()
$ws = $wb.Worksheets.Item(1)
$ws.Name = "Food Nutrition Reference"

$ws.Cells.Item(1, 1) = "Food Nutrition Reference - Expanded List (~$($sorted.Count) foods)"
$ws.Cells.Item(2, 1) = "Typical serving sizes with approximate USDA-style calories, macros, macro % of calories, and nutrient highlights. Values vary by brand, cut, and cooking method."
$ws.Cells.Item(3, 1) = "Macro % uses 4 kcal/g for protein and carbs and 9 kcal/g for fat. Includes the original meal-planner foods plus a broader grocery/reference catalog."
$ws.Range("A1:K1").Merge() | Out-Null
$ws.Range("A2:K2").Merge() | Out-Null
$ws.Range("A3:K3").Merge() | Out-Null
$ws.Cells.Item(1, 1).Font.Bold = $true
$ws.Cells.Item(1, 1).Font.Size = 16
$ws.Cells.Item(1, 1).Font.Color = 0x2F6B3A

$headers = @(
  "Food Item","Typical Serving","Calories","Protein (g)","Fat (g)","Carbs (g)",
  "% Protein","% Fat","% Carbs","Top 5 Nutrients / Highlights","Category"
)
for ($c = 1; $c -le 11; $c++) {
  $cell = $ws.Cells.Item(5, $c)
  $cell.Value2 = $headers[$c - 1]
  $cell.Font.Bold = $true
  $cell.Interior.Color = 0x2F6B3A
  $cell.Font.Color = 0xFFFFFF
}

$colors = @{
  "Protein" = 0xCEC7FF
  "Healthy Fat" = 0xB3D9FF
  "Dairy" = 0xEED7BD
  "Nuts & Seeds" = 0xEECCDD
  "Vegetable" = 0xCEEFC6
  "Fruit" = 0xB0F2FF
  "Legume" = 0x99E6FF
  "Grain" = 0xD3E6F5
  "Other" = 0xD9D9D9
}

$r = 6
foreach ($f in $sorted) {
  $ws.Cells.Item($r, 1) = $f.Name
  $ws.Cells.Item($r, 2) = $f.Serving
  $ws.Cells.Item($r, 3) = [double]$f.Calories
  $ws.Cells.Item($r, 4) = [double]$f.Protein
  $ws.Cells.Item($r, 5) = [double]$f.Fat
  $ws.Cells.Item($r, 6) = [double]$f.Carbs
  $ws.Cells.Item($r, 7) = [double]$f.PctProtein
  $ws.Cells.Item($r, 8) = [double]$f.PctFat
  $ws.Cells.Item($r, 9) = [double]$f.PctCarbs
  $ws.Cells.Item($r, 10) = $f.Nutrients
  $ws.Cells.Item($r, 11) = $f.Category
  $hex = $colors[$f.Category]
  if ($hex) { $ws.Range("A$r`:K$r").Interior.Color = $hex }
  $r++
}

$last = $r - 1
$noteRow = $last + 2
$ws.Cells.Item($noteRow, 1) = "Notes: Approximate averages for meal planning and education, not medical advice. Prefer whole foods; adjust portions to energy needs. Original 67 meal-planner items are included."
$ws.Range("A$noteRow`:K$noteRow").Merge() | Out-Null

$ws.Columns.Item(1).ColumnWidth = 42
$ws.Columns.Item(2).ColumnWidth = 28
$ws.Columns.Item(3).ColumnWidth = 11
$ws.Columns.Item(4).ColumnWidth = 12
$ws.Columns.Item(5).ColumnWidth = 10
$ws.Columns.Item(6).ColumnWidth = 11
$ws.Columns.Item(7).ColumnWidth = 12
$ws.Columns.Item(8).ColumnWidth = 10
$ws.Columns.Item(9).ColumnWidth = 11
$ws.Columns.Item(10).ColumnWidth = 55
$ws.Columns.Item(11).ColumnWidth = 14
$ws.Range("A5:K5").AutoFilter() | Out-Null
$ws.Application.ActiveWindow.SplitRow = 5
$ws.Application.ActiveWindow.FreezePanes = $true
$ws.Rows.Item("1:3").WrapText = $true
$ws.Rows.Item(1).RowHeight = 22
$ws.Rows.Item(2).RowHeight = 32
$ws.Rows.Item(3).RowHeight = 32

if (Test-Path $outXlsx) { Remove-Item $outXlsx -Force }
$wb.SaveAs($outXlsx, 51)
$wb.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($wb) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[GC]::Collect(); [GC]::WaitForPendingFinalizers()

Write-Host "Wrote $outXlsx"
Write-Host ("Rows: " + $sorted.Count)
$sorted | Group-Object Category | Sort-Object Name | ForEach-Object { Write-Host ($_.Name + "=" + $_.Count) }
