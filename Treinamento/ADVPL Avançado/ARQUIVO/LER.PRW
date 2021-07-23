#include 'protheus.ch'
#include 'parmtype.ch'

/*
DATA:

DESC:   Ler arquivo Texto - Cadastro de Cliente

AUTOR:
*/
User Function LTXTCLI(lPrim)

	Local cLinha  	:= ""
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local i,nX
	Local aSA1		:= {}
	Local cArqTxt   := "\SA1\CADASTRO_de_CLIENTE.TXT"
	Local cGetDeli  := ";"
	Local cAliasTab := "SA1"

	Default lPrim   := .F.

	//Verifica se o Arquivo Existe.
	If !File(cArqTxt)
		MsgStop("O arquivo " + cArq + " não foi Encontrado!")
		Return
	EndIf

	//Abre o Arquivo
	//Retorna o manipulador de controle do arquivo. Em caso de falha na abertura, a função retornará -1.
	If FT_FUSE(cArqTxt) == - 1
		MsgStop("Erro ao abrir o Arquivo: " + cArqTxt)
		Return
	EndIf

	//Posiciona no início (primeiro caracter da primeira linha) do arquivo texto aberto pela função FT_FUSE().
	FT_FGOTOP()

	//Indica se o ponteiro está posicionado no fim do arquivo texto.
	While !FT_FEOF()

		//Lê e retorna uma linha de texto do arquivo aberto pela função FT_FUse().
		//As linhas do texto, são delimitadas pela sequência de caracteres CRLF (chr(13)+chr(10)) ou apenas LF (chr(10)),
		//e o tamanho máximo de cada linha é 1022 bytes.
		cLinha := FT_FREADLN()

		//Indico se a Primeira linha corresponde algum layout a ser seguido
		If lPrim
			aCampos := Separa(cLinha,cGetDeli,.T.)
			lPrim := .F.
		Else
			aAdd(aDados, Separa(cLinha,cGetDeli,.T.))
		EndIf

		//Move o ponteiro, do arquivo texto aberto pela função FT_FUse(), para uma nova posição.
		FT_FSKIP()
	EndDo

	//Fecha o arquivo aberto
	FT_FUSE()

	//Caso indique que temos um controle de inserção de dados.
	//aCampos tem que ser diferente de vazio
	If !Empty(aCampos)

		For i := 1 to Len(aDados)

			DbSelectArea(cAliasTab)
			(cAliasTab)->(DbSetOrder(1))
			(cAliasTab)->(DbGoTop())

			aSA1 := {}

			For nX := 1 To Len(aCampos)

				cCampo  := cAliasTab + "->" + aCampos[nX]

				If ValType(&cCampo) == "N"

					aAdd(aSA1, {aCampos[nX], Val(aDados[i,nX]) ,Nil})

				ElseIf ValType(&cCampo) == "D"

					aAdd(aSA1, {aCampos[nX], StoD(aDados[i,nX]),Nil})

				Else

					aAdd(aSA1, {aCampos[nX], AllTrim(aDados[i,nX]),Nil})

				EndIf

			Next nX

			//executa o execauto cadastrando cliente ...

		Next i

	EndIf

Return
