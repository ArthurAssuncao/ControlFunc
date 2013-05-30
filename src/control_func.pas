Program trabalho;

uses crt, dos;

const ident=5; {identacao(recuo) das opcoes dos procedures}
	  linha=5; {linha do primeiro item}
	  max_linhas_terminal = 23; {windows == 24 e linux == 23}

type 
	 tregfunc = record
				matricula, codigoDepartamento : integer;
				nome : string[30];
				dia,mes,ano: word;
				CPF: string[11]; {xxxxxxxxxxx - so numeros}
				salario : real;
				rua, bairro, cidade, email: string[30];
				numeroCasa:integer;
				complemento:string[5];
				estado: string[2]; {apenas a sigla do estado}
				telefone: integer;
				datacontratacao : string;
			   end;
			   
	 tregdep = record
				codigo, codigogerente:integer;
				nome:string[30];
				ramal:string[6];
			   end;
			   
	treg_hist_sal = record
					matricula :  integer;
					salario : real;
					mes,ano : word;
				  end;
				  
	TReg_Hist_Func = record
					matricula,codigoDepartamento:integer;
					data:string[10];
				end;
					
    TReg_Hist_Dep = record
					codigoDepartamento,codigoGerente:integer;
					data:string[10];
				end;
	 
			   
	tarqdep = file of tregdep;	
	tarqfunc = file of tregfunc;
	tarq_hist_sal = file of treg_hist_sal;
	tarq_hist_func = file of TReg_Hist_Func;
	tarq_hist_dep = file of TReg_Hist_dep;
	
		
var arqdep : tarqdep;
	arqfunc : tarqfunc;
	arqhist_sal : tarq_hist_sal;
	arqhist_func : tarq_hist_func;
	arqhist_dep : tarq_hist_dep;
	x, l, i, j, k, m:integer;
	tecla:char;
	{op:char;} opcao:integer;
	Dia, Mes, Ano, Hora, Minuto, Segundo, Dec_Segundo, Dia_Semana : word;{ para ser usado no getDate}


{Procedimentos do menu}
procedure mudacor;
begin
	textbackground(3);
	textcolor(15);
end;

procedure voltacor;
begin
	textcolor(lightgreen);
	textbackground(0);
end;
{fim procedimentos menu}

{Fundo branco dos readln}
procedure espaco(c,l,tamanho:integer);

var i:integer;

begin
	gotoxy(c,l);
	textbackground(lightgray);
	for i:=1 to tamanho do
		write(' ');
	textcolor(0);
	gotoxy(c,l);
	{tem q colocar voltacor depois do readln}
end;

{TITULO}
procedure titulo(frase:string);

var l:integer;

begin
	textcolor(lightgreen);
	for l:=1 to 80 do
		write('_');
	textcolor(lightred);
	gotoxy(20,2);
	writeln(frase);
	voltacor;
	for l:=1 to 80 do
		write('_');
	writeln;
end;

{QUER SAIR}
procedure quersair(var sair:char);

begin
repeat
	gotoxy(20,23);
	writeln('Deseja Sair? S/N: ');
	gotoxy(39,23);
	readln(sair);
	sair:=upcase(sair);
until (sair='S') or (sair='N');
end;

{Verifica se o mes e ano sao valido}
function verificaMes(mes:word):boolean;

begin
	if (mes<1) or (mes>12) then
		verificaMes:=false
	else
		verificaMes:=true;

end;

function verificaAno(ano:word):boolean;

begin
	if (ano<1900) or (ano>2011) then
		verificaAno:=false
	else
		verificaAno:=true;
end;



{verifica se o nome eh valido}
function validanome(nome:string):boolean;

var i:integer;

begin
	i:=1;
	if (nome[1]=' ') or (nome='') then
		validanome:=false
	else
	begin
		validanome:=true;
		while (i<length(nome)) and (nome[i]+nome[i+1]<>'  ') do
		begin
			i:=i+1;
		end;
		if nome[i]+nome[i+1]='  ' then
			validanome:=false;
	end;
    {valida o nome para nao comecar com espaco, nao ter mais de um espaco junto, nem ser nulo}
end;

{verifica se a data eh valida}
function validadata(dia:word; mes:word; ano:word):boolean;

var valido:boolean;

begin
	valido:=true;
	if (ano>1992) then
		valido:=false
	else
		if (ano=1992) and (mes>6) then
			valido:=false
		else
			if (ano=1992) and (mes=6) and (dia>=20) then
				valido:=false;
	if ((mes<1) or (mes>12)) or ((ano<1900) or (ano>2011)) then
		valido:=false;
	if valido then
	begin
		valido:=false;

		if ((mes mod 2<>0) and (mes<=7) and (mes>0)) or ((mes mod 2=0) and (mes>=8) and (mes<=12)) then {mes de 31 dias}
        begin
			if (dia>=1) and (dia<=31) then
            begin
				valido:=true;
            end;
        end
		else
		if (mes=4) or (mes=6) or (mes=9) or (mes=11) then {mes de 30 dias}
        begin
			if (dia>=1) and (dia<=30) then
            begin
				valido:=true;
            end;
        end
		else
		if (mes=2) then {fevereiro, bisexto?}
			if ano div 4=0 then {bissexto}
			begin
				if (dia>=1) and (dia<=29) then
					valido:=true;
			end
			else {ano nao bissexto}
				if (dia>=1) and (dia<=28) then
					valido:=true;
	end;
	validadata:=valido;
end;

{Valida CPF - verifica se o CPF eh valido}
function validacpf(cpf:string):boolean;

var i, valor, mais:integer;
	valido1, valido2, valido:boolean;
	vetor:array[1..11]of integer;
	erro:integer;

begin
	mais:=0;
	valido1:=false;
	valido2:=false;
	valido:=true;
	for i:=1 to 11 do
	begin
		val(cpf[i],vetor[i],erro);
		{write(vetor[i]);}
		if erro=1 then
			valido:=false;
	end;
	if valido then
	repeat
		valor:=0;
		for i:=2 to 10+mais do
		begin
			valor:=valor+vetor[(11+mais)-i]*i;
		end;
		valor:=valor mod 11;

		if ((valor=1) or (valor=0)) and (vetor[i]=0) then
		begin
			if i=10 then
				valido1:=true
			else
			if i=11 then
				valido2:=true;
		end 
		else
		if ((valor>1) and (valor<11)) and (vetor[i]=11-valor) then
		begin
			if i=10 then
				valido1:=true
			else
			if i=11 then
				valido2:=true;
		end; 
		mais:=mais+1;
	until mais>1;
	if (valido1) and (valido2) then
		validacpf:=true
	else
		validacpf:=false;
end;

{Verifica se a Sigla do estado fornecido existe}
function validaestado(uf:string):boolean;

var valido:boolean;

begin
	uf:=upcase(uf);
	if (uf ='AC') then
		valido:=true
	else
	if (uf ='AL') then
		valido:=true
	else
	if (uf ='AM') then
		valido:=true
	else
	if (uf ='AP') then
		valido:=true
	else
	if (uf ='BA') then
		valido:=true
	else
	if (uf ='CE') then
		valido:=true
	else
	if (uf ='DF') then
		valido:=true
	else
	if (uf ='ES') then
		valido:=true
	else
	if (uf ='SP') then
		valido:=true
	else
	if (uf ='RJ') then
		valido:=true
	else
	if (uf ='MG') then
		valido:=true
	else
	if (uf ='SE') then
		valido:=true
	else
	if (uf ='PE')then
		valido:=true
	else
	if (uf ='PB') then
		valido:=true
	else
	if (uf ='RN') then
		valido:=true
	else
	if (uf ='PI') then
		valido:=true
	else
	if (uf ='MA') then
		valido:=true
	else
	if (uf ='PA') then
		valido:=true	
	else
	if (uf ='RR') then
		valido:=true
	else
	if (uf ='TO') then
		valido:=true
	else
	if (uf ='MT') then
		valido:=true
	else
	if (uf ='MS') then
		valido:=true
	else
	if (uf ='RO') then
		valido:=true
	else
	if (uf ='PR') then
		valido:=true
	else
	if (uf ='SC') then
		valido:=true
	else
	if (uf ='RS') then
		valido:=true
	else
		valido:=false;
	validaestado:=valido;
end;

{verifica se o email eh valido e segue o seguinte: deve ter @ depois deve ter . e depois alguma coisa}
function validaemail(email:string):boolean;

var pontos:boolean;
	i, arrobas:integer;

begin
	arrobas:=0;
	pontos:=false;
	for i:=1 to length(email) do
	begin
		if email[i]='@' then
			arrobas:=arrobas+1;
		if (arrobas=1) and (i<length(email)) then
			if email[i]='.' then
				pontos:=true;
	end;
	if (arrobas=1) and (pontos) then
		validaemail:=true
	else
		validaemail:=false;
end;


{Verifica se ja existe o codigo de departamento}	
Function pesquisadep (var ad:tarqdep; cod:integer):integer;
var r:tregdep;
	posicao:integer;
	achou:boolean;
begin
	seek(ad,0);
	posicao:=0;
	achou:=false;

	while (eof(ad)=false) and (achou=false) do
	begin
		read(ad,r);
		if r.codigo=cod then
			achou:=true
		else
			posicao:=posicao+1;
	end;

	if achou=true then
		pesquisadep:=posicao
	else
		pesquisadep:=-1;
end;

{Verifica se ja existe uma matrícula de funcionario}
Function pesquisafunc(var af:tarqfunc; matricula:integer):integer;
var r:tregfunc;
	posicao:integer;
	achou:boolean;
begin
	seek(af,0);
	posicao:=0;
	achou:=false;

	while (eof(af)=false) and (achou=false) do
	begin
		read(af,r);
		if r.matricula=matricula then
			achou:=true
		else
			posicao:=posicao+1;
	end;

	if achou=true then
		pesquisafunc:=posicao
	else
		pesquisafunc:=-1;
end;

{Verificando duplicidade de registros no arquivo de historico de salario}
Function pesquisahistoricosalario (var hs:tarq_hist_sal; matricula,mes,ano:integer):integer;
var r:treg_hist_sal;
	posicao:integer;
	achou:boolean;
begin
	seek(hs,0);
	posicao:=0;
	achou:=false;

	while (eof(hs)=false) and (achou=false) do
	begin
		read(hs,r);
		if (r.matricula = matricula) and (r.mes = mes) and (r.ano = ano) then
			achou:=true
		else
			posicao:=posicao+1;
	end;

	if achou=true then
		pesquisahistoricosalario := posicao
	else
		pesquisahistoricosalario := -1;
end;
{=============1 - DEPARTAMENTO===========}
Procedure cadastrodepartamento(var ad:tarqdep; var af:tarqfunc);
var r:tregdep;
	f:tregfunc;
	sair:char;
	pesquisa:integer;
	i:integer;
	erro:integer;
	num:integer;
begin
	repeat
		clrscr;
		titulo('Cadastro de Departamento');
		gotoxy(ident,linha);
		write('Codigo Departamento: ');
		espaco(ident+30,linha,10);
		readln(r.codigo);
		voltacor;
		pesquisa:=pesquisadep(arqdep,r.codigo);
		if pesquisa<>-1 then
		begin
			gotoxy(20,22);
			writeln('Codigo Repetido! Pressione Enter.');
			readkey;
		end
		else
		begin
			repeat
				gotoxy(ident,linha+2);
				write('Nome do Departamento: ');
				espaco(ident+30,linha+2,30);
				readln(r.nome);
				voltacor;
			until validanome(r.nome); {nao pode ser nulo nem comecar com espaco}
			repeat
				gotoxy(ident,linha+4);
				write('Ramal: ');
				espaco(ident+30,linha+4,6);
				readln(r.ramal);
				voltacor;
				erro:=0;
				i:=1;
				while (i<=length(r.ramal)) and (erro=0) do
				begin
					val(r.ramal[i],num,erro);
					i:=i+1;
				end;
			until erro=0;
			{repeat}
				gotoxy(ident,linha+6);
				write('Matricula Gerente Departamento');
				espaco(ident+30,linha+6,10);
				{readln(f.matricula);}
				readln(r.codigogerente);
				voltacor;
				pesquisa:=pesquisafunc(af,r.codigogerente);
			{until pesquisa<>-1;}{vou ter q deixar passar pq senao nao tem como criar nada no programa}
			seek(ad,filesize(ad));
			write(ad,r);
		end;
		quersair(sair);
	until sair='S';
end;

{=============2 - FUNCIONARIO===========}
Procedure cadastrofuncionario(var af:tarqfunc; var ad:tarqdep; var ah:tarq_hist_sal);

var r : tregfunc;
    rh : treg_hist_sal;
	sair : char;
	status : integer;
	aux : string[4];
	valida:boolean;
	erro:integer;
	dia,mes,ano: string[4];
begin
	repeat
		clrscr;
		titulo('Cadastro de Funcionarios');
		gotoxy(ident,linha);
		write('Codigo do Departamento: ');
		espaco(ident+30,linha,10);
		readln(r.codigoDepartamento);
		voltacor;
		if pesquisadep(ad,r.codigoDepartamento) = -1 then
		begin
			gotoxy(20,23);
			writeln('Departamento Inexistente! Pressione alguma tecla.');
			readkey;
		end
		else
		begin
			gotoxy(ident,linha+1);
			write('Matricula do Funcionario:');
			espaco(ident+30,linha+1,10);
			readln(r.matricula);
			voltacor;
			if pesquisafunc(af,r.matricula) <> -1 then
			begin
				gotoxy(20,23);
				write('Matricula Repetida! Pressione alguma tecla');
				readkey;
			end
			else
			begin
				repeat
					gotoxy(ident,linha+2);
					write('Nome:');
					espaco(ident+30,linha+2,30);
					readln(r.nome);
					voltacor;
				until validanome(r.nome); {o nome nao eh vazio nem comeca com espaco}
			repeat
					gotoxy(20,23);
					write('             ');
					gotoxy(20,max_linhas_terminal);
					write('                          ');
				repeat
					gotoxy(ident,linha+3);
					write('Dia(nascimento): ');
					espaco(ident+30,linha+3,2);
					readln(dia);
					voltacor;
					val(dia,r.dia,erro);
				until erro=0;
				repeat
					gotoxy(ident,linha+4);
					write('Mes(nascimento): ');
					espaco(ident+30,linha+4,2);
					readln(mes);
					voltacor;
					val(mes,r.mes,erro);
				until erro=0;
				repeat
					gotoxy(ident,linha+5);
					write('Ano(nascimento): ');
					espaco(ident+30,linha+5,4);
					readln(ano);
					voltacor;
					val(ano,r.ano,erro);
				until erro=0;
					gotoxy(24,20);
					{write(dia,'/',mes,'/',ano);}
					valida:=validadata(r.dia, r.mes, r.ano);
					if not valida then
					begin
						gotoxy(20,max_linhas_terminal-1);
						write('Data invalida');
						gotoxy(20,max_linhas_terminal);
						write('Tecle enter para continuar');
						readkey;
					end;
			until valida;
				repeat
					gotoxy(20,max_linhas_terminal-1);
					write('             ');
					gotoxy(20,max_linhas_terminal);
					write('                                  ');
					gotoxy(ident,linha+6);
					write('CPF: ');
					espaco(ident+30,linha+6,11);
					readln(r.CPF);
					voltacor;
					valida:=validacpf(r.cpf);
					if not valida then
					begin
						gotoxy(20,max_linhas_terminal-1);
						write('CPF Invalido');
						gotoxy(20,max_linhas_terminal);
						write('Pressione uma tecla para continuar');
						readkey;
					end;
				until valida;
				gotoxy(ident,linha+7);
				write('Rua: ');
				espaco(ident+30,linha+7,30);
				readln(r.rua);
				voltacor;
				gotoxy(ident,linha+8);
				write('Bairro: ');
				espaco(ident+30,linha+8,30);
				readln(r.bairro);
				voltacor;
				gotoxy(ident,linha+9);
				write('Numero: ');
				espaco(ident+30,linha+9,5);
				readln(r.numeroCasa);
				voltacor;
				gotoxy(ident,linha+10);
				write('Complemento: ');
				espaco(ident+30,linha+10,5);
				readln(r.complemento);
				voltacor;
				gotoxy(ident,linha+11);
				write('Cidade: ');
				espaco(ident+30,linha+11,30);
				readln(r.cidade);
				voltacor;
				repeat
					gotoxy(20,max_linhas_terminal-1);
					write('                ');
					gotoxy(20,max_linhas_terminal);
					write('                                   ');
					gotoxy(ident,linha+12);
					write('Estado Sigla: ');
					espaco(ident+30,linha+12,2);
					readln(r.estado);
					voltacor;
					r.estado:=upcase(r.estado);
					valida:=validaestado(r.estado);
					if not valida then
					begin
						gotoxy(20,max_linhas_terminal-1);
						writeln('Estado Invalido');
						gotoxy(20,max_linhas_terminal);
						writeln('Pressione uma tecla para continuar');
						readkey;
					end;
				until valida;
                gotoxy(ident,linha+13);
				write('Tel: ');
				espaco(ident+30,linha+13,12);
				readln(r.telefone);
				voltacor;
				repeat
					gotoxy(20,max_linhas_terminal-1);
					write('                ');
					gotoxy(20,max_linhas_terminal);
					write('                                   ');

					gotoxy(ident,linha+14);
					write('Email: ');
					espaco(ident+30,linha+14,30);
					readln(r.email);
					voltacor;
					valida:=validaemail(r.email);
					if not valida then
					begin
						gotoxy(20,max_linhas_terminal-1);
						writeln('Email Invalido');
						gotoxy(20,max_linhas_terminal);
						writeln('Pressione uma tecla para continuar');
						readkey;
					end;
				until valida;
				
				gotoxy(ident,linha+15);
				writeln('Salario: R$');
				espaco(ident+30,linha+15,10);
				readln(r.salario);
				voltacor;
				gotoxy(ident,linha+16);
				writeln('Data da Contratacao:');
				espaco(ident+30,linha+16,10);
				readln(r.datacontratacao);
				voltacor;
					
				seek(af,filesize(af));
				write(af,r);

                rh.matricula := r.matricula;
                rh.salario:=r.salario;
                aux := copy(r.datacontratacao,4,2);
                val(aux,rh.mes,status);
                aux := copy(r.datacontratacao,7,4);
                val(aux,rh.ano,status);
                seek(ah,filesize(ah));
                write(ah,rh);
			end;
			
		end;
		quersair(sair);
	until sair='S';
end;

{==================3 - Alterar Funcionario===================}

procedure AlteraFuncionario(var AF:TarqFunc; var AH:Tarq_Hist_Func; var AD:TArqDep; var histsal : tarq_hist_sal);

var r : tregfunc;
    rh : treg_hist_sal;
	sair : char;
	posicao, erro : integer;
	{aux : string[4];}
	valida:boolean;
	dias,mess,anos: string[4];

begin
	clrscr;
	titulo('Alteracao de Dados de Funcionario');
	gotoxy(ident,linha);
	writeln('Matricula do Funcionario:');
	espaco(ident+30,linha,10);
	readln(r.matricula);
	voltacor;
	posicao:=pesquisafunc(af,r.matricula);
	if posicao = -1 then
	begin
		gotoxy(10,23);
		writeln('Matricula inexistente! Pressione alguma tecla');
		readkey;
	end
	else
	begin
		seek(af,posicao);
		read(af,r);
		repeat
			gotoxy(ident,linha+1);
			writeln('Nome:');
			espaco(ident+30,linha+1,30);
			readln(r.nome);
			voltacor;
		until validanome(r.nome); {o nome nao eh vazio nem comeca com espaco}
		repeat
			gotoxy(20,max_linhas_terminal-1);
			write('             ');
			gotoxy(20,max_linhas_terminal);
			write('                          ');
			repeat
				gotoxy(ident,linha+3);
				write('Dia(nascimento): ');
				espaco(ident+30,linha+3,2);
				readln(dias);
				voltacor;
				val(dias,r.dia,erro);
			until erro=0;
			repeat
				gotoxy(ident,linha+4);
				write('Mes(nascimento): ');
				espaco(ident+30,linha+4,2);
				readln(mess);
				voltacor;
				val(mess,r.mes,erro);
			until erro=0;
			repeat
				gotoxy(ident,linha+5);
				write('Ano(nascimento): ');
				espaco(ident+30,linha+5,4);
				readln(anos);
				voltacor;
				val(anos,r.ano,erro);
			until erro=0;
				
			valida:=validadata(r.dia, r.mes, r.ano);
			if not valida then
			begin
				gotoxy(20,max_linhas_terminal-1);
				write('Data invalida');
				gotoxy(20,max_linhas_terminal);
				write('Tecle enter para continuar');
				readkey;
			end;
		until valida;
		repeat
			gotoxy(20,max_linhas_terminal-1);
			write('             ');
			gotoxy(20,max_linhas_terminal);
			write('                                  ');
			gotoxy(ident,linha+6);
			write('CPF: ');
			espaco(ident+30,linha+6,11);
			readln(r.CPF);
			voltacor;
			valida:=validacpf(r.cpf);
			if not valida then
			begin
				gotoxy(20,max_linhas_terminal-1);
				write('CPF Invalido');
				gotoxy(20,max_linhas_terminal);
				write('Pressione uma tecla para continuar');
				readkey;
			end;
		until valida;
		gotoxy(ident,linha+7);
		write('Rua: ');
		espaco(ident+30,linha+7,30);
		readln(r.rua);
		voltacor;
		gotoxy(ident,linha+8);
		write('Bairro: ');
		espaco(ident+30,linha+8,30);
		readln(r.bairro);
		voltacor;
		gotoxy(ident,linha+9);
		write('Numero: ');
		espaco(ident+30,linha+9,5);
		readln(r.numeroCasa);
		voltacor;
		gotoxy(ident,linha+10);
		write('Complemento: ');
		espaco(ident+30,linha+10,5);
		readln(r.complemento);
		voltacor;
		gotoxy(ident,linha+11);
		write('Cidade: ');
		espaco(ident+30,linha+11,30);
		readln(r.cidade);
		voltacor;
		repeat
			gotoxy(20,max_linhas_terminal-1);
			write('                ');
			gotoxy(20,max_linhas_terminal);
			write('                                   ');
			gotoxy(ident,linha+12);
			write('Estado Sigla: ');
			espaco(ident+30,linha+12,2);
			readln(r.estado);
			voltacor;
			r.estado:=upcase(r.estado);
			valida:=validaestado(r.estado);
			if not valida then
			begin
				gotoxy(20,max_linhas_terminal-1);
				writeln('Estado Invalido');
				gotoxy(20,max_linhas_terminal);
				writeln('Pressione uma tecla para continuar');
				readkey;
			end;
		until valida;
        gotoxy(ident,linha+13);
		write('Tel: ');
		espaco(ident+30,linha+13,12);
		readln(r.telefone);
		voltacor;
		repeat
			gotoxy(20,max_linhas_terminal-1);
			write('                ');
			gotoxy(20,max_linhas_terminal);
			write('                                   ');
			gotoxy(ident,linha+13);
			write('Email: ');
			espaco(ident+30,linha+13,30);
			readln(r.email);
			voltacor;
			valida:=validaemail(r.email);
			if not valida then
			begin
				gotoxy(20,max_linhas_terminal-1);
				writeln('Email Invalido');
				gotoxy(20,max_linhas_terminal);
				writeln('Pressione uma tecla para continuar');
				readkey;
			end;
		until valida;
			
				
				{--}

	repeat
		gotoxy(20,23);
		write('                                       ');
		gotoxy(ident,linha+14);
		writeln('Novo Salario: R$');
		espaco(ident+30,linha+14,30);
		readln(r.salario);
		voltacor;
		if r.salario <= 0 then
		begin
			gotoxy(20,23);
			writeln('Valor Incorreto! Pressione alguma tecla');
			readkey;
		end;
	until r.salario > 0;
	rh.matricula := r.matricula;
	rh.salario := r.salario;
	GetDate(Ano, Mes, Dia, Dia_Semana);
	{repeat
		writeln('Mes:');
		readln(rh.mes);
	until verificames(rh.mes);
	repeat
		write('Ano:');
		readln(rh.ano);
	until verificaano(rh.ano);}
	{vou pegar a data do PC}
	rh.mes:=mes;
	rh.ano:=ano;
	
	{atualizando o salario}
	if pesquisahistoricosalario(histsal,r.matricula,rh.mes,rh.ano) = -1 then
	begin
		{atualizando o salario}
		seek(af, posicao);
		write(af,r);
		{inserindo novo registro no historico salario}
		seek(histsal, filesize(histsal));
		write(histsal,rh);
	end
	else
	begin
		gotoxy(20,23);
		writeln('Alteração incorreta. Pressione algo para sair');
		readkey;
	end;		
	end;
	quersair(sair);
end;

{================4 - Alterar Departamento Funcionario=============}
procedure alteraDepartamento(var af:tarqfunc; var ad:tarqdep; var ahf:tarq_hist_func);

var r:tregfunc;
	rhf:treg_hist_func;
	sair:char;
	posicao:integer;
	dias, mess, anos:string[4];
	data:string[10];

begin
repeat
	clrscr;
	titulo('Alterar Departamento de Funcionario');
	repeat
		gotoxy(15,23);
		write('                                                ');
	
		gotoxy(ident,linha);
		write('Matricula do Funcionario: ');
		espaco(ident+30,linha,10);
		readln(r.matricula);
		voltacor;
		posicao:=pesquisafunc(af,r.matricula);
		if posicao = -1 then
		begin
			gotoxy(15,23);
			write('Matricula Inexistente! Pressione alguma tecla');
			readkey;
		end;
	until posicao<>-1; {aki vai reperir ate q seja fornecida uma matricula correta}
	seek(af,posicao);
	read(af,r);
	repeat
		gotoxy(20,23);
		write('                                    ');
		gotoxy(ident,linha+2);
		write('Codigo do Departamento: ');
		espaco(ident+30,linha+2,10);
		readln(r.codigoDepartamento);
		voltacor;
		posicao:=pesquisadep(ad,r.codigoDepartamento);
		if posicao = -1 then
		begin
			gotoxy(20,23);
			write('Codigo Inexistente! Pressione Enter');
			readkey;
		end;
	until posicao<>-1;
	{atualizando funcionario}
	seek(af,posicao);
	write(af,r);
	{colocando os dados no historico }
	GetDate(Ano, Mes, Dia, Dia_Semana);
	str(dia, dias);
	str(mes, mess);
	str(ano, anos);
	data:=dias+'/'+mess+'/'+anos;
	
	rhf.codigodepartamento:=r.codigodepartamento;
	
	rhf.data:=data;
	seek(ahf,filesize(ahf));
	write(ahf,rhf);
	
	quersair(sair);
until sair='S';
end;

{============5 - Alterar o Gerente de um Departamento===================}
procedure alteraGerenteDep(var ad:tarqdep; var ahd:tarq_hist_dep; var af:tarqfunc);

var r:tregdep;
	rhd:treg_hist_dep;
	posicao:integer;
	sair:char;

begin
repeat
	clrscr;
	titulo('Alterar o Gerente de um Departamento');
	repeat
		gotoxy(20,23);
		write('                                      ');
	
		gotoxy(ident,linha);
		write('Codigo do Departamento: ');
		espaco(ident+30,linha,10);
		readln(r.codigo);
		voltacor;
		posicao:=pesquisadep(ad,r.codigo);
		if posicao = -1 then
		begin
			gotoxy(20,23);
			writeln('Codigo Inexistente! Pressione Enter');
			readkey;
		end;
	until posicao<>-1;
	seek(ad,posicao);
	read(ad,r);
 repeat
	gotoxy(ident,linha+2);
	write('Novo Codigo Gerente: ');
	espaco(ident+30,linha+2,10);
	readln(r.codigogerente);
	voltacor;
	rhd.codigogerente:=r.codigogerente;
    {gotoxy(10,15); write(r.codigogerente);}
	{atualiza o gerente}
	seek(ad,posicao);
	write(ad,r);
    posicao:=pesquisafunc(af,r.codigogerente);
 until posicao<>-1;
	{add no registro de historico de departamento}
	seek(ahd,filesize(ahd));
	write(ahd,rhd);
	gotoxy(20,20);
	writeln('Alteracao feita com sucesso');

	quersair(sair);
until sair='S';
end;

{========6 - Consulta funcionario por matricula==========}
procedure consultafuncionario(var af:tarqfunc; var ad:tarqdep);

var r:tregfunc;
	rd:tregdep;
	sair:char;
	posicao:integer;

begin
repeat
	clrscr;
	titulo('Consulta Funcionario por Matricula');
	repeat
		gotoxy(20,23);
		write('                                              ');
		gotoxy(ident,linha);
		write('Matricula do funcionario: ');
		espaco(ident+30,linha,10);
		readln(r.matricula);
		voltacor;
		posicao:=pesquisafunc(af,r.matricula);
		if posicao=-1 then
		begin
			gotoxy(20,23);
			writeln('Matricula Inexistente! Pressione alguma tecla');
			readkey;
		end;
	until posicao<>-1;
	seek(af,posicao);
	read(af,r);
	gotoxy(15,7);
	write('Informacoes do funcionario');
	
	gotoxy(ident,linha+4);
	write('Nome: ',r.nome);
	gotoxy(ident,linha+5);
	write('Data de Nascimento: ',r.dia,'/',r.mes,'/',r.ano);
	gotoxy(ident,linha+6);
	write('CPF: ',r.cpf);
	
	{verificando departamento}
	posicao:=pesquisadep(ad,r.codigodepartamento);
	seek(ad,posicao);
	read(ad,rd);
	gotoxy(ident,linha+7);
	writeln('Departamento: ',rd.nome);
	
	{voltando aos dados do funcionario do arquivo do funcionario}
	gotoxy(ident,linha+8);
	writeln('Salario: R$',r.salario:0:2);
	gotoxy(ident,linha+9);
	writeln('Bairro ',r.bairro);
	gotoxy(ident,linha+10);
	writeln('Rua: ',r.rua,' Numero: ',r.numerocasa);
	gotoxy(ident,linha+11);
	writeln('Complemento : ',r.complemento);
	gotoxy(ident,linha+12);
	writeln('Cidade: ',r.cidade);
	gotoxy(ident,linha+13);
	writeln('Estado(UF): ',r.estado);
	gotoxy(ident,linha+14);
	writeln('Tel: ',r.telefone);
	gotoxy(ident,linha+15);
	writeln('Email ',r.email);
	
	{fim dos dados consulta}
	
	quersair(sair);
until sair='S';

end;

{=================7 - Gerar folha de pagamento==============}
procedure gerafolha(var af:tarqfunc);

var r:tregfunc;
	sair:char;
	posicao:integer;

begin
repeat
	clrscr;
	titulo('Gerar Folha de Pagamento');
	repeat
		gotoxy(20,23);
		write('                                              ');
		gotoxy(ident,linha);
		write('Matricula do funcionario');
		espaco(ident+30,linha,10);
		readln(r.matricula);
		voltacor;
		posicao:=pesquisafunc(af,r.matricula);
		if posicao=-1 then
		begin
			gotoxy(20,23);
			writeln('Matricula Inexistente! Pressione alguma tecla');
			readkey;
		end;
	until posicao<>-1;
	seek(af,posicao);
	read(af,r);
	gotoxy(15,7);
	writeln('Informacoes do funcionario');
	gotoxy(ident,9);
	write('Matricula |');
	gotoxy(ident+10,9);
	write('| Nome |');
	gotoxy(ident+10+30,9);
	write('| Salario ');
	
	gotoxy(ident,10);
	write(r.matricula);
	
	gotoxy(ident+10,10);
	write(r.nome);
	
	gotoxy(ident+10+30,10);
	write('R$',r.salario:0:2);
	
	quersair(sair);
until sair='S';
end;

{=============8 - ALTERAR SALARIO FUNCIONARIO===========}
{Alterando o salário do funcionario}
Procedure alteraSalario (var af : tarqfunc; var histsal : tarq_hist_sal);
var r : tregfunc;
	posicao :  integer;
	rh: treg_hist_sal;
	sair : char;
begin
	clrscr;
	titulo('Alterar Salario de Funcionario');
	repeat
		gotoxy(20,23);
		write('                                              ');
	
		gotoxy(ident,linha);
		write('Matricula: ');
		espaco(ident+30,linha,10);
		readln(r.matricula);
		voltacor;
		posicao := pesquisafunc(af,r.matricula);
		if posicao = -1 then
		begin
			gotoxy(20,23);
			writeln('Matricula Inexistente! Pressione alguma tecla');
			readkey;
		end
		else
		begin
			seek(af,posicao);
			read(af,r);
			repeat
				gotoxy(20,23);
				write('                                        ');
			
				gotoxy(ident,linha+2);
				write('Novo Salario: ');
				espaco(ident+30,linha+2,10);
				readln(r.salario);
				voltacor;
				if r.salario <= 0 then
				begin
					gotoxy(20,23);
					writeln('Valor Incorreto! Pressione alguma tecla');
					readkey;
				end;
			until r.salario > 0;
			rh.matricula := r.matricula;
			rh.salario := r.salario;
			{repeat
				writeln('Mes:');
				readln(rh.mes);
			until verificames(rh.mes);
			repeat
				write('ano:');
				readln(rh.ano);
			until verificaano(rh.ano);}
			
			GetDate(Ano, Mes, Dia, Dia_Semana);
			rh.mes:=mes;
			rh.ano:=ano;
			
			{atualizando o salario}
			if pesquisahistoricosalario(histsal,r.matricula,rh.mes,rh.ano) = -1 then
			begin
				{atualizando o salario}
				seek(af, posicao);
				write(af,r);
				{inserindo novo registro no historico salario}
				seek(histsal, filesize(histsal));
				write(histsal,rh);
			end
			else
			begin
				gotoxy(20,23);
				writeln('Alteração incorreta. Pressione algo para sair');
				readkey;
			end;		
			
		end;		
		
		quersair(sair);
	until sair = 'S';
	
end;

{===============9 - Relatorio de Funcionarios por Departamento ==========}

procedure relatorioFuncDep(var af:tarqfunc; var ad:tarqdep);

var r:tregdep;
	rf:tregfunc;
	sair:char;
	posicao,i, j:integer;
	total:real;

begin
	clrscr;
	titulo('Relatorio de Funcionario por Departamento');
repeat
	total:=0;
	repeat
		gotoxy(20,23);
		write('                                              ');
		
		gotoxy(ident,linha);
		write('Codigo do Departamento: ');
		espaco(ident+30,linha,10);
		readln(r.codigo);
		voltacor;
		posicao:=pesquisadep(ad,r.codigo);
		if posicao=-1 then
		begin
			gotoxy(20,23);
			writeln('Matricula Inexistente! Pressione alguma tecla');
			readkey;
		end;
	until posicao<>-1;
	
	seek(ad,posicao);
	read(ad,r);
	gotoxy(15,7);
	write('Departamento ',r.nome);
	
	gotoxy(ident,9);
	write('Matricula |');
	gotoxy(ident+10,9);
	write('| Nome |');
	gotoxy(ident+10+30,9);
	write('| Salario ');
	j:=0;
	for i:=0 to filesize(af)-1 do
	begin
		writeln;
		seek(af,i);
		read(af,rf);
		if rf.codigoDepartamento=r.codigo then
		begin
			j:=j+1;
			gotoxy(ident,9+j);
			writeln(rf.matricula);
			gotoxy(ident+10,9+j);
			writeln(rf.nome);
			gotoxy(ident+10+30,9+j);
			writeln(rf.salario:0:2);
			total:=total+rf.salario;
		end;
	end;
	writeln;
	writeln('        Valor total da Folha: ',total:0:2);
	
	quersair(sair);
until sair='S';
end;

{==================10 - Historico Salario em um Periodo==============}

procedure historicosalarioperiodo();

begin
	clrscr;
	titulo('Historico Salario em um Periodo');
	gotoxy(ident,linha);
	writeln('Em Construcao');
    readkey;
	voltacor;
end;

{==================11 - Gerentes de um Departamento==================}
{como so pode ter um gerente, entao eh informa os dados do gerente}
procedure gerentedados(var af:tarqfunc; var ad:tarqdep);

var r:tregfunc;
	rd:tregdep;
	sair:char;
	posicao:integer;
	achou:boolean;

begin
repeat
	clrscr;
	titulo('Gerente de um Departamento');
	repeat
		gotoxy(20,23);
		write('                                                 ');
	
		gotoxy(ident,linha);
		writeln('Codigo do departamento');
		espaco(ident+30,linha,10);
		readln(rd.codigo);
		voltacor;
		posicao:=pesquisadep(ad,rd.codigo);
		if posicao=-1 then
		begin
			gotoxy(20,23);
			writeln('Departamento Inexistente! Pressione alguma tecla');
			readkey;
		end;
	until posicao<>-1;
	achou:=false;
    seek(ad,posicao);
    read(ad,rd);
    posicao:=0;
	while (not achou) and (not eof(af)) do
	begin
		seek(af,posicao);
		read(af,r);
        {gotoxy(10,15+posicao)writeln(r.matricula,'=',rd.codigogerente);  }
        if r.matricula=rd.codigogerente then
			achou:=true
		else
			posicao:=posicao+1;
	end;

	if not achou then
	begin
		gotoxy(20,22);
		writeln('Gerente nao encontrado');
	end
	else
	begin
		gotoxy(15,7);
		writeln('Informacoes do Gerente');
		
		gotoxy(ident,linha+4);
		writeln('Matricula: ',r.matricula);
		gotoxy(ident,linha+5);
		writeln('Nome: ',r.nome);
		gotoxy(ident,linha+6);
		writeln('Data de Nascimento: ',r.dia,'/',r.mes,'/',r.ano);
		gotoxy(ident,linha+7);
		writeln('CPF: ',r.cpf);
		gotoxy(ident,linha+8);
		writeln('Salario: ',r.salario:0:2);
		gotoxy(ident,linha+9);
		writeln('Bairro ',r.bairro);
		gotoxy(ident,linha+10);
		writeln('Rua: ',r.rua,' Numero: ',r.numerocasa);
		gotoxy(ident,linha+11);
		writeln('Complemento : ',r.complemento);
		gotoxy(ident,linha+12);
		writeln('Cidade: ',r.cidade);
		gotoxy(ident,linha+13);
		writeln('Estado(UF): ',r.estado);
		gotoxy(ident,linha+14);
		writeln('Tel: ',r.telefone);
		gotoxy(ident,linha+15);
		writeln('Email ',r.email);
		
	end;
	quersair(sair);
until sair='S';
end;


{==================12 - Sobre==================}
{sobre o trabalho de logica de programacao}
procedure sobre();

begin
	clrscr;
	titulo('Sobre o Trabalho');
	gotoxy(15,5);
	writeln('ControlFunc');
	writeln('');
	writeln('Instituto Federal de Educacao, Ciencia e Tecnologia do Sudeste de Minas Gerais');
	writeln('Curso: Tecnologia em Sistemas para Internet');
	writeln('Disciplina: Logica de Programacao');
	writeln('Periodo: 1');
	writeln('Aluno: Arthur Assuncao');
	writeln('');
	writeln('Descricao: Implementacao de um sistema de controle de funcionarios em Pascal');
	writeln('Funcionalidades obrigatorias:');
	gotoxy(3,15);
	write('Cadastro de departamento; ');
	write('Cadastro de Funcionario; ');
	write('Alterar Funcionario; ');
	write('Alterar Departamento do Funcionario; ');
	write('Alterar o Gerente de um Departamento; ');
	write('Consulta Funcionario Matricula; ');
	write('Gerar Folha Pagamento; ');
	write('Alterar o Salario de um Funcionário; ');
	write('Relatorio de Funcionarios por Departamento; ');
	write('Historico Salario em um periodo; ');
	write('Gerentes de um Departamento; ');
	gotoxy(15,max_linhas_terminal);
	write('Pressione uma tecla para voltar');
	readkey;
end;

BEGIN
	{Arquivo departamento}
	assign(arqdep,'dep.dat');
	{$I-}
	reset(arqdep);
	{$I+}
	if IOresult <> 0 then
		rewrite(arqdep);
		
	{Arquivo funcionário}
	assign(arqfunc,'func.dat');
	{$I-}
	reset(arqfunc);
	{$I+}
	if IOresult <> 0 then
		rewrite(arqfunc);
		
	{Arquivo historico salario}	
	assign(arqhist_sal,'hist_sal.dat');
	{$I-}
	reset(arqhist_sal);
	{$I+}
	if IOresult <> 0 then
		rewrite(arqhist_sal);
		
	{Arquivo historico departamento}	
	assign(arqhist_dep,'hist_dep.dat');
	{$I-}
	reset(arqhist_dep);
	{$I+}
	if IOresult <> 0 then
		rewrite(arqhist_dep);
		
	{Arquivo historico funcionario}	
	assign(arqhist_func,'hist_func.dat');
	{$I-}
	reset(arqhist_func);
	{$I+}
	if IOresult <> 0 then
		rewrite(arqhist_func);
	
	{MENU}
repeat
	clrscr;
	x:=1;
	i:=0;
	j:=0;
	k:=1;
	m:=80;
	{repeat }
	{clrscr;}
	{======Titulo======}
	textcolor(lightgreen);
	for l:=1 to 80 do
		write('_');
	textcolor(lightred);
	gotoxy(15,2);
	writeln('ControlFunc - Trabalho final de Logica de Programacao');
	voltacor;
	for l:=1 to 80 do
		write('_');
	{======Fim Titulo=====}
	repeat
		
	gotoxy(18,5);
	textcolor(lightgreen); {cor das opcoes}
	if x=1 then
		mudacor;
	writeln('Cadastro de Departamento                   ');
	voltacor;
	gotoxy(18,6);
	if x=2 then
		mudacor;
	writeln('Cadastro de Funcionario                    ');
	voltacor;
	gotoxy(18,7);
	if x=3 then
		mudacor;
	writeln('Alterar Funcionario                        ');
	voltacor;
	gotoxy(18,8);
	if x=4 then
		mudacor;
	writeln('Alterar Departamento Funcionario           ');
	voltacor;
	gotoxy(18,9);
	if x=5 then
		mudacor;
	writeln('Alterar o Gerente de um Departamento       ');
	voltacor;
	gotoxy(18,10);
	if x=6 then
		mudacor;
	writeln('Consulta Funcionario Matriula              ');
	voltacor;
	gotoxy(18,11);
	if x=7 then
		mudacor;
	writeln('Gerar Folha Pagamento                      ');
	voltacor;
	gotoxy(18,12);
	if x=8 then
		mudacor;
	writeln('Alterar o Salario de um Funcionario        ');
	voltacor;
	gotoxy(18,13);
	if x=9 then
		mudacor;
	writeln('Relatorio de Funcionarios por Departamento ');
	voltacor;
	gotoxy(18,14);
	if x=10 then
		mudacor;
	writeln('Historico Salario em um Periodo            ');
	voltacor;
	gotoxy(18,15);
	if x=11 then
		mudacor;
	writeln('Gerentes de um Departamento                ');
	voltacor;
	gotoxy(18,16);
	if x=12 then
		mudacor;
	writeln('Sobre o Trabalho                           ');
	voltacor;
	gotoxy(18,17);
	if x=13 then
		mudacor;
	writeln('Sair                                       ');
	voltacor;
	textcolor(15);
	gotoxy(16,4+x);
	writeln(chr(62));    {use o 62 ou o 16}
	voltacor;
	
	
	{i:=1;
	j:=1;}
	{========Texto q se move=======}
	repeat
		GetDate(Ano, Mes, Dia, Dia_Semana);
		GetTime(Hora, Minuto, Segundo, Dec_Segundo);
		gotoxy(1,1);
	 	if minuto<10 then
			write('_',hora,':0',minuto,':',segundo,'_');
		gotoxy(1,1);
		if hora<10 then
			write('_0',hora,':',minuto,':',segundo,'_');
        gotoxy(1,1);
        if segundo<10 then
			write('_',hora,':',minuto,':0',segundo,'_');
        gotoxy(1,1);
        if (hora<10) and (minuto<10) then
			write('_0',hora,':0',minuto,':',segundo,'_');
        gotoxy(1,1);
        if (hora<10) and (minuto<10) and (segundo<10) then
			write('_0',hora,':0',minuto,':0',segundo,'_');
        gotoxy(1,1);
        if (minuto<10) and (segundo<10) then
			write('_',hora,':0',minuto,':0',segundo,'_');
        gotoxy(1,1);
        if (hora<10) and (segundo<10) then
			write('_0',hora,':',minuto,':0',segundo,'_');

		gotoxy(1,1);
		if (minuto>=10) and (hora>=10) and (segundo>=10) then
			write('_',hora,':',minuto,':',segundo,'_');
		gotoxy(70,1);
		write('_',dia,'/',mes,'/',ano,'_');
		
		{linha para direita andando}
		{gotoxy(k-1,3);
		write('_');}
		
		{if k=0 then
		begin
			gotoxy(80,3);
			write('_');
		end;}
		
		if k<40 then
			textcolor(5)
		else
			textcolor(lightgreen);
		gotoxy(k,3);
		write('_');
		k:=k+1;
		if k=81 then
			k:=0;
		
		{linha para esquerda}
		voltacor;
		
		{gotoxy(1+m,3);
		write('_');}
		{if m=81 then
		begin
			gotoxy(1,3);
			write('_');
		end;}
		
		if m>40 then
			textcolor(5)
		else
			textcolor(lightgreen);
		gotoxy(m,3);
		write('_');
		m:=m-1;
		
		if m=0 then
			m:=80;
			
		gotoxy(1,2);
		writeln(' ');
		gotoxy(1,max_linhas_terminal+1);
		
		voltacor;
		if i<51 then
		begin
			delay(80);
			i:=i+1;
			gotoxy(i,max_linhas_terminal);
			write(' Criado por Arthur Assuncao ');  {texto com 28 caracteres}
			if i>=51 then
				j:=0;
		end;
		if i>=51 then
		begin
			delay(80);
			j:=j+1;
			gotoxy(51-j,max_linhas_terminal);
			write(' Criado por Arthur Assuncao ');  {texto com 28 caracteres}
			if j>=51 then
				i:=1;
		end;
	gotoxy(1,max_linhas_terminal+1);
	until keypressed;
	{========FIM Texto q se move=======}
	
	tecla:=readkey;
	tecla:=upcase(tecla);
	case tecla of
		#80 :begin gotoxy(16,4+x); writeln(' '); x:=x+1; end;
		#72 :begin gotoxy(16,4+x); writeln(' '); x:=x-1; end;
	end; 		
	if x=0 then
		x:=13
	else
	if x=14 then
		x:=1;
	
	
	gotoxy(80,max_linhas_terminal);
	until tecla=#13;
	opcao:=x;
	case opcao of
		1:cadastrodepartamento(arqdep,arqfunc);
		2:cadastrofuncionario(arqfunc,arqdep,arqhist_sal);
		3:AlteraFuncionario(arqfunc, arqhist_func, arqdep, arqhist_sal);
		4:alteraDepartamento(arqfunc, arqdep, arqhist_func);
		5:alteraGerenteDep(arqdep, arqhist_dep, arqfunc);
		6:consultafuncionario(arqfunc, arqdep);
		7:gerafolha(arqfunc);
		8:alterasalario(arqfunc,arqhist_sal);
		9:relatorioFuncDep(arqfunc, arqdep);
		10:historicosalarioperiodo();
		11:gerentedados(arqfunc, arqdep);
		12:sobre();
		13:halt;
	end;
until opcao=13;
	{FIM MENU}
	
	{fechando as budega de arquivos}
	close(arqdep);
	close(arqfunc);
	close(arqhist_sal);
	close(arqhist_dep);
	close(arqhist_func);
END.
