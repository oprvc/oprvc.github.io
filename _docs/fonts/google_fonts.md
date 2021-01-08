---
title: Google Fonts
subtitle: Informationen über Google Fonts
tags: [fonts]
---
### Inhaltsverzeichnis
{:.no_toc}
* TOC
{:toc}

### Technische Hinweise  
#### Google Fonts über Google Server einbinden
Grundsätzlich gilt, mit dem Aufruf der Website und dem Anfordern der Schriftart, wird die IP-Adresse des Nutzers auf Google Servers außerhalb der Europäischen Union übertragen. Laut Google werden für die Erfassung unabhängige Server vorgehalten (fonts.gstatic.com und fonts.googleapis.com) und eine Zusammenführung mit Daten aus anderen Diensten fände nicht statt. Google verwendet diese Informationen für Analysezwecke und führt diese mit Daten des Webcrawlers zusammen. Cookies werden nicht gesetzt. Es werden lediglich die Schriftarten (1 Jahr) und die zugehörigen CSS-Dateien (1 Tag) auf dem Endgerät des Nutzers gespeichert. Google sieht sich im Rahmen der Google Fonts in der Rolle des Verantwortlichen. Ein Auftragsverarbeitungsvertrag ist demnach nicht erforderlich. [siehe Google Fonts API Dokumentation](https://developers.google.com/fonts/faq#what_does_using_the_google_fonts_api_mean_for_the_privacy_of_my_users)

#### Google Fonts über Consent Management Lösung einbinden
Es besteht die Möglichkeit, Google Fonts über ein Consent Management Tool einzubinden. Der Vorteil ist, dass man die Schriftarten nicht lokal einbinden und updaten muss, da die Auslieferung über Google erfolgt, denn technisch besteht kein Unterschied zur Einbindung über die Google Server. Es sollte sichergestellt werden, dass die Schriftarten erst nach Einwilligung des Nutzers geladen werden. Nachteil ist, dass man die Übersichtlichkeit im Rahmen der Einwilligung reduziert, und sollte diese verweigert werden, kann es zu Darstellungsproblemen kommen.

#### Google Fonts lokal einbinden
Die vorzuziehende Möglichkeit ist, Google Fonts lokal einzubinden, sodass Schriftarten nicht mehr von den Google Servern geladen werden und die IP-Adresse des Nutzers nicht mehr übertragen wird. Diese Lösung erhöht den Aufwand, kann zu Performance-Einbußen führen und ist pflegebedürftiger, jedoch aus datenschutzrechtlicher Sicht überzeugend.

### Juristische Hinweise
#### Einbindung über Google Server
Es ist davon auszugehen, dass eine Einbindung über die Google Server nicht vom berechtigten Interesse (Art. 6 Abs. 1 lit. f) des Websitebetreibers gedeckt ist. Zwar hat dieser ein Interesse daran, dass seine Seite optisch ansprechend ist und die Auslieferung der Schriften optimiert wird. Das Interesse des Nutzers, dass seine IP-Adresse und weitere Daten nicht von Google verarbeitet werden, wird aber überwiegen. Zumal es technisch nicht möglich ist, wie bei Google Analytics die IP-Adresse zu anonymisieren, da sonst die Schriftarten nicht ausgeliefert werden können, und alternative Einbindungsmöglichkeiten zur Verfügung stehen. Darüber hinaus ist keine praktische Möglichkeit ersichtlich, wie ein Widerspruch gegen die Verarbeitung realisiert werden sollte.

#### Einbindung über Consent Management Lösung
Eine Einbindung über eine Consent Management Lösung ist mit Einwilligung des Nutzers (Art. 6 Abs. 1 lit. a) denkbar. Dies setzt die technische Umsetzung, Aufklärung des Nutzers und einen aussagekräftigen Passus in der Datenschutzerklärung voraus. Ein Restrisiko bleibt jedoch, da Google im Rahmen der Datenschutzerklärung und API-Dokumentation nicht nachvollziehbar offenlegt, wie die gesammelten Daten verarbeitet werden.

#### Google Fonts lokal einbinden
Da bei dieser Lösung keine Verbindung zu Google Servern hergestellt werden muss, da die Verarbeitung auf den eigenen Servern stattfindet, ist weder die Aufklärung des Nutzers noch die Erwähnung in der Datenschutzerklärung erforderlich.

Weitere Informationen unter: [https://policies.google.com/privacy](https://policies.google.com/privacy)