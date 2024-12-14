# Presentation

## Slide 1

Buongiorno a tutti, mi chiamo Davide Cioni, sono qui per presentarvi il lavoro svolto per la tesi, un'analisi delle caratteristiche e trade-off del linguaggio Elm.

## Slide 2

Il Web oggi pervade le nostre vite, da social network a e-commerce a piattaforme di istruzione online. Le parti interattive della vasta maggioranza dei siti Web sono possibili grazie a JavaScript. JavaScript e' un linguaggio multi paradigma, tipato dinamicamente. Questa ultima caratteristica in particolare lo rende una scelta pericolosa per codebase di dimensioni significative su cui lavorano team di piu' sviluppatori. Le piu' basilari delle invarianti non sono codificate nel sistema di tipi e garantite da uno step di type-checking, devono essere invece mantenute attivamente dagli sviluppatori. Questo significa che semplici refactor possono generare seri errori che, se non rilevati durante una fase di controllo qualita', rischiano di arrivare in produzione.

## Slide 3

Elm nasce nel 2013, quando il linguaggio piu' usato per garantire interattivita' sul Web e' JavaScript, usato direttamente o con framework su di esso basati. Elm presenta un sistema di tipi statico, ed adotta completamente il paradigma funzionale. E' infatti un linguaggio funzionale puro, che rende molto meno caotico il suo codice. In JavaScript le funzioni possono contenere qualsiasi tipo di side-effect, rendendolo poco prevedibile: l'unico modo di essere certi che una funzione non si comporti in modo inaspettato in questi termini e' analizzare il suo codice. In Elm, la firma di una funzione dice tutto cio' che e' necessario sapere di essa per un utlizzatore: i dati che acquisisce in input e i dati che restituisce in output, con la garanzia che questa sara' una trasformazione pura, senza side-effect. Elm offre inoltre interoperabilita' limitata con JavaScript, per evitare che gli aspetti negativi di JavaScript in termini di robustezza possano influenzare anche il runtime di Elm.

## Slide 4

Gli obiettivi di design di Elm sono molteplici: anzitutto, si propone di eliminare quasi totalmente gli errori a runtime. Il runtime di Elm puo' crashare in condizioni estremamente rare, ma la vasta maggioranza degli errori che si incontrano in linguaggi come JavaScript sono completamente eliminati dal suo sistema di tipi statico. Come gia' citato, il codice Elm e' inoltre molto piu' prevedibile grazie al paradigma funzionale che Elm adotta completamente. Viene posta enfasi anche sulla semplicita', sia per quanto riguarda il processo di sviluppo, sia per quanto riguarda la fase di apprendimento del linguaggio. Conseguenza diretta e' la mancanza di concetti avanzati come gli HKT (Higher Kinded Types) o le type classes, che sono invece parte di alcuni dei linguaggi piu' simili ad Elm.

## Slide 5

Senza dubbio una delle parti piu' importanti e innovative di Elm e' la Elm Architecture, un semplice flusso model-view-update che e' alla base di tutti i programmi Elm. Nella sua versione piu' basilare, vi sono solo 3 componenti, il model, la view e l'update. Il model rappresenta lo stato dell'applicazione, view e' una funzione pura che, dato lo stato, restituisce la interfaccia utente nella forma del tipo Elm Htlm, una rappresentazione leggera dell'albero HTML che viene usata dal runtime di Elm per renderizzare in pagina quello reale. Vi e' infine la funzione update, che prende in input un messaggio (appartente a un tipo, anch'esso definito dall'utente, che e' quasi sempre un sum type), e lo stato corrente dell'applicazione. Dati questi due argomenti, la funzione update restituisce un nuovo stato dell'applicazione.

Il ciclo di base del runtime di Elm e' quindi:

-   Utilizzare la funzione view per renderizzare il DOM dato lo stato corrente
-   Ricevere un messaggio, computare il nuovo stato dato quello corrente ed il messaggio stesso
-   Passare il nuovo stato alla funzione view, ripetendo il ciclo

Una volta transpilato a JavaScript con il compilatore, Elm ripete questo ciclo all'infinito.

## Slide 6

La Elm architecture rende chiaro uno degli aspetti caratterizzanti di Elm: cioe' la assenza di componenti intesi come nella vasta maggioranza dei framework frontend e nella stessa Web Platform, con i Web Components. In Elm non puo' esistere alcuna forma di stato locale, tutto e' centralizzato nel model, indipendentemente dalla posizione nell'albero in cui questo viene effettivamente usato. Questo crea situazioni peculiari rispetto alle altre soluzioni: poniamo di avere una serie di elementi dell'interfaccia utente a cui e' associata qualche tipo di azione che necessita una chiamata API verso un server remoto, che necessariamente impieghera' qualche centinaio di millisecondi. Una soluzione di design comune in questi casi e' inserire uno spinner che gira solo nel momento in cui non si e' ancora ricevuta una risposta dall'API. Per fare questo in un framework a componenti, e' sufficiente aggiungere una qualche variabile booleana locale che rappresenta lo stato di caricamento del componente. In Elm, questo stato deve per forza essere inserito nel model, per cui possono essere necessari refactor per permettere al tipo di dato associato alla'elemento dell'interfaccia di contenere anche una ulteriore variabile booleana. Un'altra soluzione potrebbe invece essere inserire una mappa che data una stringa identificativa dell'elemento dell'interfaccia restituisce il suo stato di caricamento. In caso, al contrario di framework che supportano stato locale, non si tratta di una operazione a costo quasi-zero.

## Slide 7

Un altro aspetto peculiare di Elm e' la limitatezza della interoperabilita' con JavaScript. Non e' supportata nessuna FFI, sono invece altri due i metodi usati:

-   Web Components. E' possibile infatti definire componenti custom elements e usarli in Elm, ricevendo anche i messaggi che emettono
-   Porte. Questo e' il metodo piu' usato, e consiste in message passing tra JavaScript ed Elm.

## Slide 8

Per dettagliare il funzionamento delle porte in Elm e come queste si integrano nella Elm Architecture, e' necessario introdurne una versione piu' complessa che include altri concetti. Rispetto alla architettura precedente sono cambiate due cose:

-   La funzione di inizializzazione ora gestisce anche una funzione subscriptions, la quale ritorna valori del tipo Sub Msg, una subscription associata a un messaggio. In generale, e' necessario usare le subscriptions quando bisogna eseguire una azione dopo un certo evento che non puo' essere rilevato in altri modi dal runtime di Elm. Ad esempio, un cambiamento dello stato che deve avvenire periodicamente sarebbe associata ad un messaggio che viene mandato ogni N secondi da una subscription.
-   La funzione update ora restituisce non solo un nuovo model, ma anche un comando associato ad un messaggio (Cmd Msg). Questo e' necessario quando, in seguito alla computazione del nuovo stato, e' necessario eseguire una funzione che non e' una semplice ulteriore trasformazione dello stato, ma ad esempio una chiamata API.

## Slide 9

Le porte si usano con comandi e subscriptions. Nello specifico, definendo una porta per messaggi da Elm a JavaScript, questa sara' usabile nella funzione update per produrre un comando. Il runtime di Elm quando questo viene eseguito, chiama la funzione con lo stesso nome definita su JavaScript con gli argomenti passatigli. Per quanto riguarda le prote che producono messaggi da JavaScript ad Elm, queste sono invece funzioni che restituiscono una subscription associata ad un messaggio, la quale deve essere passata alla funzione init per rendere noto al runtime di Elm che, quando da JavaScript viene chiamata la corrispettiva funzione, deve essere mandato il messaggio associato contenente gli argomenti relativi.

## Slide 10

Concludendo, Elm risulta quindi essere una soluzione che garantisce runtime safety piu' alta di quasi ogni altra, buone performance a client e una architettura semplice ma profondamente espressiva, tutto nel contesto del paradigma funzionale puro. Ciononostante, non avere supportato nativamente tutte le API della Web Platform unito al fatto che la interoperabilita' con JavaScript, a meno di elementi custom, deve sempre passare per message passing, rendono alcune operazioni piu' complesse rispetto a quello che risulterebbero usando altri strumenti. La assenza di componenti e conseguente impossibilita' di incapsulare lo stato puo' complicare la sua gestione in applicazioni di dimensioni significative. Per questi motivi, Elm si configura come un linguaggio di nicchia, utile per applicazioni con requisiti specifici ma meno flessibile della maggioranza delle soluzioni ad esso alternative. Tuttavia, e' stato una importante fonte di ispirazione per progetti che sarebbero in seguito diventati importanti e molto diffusi, come Redux, una libreria di state management per React che e' stata la piu' utilizzata per molto tempo, ed il cui funzionamento e' basato sulla Elm Architecture. Elm ha inoltre contribuito in modo positivo al trend generale osservabile nel mondo frontend che, dall'inizio degli anni 2010 ad oggi ha portato alla sempre maggiore diffusione linguaggi e soluzioni dove l'affidabilita' e' un interesse centrale.
