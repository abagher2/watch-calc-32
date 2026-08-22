# WatchCalc32 Packaging & Dielines

This directory contains the physical packaging designs, dielines, and concepts for WatchCalc32. Our packaging strategy employs a dual-box system tailored for both Direct-to-Consumer (D2C) e-commerce and traditional retail channels.

## 1. D2C Mailer Box
For our Amazon and D2C online sales, we use a minimalist, eco-friendly corrugated mailer.

- **Objective:** Survive shipping, reduce environmental impact, and provide a rebellious unboxing experience.
- **Design:** Kraft brown cardboard with bold, edgy black typography.
- **Slogan:** "Ditch the Equals Sign."
- **Internal:** Custom high-density foam insert cut to the exact chassis dimensions.
- **Concept Image:** ![D2C Mailer Concept](mailer_box_concept.jpg)

## 2. Retail Display Box
For physical store shelves (e.g., Walmart, office supply stores), we use a high-gloss tuck-end box designed to pop off the shelf and appeal to students/teenagers.

- **Objective:** Maximum shelf appeal, highlight the modern UI, and clearly differentiate from boring legacy calculators.
- **Design:** Dark mode aesthetics with vibrant neon/tech accents. Features high-res screenshots of the equation editor and plot view.
- **Interactive:** Large QR code on the front linking directly to the companion app/tutorials.
- **Slogan:** "Ditch the Equals Sign."
- **Concept Image:** ![Retail Box Concept](retail_box_concept.jpg)

## 3. Production Specs & Cost of Goods Sold (COGS)
To achieve our target retail price of **$10–$15**, the total manufacturing cost (COGS) must remain strictly under **$4.00 per unit** to allow for 3PL, freight, and retail margins.

### BOM Target Breakdown ($3.50 total):
- **MCU:** CH32V or RP2040 (~$0.15 - $0.70)
- **Display:** 1.8" Monochrome Graphic LCD SPI (~$0.85)
- **Keypad:** Silicone dome membrane keypad with printed plastic caps (~$0.40)
- **Chassis:** Injection-molded ABS plastic (~$0.50)
- **Packaging:** 300gsm tuck-end box with molded pulp tray (more sustainable and cheaper than EVA foam) (~$0.30)
- **PCBA & Assembly Labor:** (~$0.60)

*Note: We cannot use premium mechanical keyboard switches or full-color OLED screens without breaking this strict budget constraint.*

## Next Steps for Production
1. **Dieline Generation:** Once the final chassis dimensions are locked in `Hardware/designs/chassis.scad`, we will generate 2D `.dxf` / `.ai` dielines for the box fold patterns based on the 300gsm tuck-end spec.
2. **Pulp Tray Routing:** Generate step files for the internal molded pulp tray so the manufacturer can press the exact cutout for the calculator and charging cable.
3. **Artwork Layout:** Apply the high-res marketing renders to the flattened dielines for printing.
