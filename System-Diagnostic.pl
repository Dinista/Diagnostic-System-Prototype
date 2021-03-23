% Escrever no arquivo.
:- use_module(library(readutil)).

:- use_module(library(plunit)).

:- dynamic paciente/4.

:- discontiguous doenca/3.

escrever_arquivo :-
   tell('c:\\pacientes.txt'),
   listing(paciente),
   told.

adicionar :-
    cls,
    writeln("Adicionando um paciente."),nl,
    writeln("Entre o nome do paciente: "),nl,
    read_line_to_string(user_input,Nome),nl,
    writeln("Entre o telefone dele:"),nl,
    read_line_to_string(user_input,Telefone),nl,
    ler_sintomas(Lista_Sintomas),
    assertz(paciente(Nome, Telefone, Lista_Sintomas, "Inexistente")),
    write("Paciente adicionado."),
    escrever_arquivo,
    get_char(_),
    init.


deletar :-
   cls,
   writeln("Deletando um paciente."),nl,
   writeln("Entre o nome: "),
   read_line_to_string(user_input,Nome),nl,
   call(paciente(Nome, _, _, _)), !,
   retract(paciente(Nome, _, _, _)),
   format("Deseja remover os dados do ~w? (y/n)", Nome), nl,
   readln(Op),
   (Op == [y] -> write("Paciente retirado."),
    get_char(_),
    escrever_arquivo,
    init;
   write("Cancelado."),
   get_char(_),
   init);
   write("Erro: Paciente n�o encontrado"),
   get_char(_),
   init.


consultar :-
   cls,
   writeln("Procurando informa��es de um paciente"),nl,
   writeln("Entre com o nome:"),nl,
   read_line_to_string(user_input,Nome),nl,
   call(paciente(Nome, T, S, D)), !,
   format("Nome: ~w", Nome),nl,
   format("Telefone: ~w", T),nl,
   write("Sintomas:"),nl,
   show_sint(S),nl,
   format("Diagn�stico: ~w", D),
   get_char(_),
   init;
   write("Paciente n�o encontrado"),
   get_char(_),
   init.

alterar :-
   cls,
   writeln("Alterando os dados de um paciente."),nl,
   writeln("Entre o nome:"),
   read_line_to_string(user_input,Nome),nl,
   call(paciente(Nome, T, S, D)) ->
   format("Deseja alterar os dados do ~w? (y/n)", Nome), nl,
   readln(Op),
   (Op == [y] ->
    retract(paciente(Nome,T, S, D)),
    format("Entre com o novo nome do paciente (Nome antigo : ~w): ", Nome),nl,
    read_line_to_string(user_input,NovoNome),nl,
    format("Entre com o novo telefone (Telefone antigo: ~w):", T),nl,
    read_line_to_string(user_input,NovoTelefone),nl,
    ler_sintomas(Lista_Sintomas),
    assertz(paciente(NovoNome, NovoTelefone, Lista_Sintomas, "Inexistente")),
    escrever_arquivo,
    write("Paciente alterado."),
    get_char(_),
    init;
    write("Cancelado"), init);
    write("Erro: Paciente n�o encontrado."), get_char(_), init.


diagnostico(Sintomas, L) :-
    setof(Resultado:Nome_Doenca, sintomas_comum(Sintomas,
    Nome_Doenca, Resultado), Probabilidade),
    reverse_list(Probabilidade, L),
    writeln("CONSIDERANDO OS SEUS SINTOMAS:"),
    writeln("-------------------------------------------------------------"),
    show_records(L).

sintomas_comum(Paciente_Sintoma, Nome_Doenca, Resultado):-
    doenca(Nome_Doenca, Sintomas, _),
    intersection(Paciente_Sintoma, Sintomas, Sintomas_comum),
    length(Sintomas_comum, NSC), %NSC = Numero de Sintomas em Comum.
    length(Sintomas, NSD),  % NSD = Numero de Sintomas da Doenca.
    Resultado is NSC / NSD * 100.

sintomas_comum_info(Paciente_Sintoma, Nome_Doenca, Sintomas_comum):-
   doenca(Nome_Doenca, Sintomas, _),
   intersection(Paciente_Sintoma, Sintomas, Sintomas_comum).

sintomas_out_info(Paciente_Sintoma, Nome_Doenca, Info):-
   doenca(Nome_Doenca, Sintomas, _),
   intersection(Paciente_Sintoma, Sintomas, Sintomas_comum),
   subtract(Sintomas, Sintomas_comum, Info).

ler_sintomas(Lista_Sintomas):-
   nl,
   writeln("Escreva os sintomas, separando-os com virgula e sem ponto final:"),
   read_line_to_string(user_input,Input),
   string_lower(Input, Saida),
   split_string(Saida, ",", " ", Lista_Sintomas),nl.

%Regras-�teis

switch(X, [Val:Goal|Cases]) :-
    ( X=Val ->
        call(Goal)
    ;
        switch(X, Cases)
    ).

cls :-
   write('\33\[2J'). %Limpa o console

reverse_list(L,L1):-
   reverse_list(L,[],L1).

reverse_list([],ACC,ACC).

reverse_list([X|L], ACC,L1):-
   reverse_list(L,[X|ACC],L1).

show_list([A|B]):-
   split_string(A, ".", "", T),
   first_elem(T, C),
   C \= "0" ->
   nl,format("~w% de chance", C),format(" de ser ~w.", B),nl;
   true.

show_records([]).

show_records([A|B]) :-
  format(atom(T), "~w", A),
  atom_string(T,X),
  split_string(X, ":", "", Saida),
  show_list(Saida),
  show_records(B).

first_elem([A|_],A).

show_sint([]).

show_sint([M|N]):-
   format("- ~w.",M),nl,
   show_sint(N).

%main

init :-
   ['c:\\Pacientes.txt'],
   cls,
   %writeln("-----------Menu----------"),nl,
   writeln("BEM-VINDO AO SISTEMA DE DIAGN�STICO DE SINTOMAS!"),nl,
   writeln("Escolha uma das op��es (sem ponto final):"),nl,
   writeln("1. Controle de Paciente."),nl,
   writeln("2. Diagn�stico."),nl,
   %writeln("-------------------------"),nl,
   readln(Op),
   cls,
   Op == [1] -> writeln("Escolha uma das op��es (sem ponto final):"),nl,
       writeln("1. Adicionar paciente."),nl,
       writeln("2. Pesquisar paciente."),nl,
       writeln("3. Alterar informa��es do paciente."),nl,
       writeln("4. Remover paciente."),nl,
       readln(CP),
       switch(CP, [[1] : adicionar,
                   [2] : consultar,
                   [3] : alterar,
                   [4] : deletar]);
   %Op == [2],
   writeln("Qual o nome do paciente que deseja diagnosticar?"),nl,
   read_line_to_string(user_input,Nome),nl,
   call(paciente(Nome, Tele, Paciente_Sintomas, D)) ->
   diagnostico(Paciente_Sintomas, A),
   first_elem(A, B),
   format(atom(T), "~w", B),
   atom_string(T,X),
   split_string(X, ":", "", Saida),
   first_elem(Saida, PBS),
   (   PBS \= "0" ->
   retract(paciente(Nome, Tele, Paciente_Sintomas, D)),
   reverse_list(Saida, S),
   first_elem(S, Doenca),
   sintomas_comum_info(Paciente_Sintomas, Doenca, Info_Comum),nl,
   writeln("-------------------------------------------------------------"),nl,
   format("A poss�vel doen�a segundo seus sintomas � a ~w.", Doenca), nl,nl,   doenca(Doenca,_,Y),
   format("A ~w ", Doenca), format(",sengundo pesquisa, tem probabilidade de ~w% de ocorr�ncia.", Y),nl, nl, nl,
   writeln("O RESULTADO DO PROT�TIPO � APENAS INFORMATIVO!"),
   writeln("O PACIENTE DEVE CONSULTAR UM M�DICO PARA OBTER UM DIAGN�STICO CORRETO E PRECISO."),nl,
   writeln("-------------------------------------------------------------"),nl,
   assertz(paciente(Nome, Tele, Paciente_Sintomas, Doenca)),
   escrever_arquivo,
   format("Deseja ter mais informa��es sobre a ~w? (y/n)", Doenca), nl,
   readln(Opc),
   (Opc == [y] ->
   nl, writeln("Sintomas em comum:"),nl,
   show_sint(Info_Comum),nl,
   writeln("Outros sintomas da doen�a:"),nl,
   sintomas_out_info(Paciente_Sintomas, Doenca, Info_dif),
   show_sint(Info_dif),nl,
   readln(_), init; init);
   nl,
   writeln("Nenhuma doen�a foi encontrada com seus sintomas."),nl,
   write("PROCURE UM M�DICO PARA OBTER UM DIAGN�STICO CORRETO E PRECISO."),
   get_char(_),
   init); write("Erro: Paciente n�o encontrado."), get_char(_), init.

% Doen�as - base de dados

doenca("Cefaleia", ["dor de cabe�a","sensibilidade a luz", "sensibilidade ao som", "sensibilidade ao cheiro","irritabilidade", "n�useas", "v�mito", "latejamento" , "dor"], 0.29).

doenca("Acidente vascular encef�lico(AVC)", ["fraqueza de um lado do corpo", "sensibilidade", "corpo", "dificuldade para falar", " dificuldade para comer", "perda da vis�o", "tontura", "desmaios", "altera��es motoras", "dist�rbio de linguagem"], 0.26).

doenca("Dorsalgia", ["pontadas", "queima��o na coluna", "dificuldade para respirar"], 0.10).

doenca("Dor precordial", ["dor no peito", "dor durante a respira��o", "falta de ar", "ansiedade"], 0.38).

doenca("Insufici�ncia card�aca",["tosse", "incha�o", "ganho de peso", "pulso irregular", "palpita��es", "ins�nia", "fadiga", "fraqueza", "desmaio", "indigest�o", "nn�useas", "v�mito"], 0.25).

doenca("Hipertens�o arterial", [ "dor de cabe�a", "falta de ar", "vis�o borrada","zumbido no ouvido", "tontura", "dores no peito"], 0.12).

doenca("Arritmia Card�aca", ["palpita��es no cora��o", "queda de press�o", "fadiga", "falta de ar","desmaios", "enjoos", "vertigem"], 0.08).

doenca("Lombalgia", ["dor na coluna", "dor na coxa", "fraqueza", "dificuldade em se movimentar"], 0.04).

doenca("Sinusite", ["obstru��o nasal", "secre��o nasal", "far�ngea amarelada","far�ngea esverdeada","tosse","dor de cabe�a","mal-estar", "cansa�o","irrita��o na garganta","redu��o do olfato", "febre alta"], 0.02).

doenca("Dispepsia",["dispneia","sudorese","taquicardia","anorexia","n�useas","v�mitos","perda ponderal","sangue nas fezes","disfagia","odinofagia"], 0.015).

%Testes Unit�rios

:- begin_tests(testes).

test(t0) :- diagnostico(["febre", "dor", "Abdomen"],  [11.11111111111111:"Cefaleia", 0:"Sinusite", 0:"Lombalgia", 0:"Insufici�ncia card�aca", 0:"Hipertens�o arterial", 0:"Dorsalgia", 0:"Dor precordial", 0:"Dispepsia", 0:"Arritmia Card�aca", 0:"Acidente vascular encef�lico(AVC)"]).

test(t1):- sintomas_comum(["febre", "dor", "Abdomen"], "Lombalgia", 0).

test(t2, X = ["dor"]):- sintomas_comum_info(["febre", "dor", "Abdomen"], "Cefaleia", X).

test(t3, X = ["v�mito", "ins�nia"]):- sintomas_comum_info(["v�mito", "ins�nia", "Abdomen"], "Insufici�ncia card�aca", X).

test(t4, X = ["queima��o na coluna", "dificuldade para respirar"]):- sintomas_out_info(["pontadas", "ins�nia", "Abdomen"], "Dorsalgia", X).

test(t5):- switch( 3, [1 :  false, 2 : false, 3 : true, 4 : false]).

test(t6):- reverse_list([1, 2, 3], [3, 2, 1]).

test(t8):- reverse_list([], []).

test(t7):- first_elem([1, 2, 3], 1).

test(t7):- first_elem(["ol�", "mundo"], "ol�").

:- end_tests(testes).
