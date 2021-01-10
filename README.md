# opr.vc – open privacy

Wir bauen eine umfangreiche frei verfügbare Sammlung an Mustertexten für Datenschutzerklärungen auf. Diese sammeln wir in Docs, die unter opr.vc zu finden sind.

Wir sind überzeugt, dass die besten Ergebnisse in einer öffentlichen Diskussion entstehen und laden jeden Interessierten ein, sich zu beteiligen (https://github.com/oprvc/oprvc.github.io/discussions).

Für weitere Fragen stehen wir auf Twitter [@opr_vc](https://twitter.com/opr_vc) oder per E-Mail (info@opr.vc) zur Verfügung.

## Vorlage für die Erstellung neuer Docs
Für die Erstellung neuer Docs kann folgende Vorlage verwendet werden. Programmierkenntnisse sind nicht erforderlich.

```Markdown
---
title:                                // Name des Services/Plugins
subtitle: Informationen über          // Name des Services/Plugins
tags: [ ]                             // Bsp. newsletter, cdn, hosting, payment
vendorname:                           // Firmenname des Herstellers
addressline1:                         // Adresse (Zeile 1) des Herstellers
addressline2:                         // Adresse (Zeile 1) des Herstellers
country:                              // Land
ppurl:                                // URL Datenschutzerklärung (https://...)
dpaurl:                               // (optional) URL DPA (https://...)
sccurl:                               // (optional) URL SCC (https://...)
privacyemail: privacy@akamai.com
flag: us                              // derzeit nur eu/us
---

### Inhaltsverzeichnis
{:.no_toc}
* TOC
{:toc}                                // Inhaltsverzeichnis wird automatisch erstellt

### Mustertext Datenschutzerklärung   // ### Hauptüberschriften
**Name des Services**                 // **Überschrift** innerhalb Muster

### Technische Hinweise               // ### Hauptüberschrift
#### Unterüberschrift                 // #### Unterüberschrift außerhalb Muster
### Rechtliche Hinweise               // ### Hauptüberschrift

Bitte beachte, dass Umbrüche <br>, durch zwei Leerzeichen erzeugt werden. **Überschrift**  < 2 Leerzeichen
```