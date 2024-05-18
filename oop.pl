%%%% -*- Mode: Prolog -*-

%%%%Bianchi Francesco 902251

%%%%componenti del gruppo
%%%%Carbone Samuele 899661
%%%%Brighenti Stefano 900153

%Il predicato :- dynamic indica che il seguente predicato e' un
%predicato dinamico  
:- dynamic class/3.
:- dynamic instance/3.

%il predicato def_class definisce la struttura di una classe
%def_class/2 e' il caso dove considera la lista parts come una lista
%vuota 
%def_class/3 attua tutti i conrolli


def_class(ClassName, Parents) :-
    def_class(ClassName, Parents, []).

def_class(ClassName, Parents, Parts) :-
    %vengono applicati dei controlli in modo per la creazione della
    %classe 
    not(is_class(ClassName)), 
    !,
    atom(ClassName),
    is_list(Parents),
    maplist(atom, Parents),
    is_list(Parts),
    %divide i fields dai metodi
    partition(is_method, Parts, _, Fields), 
    partition(is_method, Parts, Methods, _),
    is_valid_methods(Methods),
    %parte la gestione dei metodi
    process_methods(ClassName, Methods),
    %controlla che i fields siano validi
    check_parts(Fields, ClassName, Parents),
    assertz(class(ClassName, Parents, Parts)),
    !.

%make/2 e make/3 creano una nuova istanza di una classe,
%make/2 si invoca make/3 considerando parts come una lista vuota

make(InstanceName, ClassName) :-
    make(InstanceName, ClassName, []).

%InstanceName e' un simbolo e quindi lo associamo nella base di
%conoscenza al termine che rappresenta la nuova istanza

make(InstanceName, ClassName, Parts) :-
    %controlli prima della creazione dell'istanza
    not(is_instance(InstanceName, ClassName)),
    !,
    atom(InstanceName),
    is_class(ClassName),
    is_list(Parts),
    check_parts_instance(Parts),
    !,
    %applichiamo field_in_class_or_superclass a tutti gli elementi di
    %Parts per poi asserire l'istamza nella base di conoscenza
    maplist(field_in_class_or_superclass(ClassName), Parts),
    assertz(instance(InstanceName, ClassName, Parts)).

%InstanceName e' una variabile allora la unifichiamo con il
%termine che rappresenta la nuova istanza

make(InstanceName, ClassName, Parts) :-
    not(is_instance(InstanceName, ClassName)),
    !,
    var(InstanceName),
    is_class(ClassName),
    is_list(Parts),
    check_parts_instance(Parts),
    !,
    maplist(field_in_class_or_superclass(ClassName), Parts),
    InstanceName = instance(InstanceName, ClassName, Parts).

%Altrimenti <InstanceName> deve essere un termine che unifica con la
%nuova istanza appena creata

make(InstanceName, ClassName, Parts) :-
    not(is_instance(InstanceName, ClassName)),
    !,
    nonvar(InstanceName),
    is_class(ClassName),
    is_list(Parts),
    check_parts_instance(Parts),
    maplist(field_in_class_or_superclass(ClassName), Parts),
    InstanceName = instance(_, ClassName, Parts).

%is_class/1 controlla che la classe esista

is_class(ClassName) :-
    atom(ClassName), 
    class(ClassName, _, _).

%is_instance/1 richiama is_instance/2 considerando qualsiasi ClassName
%is_instance/2 controlla che l'istanza di una classe esita 

is_instance(Value) :-
    is_instance(Value, _).

is_instance(Value, ClassName) :-
    atom(Value),
    instance(Value, InstanceClassName, _),
    InstanceClassName = ClassName.

is_instance(Value, ClassName) :-
    atom(Value),
    instance(Value, InstanceClassName, _),
    is_superclass(InstanceClassName, ClassName).

%inst/2 recupera un'istanza dato InstanceName e Instance, InstanceName
%e' un atomo e Instance e' un termine o una variabile logica che
%rappresenta un'istanza

inst(InstanceName, Instance) :-
    instance(InstanceName, ClassName, Parts),
    atom(InstanceName),
    Instance = instance(InstanceName, ClassName, Parts).

%field/3 estrae il valore di un campo da una classe se non presente
%nell'istanza controlla nella classe o nelle superclassi

field(InstanceName, FieldName, Result) :-
    atom(InstanceName),
    inst(InstanceName, Instance),
    field_in_instance(Instance, FieldName, Result),
    !.

field(InstanceName, FieldName, Result) :-
    atom(InstanceName),
    inst(InstanceName, Instance),
    field_in_class_or_superclass(Instance, FieldName, Result),
    !.

field(instance(InstanceName, _, _), FieldName, Result) :-
    inst(InstanceName, Instance),
    field_in_instance(Instance, FieldName, Result),
    !.

field(instance(InstanceName, _, _), FieldName, Result) :-
    inst(InstanceName, Instance),
    field_in_class_or_superclass(Instance, FieldName, Result),
    !.

%fieldx/3 estrare il valore da una classe percorrendo un insieme di
%simboli 

%Caso base:
fieldx(_, [], []).

%Caso ricorsivo:
fieldx(Instance, [FieldName|FieldNames], [Result|Results]) :-
    field(Instance, FieldName, Result),
    fieldx(Instance, FieldNames, Results).



%predicati utili per una gestione piu' agevole dei metodi precedenti


%gestione dei fields

%check_parts/3 controlliamo che i vari elementi di Parts siano field
%validi 

%Caso base:
check_parts([], _, _).

%Caso ricorsivo:
check_parts([Field|Fields], ClassName, Parents) :-
    is_valid(Field, ClassName, Parents),
    check_parts(Fields, ClassName, Parents).

%check_parts_instance/1 controlla che i field delle istanze siano
%validi 

%Caso base:
check_parts_instance([]).

%Caso ricorsivo:
check_parts_instance([Field|Fields]) :-
    is_valid_instance(Field),
    check_parts_instance(Fields).

%is_valid/3 controlla che field sia valido:
%functor controlla che esista un funtore field di arita' n (in base
%alle necessita')
%arg accede agli argomenti di field estraendoli e associandoli a delle
%variabili su cui fare i controlli successivamente, controllando anche
%nelle superclassi 


is_valid(Field, _, _) :-
    functor(Field, field, 2),
    arg(1, Field, FieldName),
    atom(FieldName),
    arg(2, Field, Value),
    valid_value(Value).

is_valid(Field, _, Parents) :-
    functor(Field, field, 3),
    arg(1, Field, FieldName),
    atom(FieldName),
    arg(2, Field, FieldValue),
    valid_value(FieldValue),
    arg(3, Field, FieldType),
    valid_value(FieldType, Parents).

is_valid(Field, _, Parents) :-
    functor(Field, field, 3),
    arg(1, Field, FieldName),
    atom(FieldName),
    arg(2, Field, FieldValue),
    arg(3, Field, FieldType),
    valid_value(FieldType, Parents),
    call(FieldValue).

is_valid(Field, ClassName, Parents) :-
    functor(Field, field, 3),
    arg(1, Field, FieldName),
    atom(FieldName),
    arg(2, Field, Value),
    arg(3, Field, Type),
    %controlla che parents non sia vuota e che il tipo di field non
    %sia piu' ampio nella sottoclasse
    once((Parents \= [],
	  field_type_not_wider_in_subclass(FieldName,
					   [field(FieldName, Value,
						  Type)], ClassName)
	 )),
    !,
    valid_value(Value, Type).

is_valid(Field, _, Parents) :-
    Parents == [],
    functor(Field, field, 3),
    arg(1, Field, FieldName),
    atom(FieldName),
    arg(2, Field, Value),
    arg(3, Field, Type),
    valid_value(Value, Type).



%is_valid_instance/1 controlla che i field dell'istanza siano validi

is_valid_instance(Field) :-
    arg(1, Field, FieldName),
    atom(FieldName),
    arg(2, Field, Value),
    valid_value(Value).

%valid_value/1 e valid_value/2 controllano che i valori passati siano
%consoni 

valid_value(Value) :- is_instance(Value).
valid_value(Value) :- atom(Value).
valid_value(Value) :- number(Value).
valid_value(Value) :- string(Value).
valid_value(Value, 'integer') :- integer(Value).
valid_value(Value, 'atom') :- atom(Value).
valid_value(Value, 'float') :- float(Value).
valid_value(Value, 'string') :- string(Value).
valid_value(FieldType, [Parent|Parents]) :-
    is_list(Parents),
    is_class(Parent),
    is_class(FieldType),
    is_superclass(Parent, FieldType).



%ereditarieta'
%Ottenere le parti ereditate dalle classi genitore creare una lista di
%tutte le superclassi di una classe 
%Questa funzione viene applicata a ciascun elemento di "Parents"

%all_superclasses/2 trova tutte le superclassi dirette e indirette
%della classe passata e le unisce tutte in una lista

all_superclasses(ClassName, Superclasses) :-
    findall(Parent,(class(ClassName, Parents, _),
		    member(Parent, Parents)), DirectSuperclasses),
    findall(IndirectSuperclass
	    , (member(DirectSuperclass, DirectSuperclasses),
	       all_superclasses(DirectSuperclass, IndirectSuperclasses
			       ), member(IndirectSuperclass,
					 IndirectSuperclasses)),
	    IndirectSuperclasses),
    append(DirectSuperclasses, IndirectSuperclasses, Superclasses).

%field_in_class_or_superclass/2 controlla se un campo esiste in una
%classe o in una superclasse

%controlla se un field con un certo nome e valore esiste nella classe
%e se il valore e' valido
field_in_class_or_superclass(ClassName, Field) :-
    Field =.. [=, FieldName, FieldValue],
    class(ClassName, _, Parts),
    member(field(FieldName, _, FieldType), Parts),
    valid_value(FieldValue, FieldType).

%controlla che esista il field nella classe indipendentemente dal
%valore 
field_in_class_or_superclass(ClassName, Field) :-
    Field =.. [=, FieldName, _],
    class(ClassName, _, Parts),
    member(field(FieldName, _), Parts).

%controlla se un field con un certo nome e valore esiste nelle
%superclassi della classe passata come argomento 
field_in_class_or_superclass(ClassName, Field) :-
    Field =.. [=, FieldName, FieldValue],
    all_superclasses(ClassName, Superclasses),
    member(Superclass, Superclasses),
    class(Superclass, _, Parts),
    member(field(FieldName, _, FieldType), Parts),
    valid_value(FieldValue, FieldType).

%controlla che esista il field in una delle superclassi della classe
%passata come argomento indipendentemente dal valore
field_in_class_or_superclass(ClassName, Field) :-
    Field =.. [=, FieldName, _],
    all_superclasses(ClassName, Superclasses),
    member(Superclass, Superclasses),
    class(Superclass, _, Parts),
    member(field(FieldName, _), Parts).

%field_in_class_or_superclass/3 differisce da
%field_in_class_or_superclass/2 nei parametri in quanto viene cercata
%la classe partendo dall'istanza 

field_in_class_or_superclass(instance(_, ClassName, _), FieldName,
			     Result) :-
    class(ClassName, _, ClassParts),
    member(field(FieldName, Result, _), ClassParts).


field_in_class_or_superclass(instance(_, ClassName, _), FieldName,
			     Result) :-
    all_superclasses(ClassName, Superclasses),
    member(Superclass, Superclasses),
    class(Superclass, _, SuperclassParts),
    member(field(FieldName, Result, _), SuperclassParts).

field_in_class_or_superclass(instance(_, ClassName, _), FieldName,
			     Result) :-
    class(ClassName, _, ClassParts),
    member(field(FieldName, Result), ClassParts).

field_in_class_or_superclass(instance(_, ClassName, _), FieldName,
			     Result) :- 
    all_superclasses(ClassName, Superclasses),
    member(Superclass, Superclasses),
    class(Superclass, _, SuperclassParts),
    member(field(FieldName, Result), SuperclassParts).

%field_in_instance/3 controlla che un determinato field esista in una
%determinata istanza
field_in_instance(instance(_, _, Parts), FieldName, Result) :-
    member(FieldName = Result, Parts).



%is_superclass/2 controlla che Superclass sia superclasse di ClassName
%controllando anche le Superclassi indirette
is_superclass(ClassName, Superclass) :-
    class(ClassName, Parents, _),
    member(Superclass, Parents).

is_superclass(ClassName, Superclass) :-
    class(ClassName, Parents, _),
    member(Parent, Parents),
    is_superclass(Parent, Superclass).



%la gerarchia dei tipi numerici


%subtype
subtype(integer, number).
subtype(integer, rational).
subtype(rational, float).

%un tipo e' un sottotipo di se stesso

subtype(X, X).

%Se un tipo A e' un sottotipo di B, e B e' un sottotipo di C, allora A
%e' sottotipo di C

subtype(A, C) :-
    subtype(A, B),
    subtype(B, C).

%wider_type/2 un tipo e' piu' grande di un altro se l'altro e'
%sottotipo di esso 

wider_type(A, B) :- subtype(B, A).

%field_type_not_wider_in_subclass/3 controlla che il tipo delle
%sottoclassi non sia piu' ampio del tipo dello stesso campo delle
%superclassi 

field_type_not_wider_in_subclass(FieldName, SubclassParts,
				 SuperclassName) :-
    class(SuperclassName, _, SuperclassParts),
    member(field(FieldName, _, SubclassFieldType), SubclassParts),
    member(field(FieldName, _, SuperclassFieldType), SuperclassParts),
    not(wider_type(SubclassFieldType, SuperclassFieldType)).


%Gestioni dei metodi


%is_method/1 controlla che un elemento di Part sia un metodo

is_method(Method) :- functor(Method, method, _).

%is_valid_methods/1 controlla che i metodi siano corretti

%Caso base:
is_valid_methods([]).

%Caso ricorsivo
is_valid_methods([Method|Methods]) :-
    functor(Method, method, _),
    arg(1, Method, MethodName),
    atom(MethodName),
    arg(2, Method, Arglist),
    is_list(Arglist),
    is_valid_methods(Methods).


%replace_this/4 rimpiazza tutte le occorrenze di "this" in una forma
%con il nome dell'istanza

replace_this(_, _, X, X) :- var(X), !.

replace_this(this, Instance, this, Instance) :- !.

replace_this(this, Instance, Term1, Term2) :-
    compound(Term1),
    Term1 =.. [Functor|Args1],
    replace_this_list(this, Instance, Args1, Args2),
    Term2 =.. [Functor|Args2].

replace_this(this, _, X, X) :- X \= this.

%replace_this_list/4 richiama il replace_this/4 sui singoli elementi
%della lista

%Caso base:
replace_this_list(_, _, [], []).

%Caso ricorsivo:
replace_this_list(this, Instance, [H1|T1], [H2|T2]) :-
    replace_this(this, Instance, H1, H2),
    replace_this_list(this, Instance, T1, T2).

%process_methods/2 processa la lista di metodi e li aggiunge alla
%base di conoscenza per poi essere richimati in call_methods/4

%Caso base:
process_methods(_, []).

%Caso ricorsivo:
process_methods(ClassName, [method(MethodName, Arglist, Form)|Methods]) :- 
    %MethodName e' un atomo
    atom(MethodName),
    %Arglist e' una lista
    is_list(Arglist),
    MethodArgs = [InstanceName|Arglist],
    Method =.. [MethodName|MethodArgs],
    assertz(Method :- call_methods(InstanceName, MethodName, Arglist,
				   Form)),
    process_methods(ClassName, Methods).

%call_methods/2 si applica a call_methods/4 ponendo gli ultimi 2
%parametri come any

%call_methods/4 e' un predicato utilizzato per chiamare un metodo su
%un'istanza o, se non presente, nella classe o nella superclasse

call_methods(InstanceName, MethodName):-
    call_methods(InstanceName, MethodName, _, _).

call_methods(InstanceName, MethodName, Arglist, Form) :-
    %ottengo la classe dell'istanza
    inst(InstanceName, instance(_, ClassName, _)),
    %ottengo le parts della classe
    class(ClassName, _, Parts),
    %controllo che il metodo sia nella classe
    member(method(MethodName, Arglist, Form), Parts), 
    replace_this(this,InstanceName, Form, NewForm),
    call(NewForm),
    !.

call_methods(InstanceName, MethodName, _, _) :-
    %ottengo la classe dell'istanza
    inst(InstanceName, instance(_, ClassName, _)),
    %ottengo le parts della classe
    class(ClassName, _, Parts),
    %controllo che il metodo sia nella classe
    member(method(MethodName, _, Form), Parts),
    replace_this(this, InstanceName, Form, NewForm),
    call(NewForm),
    !.

call_methods(InstanceName, MethodName, Arglist, Form) :-
    %ottieni la classe dell'istanza
    inst(InstanceName, instance(_, ClassName, _)), 
    all_superclasses(ClassName, Superclasses),
    member(Superclass, Superclasses),
    class(Superclass, _, SuperclassParts),
    %controlla che il tipo sia nella superclasse
    member(method(MethodName, Arglist, Form), SuperclassParts), 
    replace_this(this, InstanceName, Form, NewForm),
    call(NewForm),
    !.

call_methods(InstanceName, MethodName, _, _) :-
    %ottieni la classe dell'istanza
    inst(InstanceName, instance(_, ClassName, _)),
    all_superclasses(ClassName, Superclasses),
    member(Superclass, Superclasses),
    class(Superclass, _, SuperclassParts),
    %controlla che il metodo sia nella superclasse
    member(method(MethodName, _, Form), SuperclassParts),
    replace_this(this, InstanceName, Form, NewForm),
    call(NewForm),
    !.

%%%% end of file -- oop.pl --
