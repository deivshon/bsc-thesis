# Presentation

## Slide 1

Buongiorno a tutti, mi chiamo Davide Cioni, sono qui per presentarvi il lavoro svolto per la tesi, un'analisi delle caratteristiche e trade-off del linguaggio Elm.

## Slide 2

Il Web oggi pervade le nostre vite, da social network a e-commerce a piattaforme di istruzione online. Le parti interattive della vasta maggioranza dei siti Web sono possibili grazie a JavaScript, il linguaggio di scripting del Web. JavaScript e' un linguaggio multi paradigma, tipato dinamicamente. Questa ultima caratteristica in particolare lo rende una scelta pericolosa per codebase di dimensioni significative su cui lavorano team di piu' sviluppatori. Le piu' basilari delle invarianti non sono codificate nel sistema di tipi e garantite da uno step di type-checking, devono essere invece mantenute attivamente dagli sviluppatori. Questo significa che semplici refactor possono generare seri errori che, se non rilevati durante una fase di controllo qualita', rischiano di arrivare in produzione.

## Slide 3

Elm nasce nel 2013, quando il linguaggio piu' usato per garantire interattivita' sul Web era JavaScript, o framework su di esso basati direttamente. Elm presenta un sistema di tipi statico, ed adotta completamente il paradigma funzionale. Elm e' infatti un linguaggio funzionale puro, che rende molto meno caotico il suo codice. In JavaScript le funzioni possono contenere qualsiasi tipo di side-effect, rendendolo poco prevedibile: l'unico modo di essere certi che una funzione non si comporti in modo inaspettato in questi termini e' analizzare il suo codice. In Elm, la firma di una funzione dice tutto cio' che e' necessario sapere di essa per un utlizzatore: i dati che acquisisce in input e i dati che restituisce in output, con la garanzia che questa sara' una trasformazione pura, senza side-effect. Elm offre inoltre interoperabilita' limitata con JavaScript, per evitare che il codice Elm possa essere influenzato dai suoi aspetti negativi.

## Slide 4

Gli obiettivi di design di Elm sono molteplici: anzitutto, si propone di eliminare quasi totalmente gli errori a runtime. Il runtime di Elm puo' crashare in condizioni estremamente rare, ma la vasta maggioranza degli errori che si incontrano in linguaggi come JavaScript sono completamente eliminati dal suo sistema di tipi statico. Come gia' citato, il codice Elm e' inoltre molto piu' prevedibile grazie al paradigma funzionale che Elm adotta completamente. Elm pone enfasi anche sulla semplicita', sia per quanto riguarda il processo di sviluppo, sia per quanto riguarda la fase di apprendimento del linguaggio. Conseguenza diretta e' il basso numero di keyword nel linguaggio, che riflette inoltre la mancanza di concetti avanzati come gli HKT (Higher Kinded Types) o le type classes, che sono invece parte di alcuni dei linguaggi piu' simili ad Elm.

## Slide 5

Senza dubbio una delle parti piu' importanti e innovative di Elm e' la Elm Architecture, un semplice flusso model-view-update che e' alla base di tutti i programmi Elm. Nella sua versione piu' basilare, vi sono solo 3 componenti, il model, la view e l'update. Il model rappresenta lo stato dell'applicazione, view e' una funzione pura che, dato il modello, restituisce la interfaccia utente nella forma del tipo Elm Htlm, una rappresentazione leggera dell'albero HTML che viene usata dal runtime di Elm per renderizzare in pagina quello reale. Vi e' infine la funzione update, che prende in input un messaggio (appartente a un tipo che e' quasi sempre un sum type), e lo stato corrente dell'applicazione. Dati questi due argomenti, la funzione update restituisce un nuovo stato dell'applicazione.

Il ciclo di base del runtime di Elm e' quindi:

-   Utilizzare la funzione view per renderizzare il DOM dato lo stato corrente
-   Ricevere un messaggio, computare il nuovo stato dato quello corrente ed il messaggio stesso
-   Passare il nuovo stato alla funzione view, ripetendo il ciclo

Una volta transpilato a JavaScript con il compilatore, Elm ripete questo ciclo all'infinito.

## Slide 6

La Elm architecture rende chiaro uno degli aspetti caratterizzanti di Elm: la assenza di componenti intesi come nella vasta maggioranza dei framework frontend e nella stessa Web Platform, per quanto riguarda i Web Components. In Elm non puo' esistere alcuna forma di stato locale, tutto e' centralizzato nel model, indipendentemente dalla posizione nell'albero in cui questo viene effettivamente usato. Questo crea situazioni peculiari rispetto alle altre soluzioni: poniamo di avere una serie di card a cui e' associata qualche tipo di azione che necessita' una chiamata API verso un server remoto, che necessariamente impieghera' qualche centinario di millisecondi. Una soluzione di design comune in questi casi e' inserire uno spinner che gira solo nel momento in cui non si e' ancora ricevuta una risposta dall'API. Per fare questo in un framework a componenti, e' sufficiente aggiungere una qualche variabile booleana locale che rappresenta lo stato di caricamento del componente. In Elm, questo stato deve per forza essere inserito nel model, per cui possono essere necessari refactor per permettere al tipo di dato associato alla card di contenere anche un booleano. Un'altra soluzione potrebbe invece essere inserire una mappa che va da stringa identificativa della card al suo stato di caricamento. In ogni modo in cui si decida di operare, al contrario di framework che supportano stato locale, non si tratta di una operazione a costo quasi-zero.
