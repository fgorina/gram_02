# gram_02

Partint de gram_01_android però actualitzant a la  versió de flutter 3.0.0 i modificant :

    - qr_scanner es substituit per mobile_scanner doncs hi havien llibreríes que ja no s'actuizaven
    - download_provider es substituit per android_external_storage

Modificiació de RoundButton e IndicatorButton per fer servir ElevatedButton doncs MateriaButton està deprecat

Encara hi ha codi deprecat però s'hau`` d'anar corregint.

S'han afegit a Git els fitxers que realment corresponen a l'aplicació i no els que ell genera automàticament. En principi un flutter create i 
un pull de github hauria de funcionar.

La id de l'aplicació continua sent gram_01`