Componenti del gruppo:

Bianchi Francesco 902251
Carbone Samuele 899661
Brighenti Stefano 900153

FILE README PROGETTO OOP PROLOG

______________________PRIMITIVE_______________________

DEF_CLASS:

Il predicato def_class permette all'utente di creare una nuova classe
nella base di conoscenza. 

Sintassi:
def_class '(' <ClassName> ',' <Parents> ')'
def_class '(' <ClassName> ',' <Parents> ',' <Parts> ')'

Codice
- La classe non deve essere gia' presente nella base di conoscenza
- ClassName deve essere un atomo
- Parents deve essere una lista di atomi
- Parts deve essere una lista.
- Parts e' una lista contente i campi(fields) e i metodi(methods) che
verranno separati tramite una partition utilizzando is_method 
- i campi vengono analizzati nella check_parts
- i metodi vengono analizzati nella is_valid_method
- i metodi vengono successivamente processati con la process_methods
- la classe viene asserita alla base di conoscenza.


MAKE

Il predicato della Make permette di creare una nuova istanza di una
classe. 
Ci sono 2 tipi di make: make/2 e make/3 -> make/2 si comporta come
make/3, ma considera Parts come lista vuota.
Inoltre ci sono 3 sotto-tipi di make/3:
- Se InstanceName e' un simbolo allora lo si associa alla base dati, al
termine che rappresenta la nuova istanza.
- Se InstanceName e' una variabile allora questa viene unificata con il
termine che rappresenta la nuova istanza.
- Altrimenti InstanceName deve essere un termine che unifica con la
nuova istanza creata.

Sintassi:
make '(' <InstanceName> ',' <ClassName> ',' <Parts> ')' 

Codice:
- Controllo che non esista gia' l'istanza che voglio creare
- InstanceName deve essere un atomo
- ClassName deve essere una classe
- Parts deve essere una lista
- analizzo gli elementi di Parts con check_parts_instance
- passo i field e i metodi delle classi e superclassi all'istanza
attraverso field_in_class_or_superclass 
- (caso 1) asserisco l'istanza alla base di conoscenza
- (caso 2) unifico InstanceName con il termine che rappresenta la
nuova istanza 
- (caso 3) unifico con la nuova istanza creata


IS_CLASS

Il predicato serve per vedere se la classe e' gia' presente nella base
di conoscenza 

Sintassi:
is_class '(' <ClassName> ')'

Codice:
- controllo che ClassName sia un atomo
- controllo che ClassName sia nella base di conoscenza


IS_INSTANCE

Il predicato controlla l'esistenza di un'istanza di una classe
is_instance/1 si comporta come is_instance/2, considerando ClassName
come una qualsiasi classe 

Sintassi:
is_instance '(' <Value> ')'
is_instance '(' <Value> ',' <ClassName> ')'

Codice:
- (is_instance/1) richiama l'is_instance/2 mettendo any come parametro
nella ClassName 
- Value deve essere un valore qualunque 
- controllo se l'istanza e' presente nella base di conoscenza
- in caso contrario controllo che sia un'istanza di una superclasse


INST

Recupera l'istanza creata dalla make attraverso il nome

Sintassi:
inst '(' <InstanceName> ',' <Instance> ')'

Codice:
- InstanceName deve essere un atomo
- recupero l'istanza dalla base di conoscenza
- associo instance all'istanza nella base di conoscenza


FIELD

Estrae il valore di un campo dalla classe

Sintassi:
field '(' <Instance> ',' <FieldName> ',' <Result> ')'

Codice:
- otteniamo l'istanza dalla inst
- (caso del field nell'istanza) controlliamo i field nell'istanza
(field_in_instance) 
- (caso del field nella classe o superclasse) controlliamo i field
nella classe o superclasse (field_in_class_or_superclass) 


FIELDX

Estrae il valore da una classe percorrendo un insieme di attributi
tramite la ricorsione 

Sintassi:
fieldx '(' <Instance> ',' <FieldNames> ',' <Result> ')'

Codice:
- Caso base: quando la lista dei FieldNames e' vuota
- Caso ricorsivo: richiama la field sul primo elemento di FieldNames e
applica la ricorsione sulla restante parte 

__________________ULTERIORI FUNZIONI__________________

CONTROLLO FIELD


CHECK_PARTS

Controlliamo tramite la ricorsione che tutti i field siano validi

Sintassi:
check_parts '(' <Fields> ',' <ClassName> ',' <Parents> ')'

Codice:
- Caso base: La lista di Fields e' vuota
- Caso ricorivo: controllo che l'elemento Field preso dalla lista
Fields sia valido con is_valid e richiamo la check_parts sul resto
della lista Fields 


CHECK_PARTS_INSTANCE

Controllo che i field delle istanze siano validi attraverso la
ricorsione 

Sintassi:
check_parts_instance '(' <Fields> ')

Codice:
- Caso base: la lista Fields e' vuota
- Caso ricorsivo: controllo che l'elemento Field preso dalla lista sia
valido con is_valid_instance e richiamo la check_parts sul resto della
lista Fields 


IS_VALID

E' un predicato che serve per controllare che i field passati siano
validi 

Sintassi:
is_valid '(' <Field> ',' <ClassName> ',' <Parents> ')'

Codice:
- controlliamo che field sia un predicato di arita' 3 
- gli argomenti di field vengono estratti e associati a delle
variabili su cui fare i vari controlli, controllando anche nelle
superclassi 
- Field e' composto da un FieldName, FieldValue ed eventualmente un FieldType
- FieldName deve essere un atomo
- FieldValue viene controllato da valid_value/1
- FieldType viene controllato insieme a FieldValue in valid_value/2 e
in caso FieldTyper fosse una classe e FieldValue un istanza viene
controllato FieldType che sia superclasse di FieldValue 
- Se FieldValue e' una chiamata alla creazione di un istanza si fanno
gli opportuni controlli e se risultano corretti viene creata l'istanza
- vengono anche controllati i Field delle superclassi
- vengono controllati anche le ampiezze dei field che non devono
essere piu' grandi di quelle della superclasse 


IS_VALID_INSTANCE

Controlla che i field dell'istanza siano validi

Sintassi:
is_valid_instance '(' <Field> ')'

Codice:
- gli argomenti di field vengono estratti e associati a delle
variabili su cui fare i vari controlli 
- FieldName deve essere un atomo
- FieldValue viene controllato con valid_value


VALID_VALUE

Controlla che tutti i valori passati siano consoni 

Sintassi:
valid_value '(' <Value> ')'
valid_value '(' <Value> ',' <FieldType> ')'
valid_value '(' <FieldType> '.' <Parents> ')'

Codice:
- valid_value/1 controlla che gli elementi siano accettati da Prolog
- valid_value/2 controlla che gli elementi siano accettati da Prolog e
che i type siano corretti 
- il terzo caso di valid_value controlla che Parent sia una
superclasse di FieldType attraverso is_superclass 
- se passo dei parametri any li genera e prende come riferimento
quelli della superclasse


EREDITARIETA'


ALL_SUPERCLASSES

Questo predicato trovs tutte le classi dirette e indirette della
classe passata 

Sintassi:
all_superclasses '(' <ClassName> ',' <Superclasses> ')'

Codice:
- utilizza findall per trovare tutte le classi dirette della classe
- utilizza findall per trovare tutte le classi indirette della classe
- concatena tutte le classi in una lista (Superclassi_dirette,
Superclassi_indirette, Superclasses) 


FIELD_IN_CLASS_OR_SUPERCLASS

field_in_class_or_superclass/2 e field_in_class_or_superclass/3
controllano che un campo esista in una classe o in una superclasse 

Sintassi:
field_in_class_or_superclass '(' <ClassName> ',' <Field> ')'
field_in_class_or_superclass '(' <Instance> ',' <FieldName> ',' <Result> ')'

Codice:
- (caso 1) si recupera il FieldName dal Field, si recupera Parts da
ClassName e si controlla che Field sia presente in Parts sia
considerando il valore sia indipendentemente dal valore, sia nelle
classi sia nelle superclassi 
- (caso 2) si recupera ClassName dall'istanza, si recuperano Partz dal
nome della classe e si controlla che Field sia presente in Parts sia
considerando il valore sia indipendentemente dal valore, sia nelle
classi sia nelle superclassi 


FIELD_IN_INSTANCE

Controlla che un field esista in un'istanza

Sintassi:
field_in_instance '(' <Instance> ',' <FieldName> ',' <Result> ')'

Codice:
- viene fatta una member per controllare che FieldName sia parte di
Parts, recuperato dall'istanza 


IS_SUPERCLASS

controlla che Superclass sia una superclasse di ClassName

Sintassi:
is_superclass '(' <ClassName> ',' <Superclass> ')' 

Codice:
- prende i parents da ClassName e controlla Superclass e' un parents
diretto 
- in caso non fosse diretto controlla i parents indiretti


CONTROLLO SUI TIPI


SUBTYPE

comprende una serie di fatti che difiniscono la gerarchia dei tipi in
prolog 

Sintassi:
subtype '(' <A> ',' <B> ')'
subtype '(' <A> ',' <A> ')'
subtype '(' <A> ',' <C> ')'

Codice:
- i primi 2 sono i casi base generalizzati 
- nel terzo caso se A e' sottotipo di B e B e' sottotipo di C allora A e'
sottotipo di C 


WIDER_TYPE

controlla l'ampiezza di un tipo di un field rispetto ad un altro

Sintassi:
wider_type '(' <A> ',' <B> ')'

Codice:
- si controlla che B sia sottotipo di A


FIELD_TYPE_NOT_WIDER_IN_SUBCLASS

Controlla che il tipo delle sottoclassi non sia piu' ampio del tipo
dello stesso campo delle superclassi 

Sintassi:
field_type_not_wider_in_subclass '(' <FieldName> ',' <SubclassParts>
',' <SuperclassName> ')' 

Codice:
- recupero le Parts dalla superclasse
- controllo che FieldName sia nei Parts delle sottoclassi e nelle
superclassi, recuperando i rispettivi tipi dei Field 
- controlla che il tipo della sottoclasse non sia piu' ambio del tipo
della superclasse 


GESTIONE DEI METODI


IS_METHOD

controlla che l'elemento sia un metodo

Sintassi:
is_method '(' <Method> ')'

Codice:
- controlla che Method passato sia un metodo tramite 


IS_VALID_METHODS

controlla che i metodi siano corretti

Sintassi:
is_valid_method '(' <Methods> ')'

Codice:
- Caso base: Lista vuota
- controlla che sia un metodo
- con arg prende il MethodName e l'arglist
- controlla che MethodName sia un atomoe che arglist sia una lista
- Caso ricorsivo: richiama is_valid_method sugli altri elementi della
lista 


REPLACE_THIS

rimpiazza tutte le occorrenze di "this" in una forma con il nome
dell'istanza 

Sintassi:
replace_this '(' <this> ',' <Instance> ',' <Term1> ',' <Term2> ')'

Codice:
- Controllo che i termini siano variabili e se lo sono allora non
rimpiazzo il this 
- sostituisco il this con Instance se il terzo argomento e' this
- Se term1 e' composto, lo scompone in funtore e argoment, sostituisce
this con Instance in ogni argomento, e costruisce un nuovo termine con
il funtore originale e i nuovi argomenti 
- se X non e' this non effettua alcuna sostituzione


REPLACE_THIS_LIST

richiama il replace this sui singoli elementi della lista 

Sintassi:
replace_this_list '(' <this> ',' <Instance> ',' <Terms1> ',' <Terms2> ')'

Codice:
- Caso base: se le liste Terms1 e terms2 sono vuote
- Caso ricorsivo: richiama replace_this sul primo elemento di Terms1 e
d Terms2, richiama ricorsivamente replace_this_list sul resto della
lista 


PROCESS_METHOD

Processa la lista di metodi e li aggiunge alla base di conoscenza per
poi essere chiamati attraverso la call_methods 

Sintassi:
process_methods '(' <ClassName>, <Methods> ')'

Codice:
- Caso base: la lista Methods e' vuota
- Caso ricorivo: recupero il metodo da Methods, controllo i vari
parametri di Method, MethodName e' un atomo, Arglist e' una lista,
asserisco alla base di conoscenza il metodo e richiamo process_methods
sul resto della lista. 


CALL_METHODS

Predicato utilizzato per chiamare un metodo su un'istanza o, se non
presente nella classe o nella superlcasse 
call_methods/2 richiama call_methods/4 ponendo Arglist e Form come
parametri any 

Sintassi:
call_methods '(' <InstanceName> ',' <MethodName> ',' <Arglist> ',' <Form> ')'

Codice:
- ottengo la classe dell'istanza
- ottengo le parts dell'istanza
- controllo che il metodo sia nella classe
- in caso non fosse nella classe si controlla che il metodo sia nelle
superclassi  
- rimpiazzo i this nel metodo
- il metodo viene applicato e chiamato

