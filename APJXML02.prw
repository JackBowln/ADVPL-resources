#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "ap5mail.ch"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA: 	29/12/2017

DESCR: 	PROGRAMA DE IMPORTAÇÃO DE XML -> NF-e/CT-e - JARACATIA

AUTOR:	MAYCON ANHOLETE BIANCHINE
*/

User Function APJXML02()

	Local i

	Private oProcess
	Private aSize 			:= MsAdvSize()
	Private oDlgXML
	Private oGetXml
	Private aGetXml 		:= {}
	Private aCpoXml			:= {}
	Private aNomCpoXml		:= {}
	Private aTamCpoXml		:= {}
	Private aHeaderEx 		:= {}
	Private aColsEx 		:= {}
	Private aFieldFill 		:= {}
	Private aFields 		:= {}
	Private aAlterFields 	:= {"ZI_B1COD"}
	Private oGetItem
	Private oCgcReme
	Private cCgcReme
	Private oNomReme
	Private cNomReme
	Private oCgcDest
	Private cCgcDest
	Private oNomDest
	Private cNomDest
	Private oObsNf
	Private cObsNf
	Private cCondPag		:= "002"
	Private oCondPag
	Private oFolder
	Private aBrTotais 		:= {}
	Private oBrTotais
	Private aCpoTotais 		:= {"Valor Total dos Produtos","Vl. Desconto","Vl. Despesas","Vl. Frete","Base de Cálculo ICMS","Valor do ICMS","Valor Total do IPI","Valor Total da NFe"}
	Private aCpoGeral 		:= {"Valor Total dos Produtos","Vl. Desconto","Vl. Despesas","Vl. Frete","Base de Cálculo ICMS","Valor do ICMS","Valor Total do IPI","Valor Total das NF's'"}
	Private cTpNfota 		:= "NF-e"
	Private oTpNfota 
	Private oMemoXml
	Private cMemoXml
	Private oVerde   		:= LoadBitmap(GetResources(),"BR_VERDE")
	Private oVermelho   	:= LoadBitmap(GetResources(),"BR_VERMELHO")
	Private oCLEG1   		:= LoadBitmap(GetResources(),"BR_VERDE")
	Private oCLEG2   		:= LoadBitmap(GetResources(),"BR_VERMELHO")
	Private oStatusXML
	Private cStatusXML		:= "Docto. não Classificado"
	Private oBrGeral
	Private aBrGeral		:= {}
	Private oBtNCM
	Private oBtUM
	Private oBtCad
	Private oBtPed
	Private oBtDesfaz

	//====================================MANIPULAÇÃO DE ARQUIVOS XML's=============================================
	//IP DO SERVIDOR PARA ACESSO DAS PASTAS REFERENTES AO XML
	Private cIpServer		:= "192.168.100.180"

	//LOCAL ONDE SISTEMA VAI BUSCAR OS XML PARA DARA INICIO AO PROGRAMA DE IMPORTAÇÃO
	Private cPatch 			:= Lower("\\"+cIpServer+"\XML JARACATIA DISTRIBUIDORA - NF-e CT-e\")

	//LOCAL ONDE O SISTEMA VAI "JOGAR" OS XML QUE JA FOREM PROCESSADOS - GRAVADOS NAS TABELAS SZX, SZI
	Private cDirDest 		:= "\\"+cIpServer+"\XML JARACATIA DISTRIBUIDORA - NF-e CT-e - IMPORTADOS\"

	//LOCAL ONDE O SISTEMA VAI "JOGAR" OS XML QUE ESTÃO COM ERRO DE LEITURA
	//ERRO ACONTECE PORQUE O XML TEM NUMERO DE CARACTER MAIOR QUE 64000
	//ENTÃO DEVO PEGAR ESSE XML E JOGAR DENTRO DA ROOT = cDirErrXml
	//APOS A LEITURA DO XML DENTRO DA ROOT, O XML VAI PARA cDirDest
	Private cDirErrLei		:= "\\"+cIpServer+"\Totvs\Protheus_JARACATIA\Protheus_Prod_P12\Protheus_Data_Prod_P12\XML JARACATIA DISTRIBUIDORA - NF-e CT-e - ERRO DE LEITURA\"
	Private cDirErrXml		:= "\XML JARACATIA DISTRIBUIDORA - NF-e CT-e - ERRO DE LEITURA\"

	//LOCAL ONDE O SISTEMA VAI "JOGAR" XML COM CADASTRO DOS FORNECEDORES FOREM DIVERGENTES OU NÃO ENCONTRAREM
	//O CADASTRO DO FORNECEDOR NO SISTEMA
	//O CADASTRO DE FORNECEDOR vs XML É VALIDADDO PELA FUNÇÃO XMLFOR()
	//XMLFOR() BUSCA CADASTRO DE FORNECEDOR PELO A2_CGC
	Private cDirDivFor 		:= "\\"+cIpServer+"\xml jaracatia distribuidora - divergencia fornecedores\"
	//==============================================================================================================

	aAdd(aNomCpoXml, "")
	aAdd(aTamCpoXml, 5)
	aAdd(aCpoXml, "COR")
	aEval(ApBuildHeader("SZX", Nil), {|x| aAdd(aCpoXml, x[2])})
	aEval(ApBuildHeader("SZX", Nil), {|x| aAdd(aNomCpoXml, x[1])})
	aEval(ApBuildHeader("SZX", Nil), {|x| aAdd(aTamCpoXml, x[4]+30)})
	aAdd(aCpoXml, "R_E_C_N_O_")
	aAdd(aNomCpoXml, "Recno SZX")
	aAdd(aTamCpoXml, 15)

	aEval(ApBuildHeader("SZI", Nil), {|x| aAdd(aFields, x[2])})

	aAdd(aHeaderEx, {"Prod.","CLEG1","@BMP",2,0,".F.","","C","","V","","","","V"})
	aAdd(aHeaderEx, {"Ped.","CLEG2","@BMP",2,0,".F.","","C","","V","","","","V"})

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For i := 1 To Len(aFields)
		If SX3->(DbSeek(aFields[i]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			IIF(SX3->X3_CAMPO == "ZI_FDESC  " .OR. SX3->X3_CAMPO == "ZI_SDESC  ",(SX3->X3_TAMANHO-(SX3->X3_TAMANHO*0.50)),SX3->X3_TAMANHO),;
			SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next i
	aAdd(aHeaderEx, {"Recno SZI","R_E_C_N_O_","@!",15,0,"","","C","","R","",""})

	oProcess := MsNewProcess():New({|| XML02ATU()},"Lendo Arquivos XML...","Aguarde...",.F.)
	oProcess:Activate()

	//INSTACIANDO O TOTALIZADORES PARA SOMATORIO DOS VALORES
	aAdd(aBrGeral, {0,0,0,0,0,0,0,0})

	DEFINE MSDIALOG oDlgXML TITLE "Importação de XML -> NF-e/CT-e" FROM 000, 000  TO 603, 1349 COLORS 0, 16777215 PIXEL 

	@ 002, 002 BUTTON oBtGera PROMPT "|*-*|  Gerar NF-e/CT-e  |*-*|" SIZE 080, 015 OF oDlgXML ACTION VALNFECTE() PIXEL

	@ 005, 490 BUTTON oBtRefresh PROMPT "Refresh" SIZE 037, 012 OF oDlgXML ACTION {|| REFRESHXML()} PIXEL

	@ 002, 632 SAY oSay3 PROMPT "Tipo de Nota" SIZE 049, 007 OF oDlgXML COLORS 0, 16777215 PIXEL
	@ 009, 632 MSCOMBOBOX oTpNfota VAR cTpNfota ITEMS {"NF-e","CT-e"} SIZE 038, 010 OF oDlgXML COLORS 0, 16777215 ON CHANGE CHANGETPNF() PIXEL 

	@ 002, 532 SAY oSay14 PROMPT "Status" SIZE 049, 007 OF oDlgXML COLORS 0, 16777215 PIXEL
	@ 009, 532 MSCOMBOBOX oStatusXML VAR cStatusXML ITEMS {"Docto. não Classificado","Docto. Normal","Ambas"} SIZE 100, 010 OF oDlgXML COLORS 0, 16777215 ON CHANGE CHANGETPNF() PIXEL 

	//EVENTOS
	@ 025, 635 BUTTON oBtFiltro PROMPT "Filtrar" SIZE 040, 012 OF oDlgXML ACTION {|| MsgRun("Filtrando "+cTpNfota+". Aguarde... ","Filtrar "+cTpNfota,{|| XMLFILTRO()})} PIXEL
	@ 042, 635 BUTTON oBtEntrada PROMPT "Conf. Entr." SIZE 040, 012 OF oDlgXML ACTION {|| CONFENTRA()} PIXEL

	//SOMETE USUARIOS AUTORIZADOS PODEM REALIZAR AJUSTE DE PREÇO
	If cUserName $ "DARLAN/VIRGILIO/MAYCON.ADMIN"
		@ 059, 635 BUTTON oBtTabPrc PROMPT "Ajuste Preço" SIZE 040, 012 OF oDlgXML ACTION {|| AJUSTAPRC()} PIXEL
	EndIf
	@ 076, 635 BUTTON oBtDivFor PROMPT "Nf.Div/Fornece" SIZE 040, 012 OF oDlgXML ACTION XMLDIVFOR() PIXEL
	@ 093, 635 BUTTON oBtTree PROMPT "Arvore XML" SIZE 040, 012 OF oDlgXML ACTION XMLTREE() PIXEL
	@ 110, 635 BUTTON oBtVoltaNf PROMPT "Voltar Nf" SIZE 040, 012 OF oDlgXML ACTION XMLVOLTA() PIXEL
	@ 127, 635 BUTTON oBtMan PROMPT "Manifestar Nf" SIZE 040, 012 OF oDlgXML ACTION u_XML02MAN() PIXEL

	//TELA DE CABEÇALHO DO XML 
	//oGetXml := TWBrowse():New(021,002,669,095,,aNomCpoXml,aTamCpoXml,oDlgXML,,,,{|| CHANGEXML()},,,,,,,,.F.,,.T.,,.F.,,,)
	oGetXml := TWBrowse():New(021,002,630,095,,aNomCpoXml,aTamCpoXml,oDlgXML,,,,{|| CHANGEXML()},,,,,,,,.F.,,.T.,,.F.,,,)

	SEEKGETXML()
	FGETXML()

	//FACILITADOR DE AMARRAÇÃO PRODUTO VS FORNECEDOR
	SetKey(VK_F2, {|| XML02F2()})

	//AMARRAR PED. DE COMPRA
	SetKey(VK_F4, {|| XML02F4()})
	@ 120, 002 BUTTON oBtPed PROMPT "Item do Ped Compra [F4]" SIZE 074, 012 OF oDlgXML ACTION XML02F4() PIXEL 

	//DESFAZ AMARRAÇÃO DO PRODUTO
	//APENAS LIMPA AMARRAÇÃO DO PRODUTO DA LINHA SELECIONADA
	SetKey(VK_F5, {|| XML02F5()})
	@ 120, 083 BUTTON oBtDesfaz PROMPT "Desf. Amarração [F5]" SIZE 074, 012 OF oDlgXML ACTION XML02F5() PIXEL

	//VERIFICA NCM X CEST DO PRODUTO
	SetKey(VK_F6, {|| XML02F6()})
	@ 120, 164 BUTTON oBtNCM PROMPT "Atual. N.C.M/CEST [F6]" SIZE 074, 012 OF oDlgXML ACTION XML02F6() PIXEL

	//PROGRAMA DE CONVERSÃO DE UNIDADE DE MEDIDA
	SetKey(VK_F7, {|| XMLUM()})
	@ 120, 245 BUTTON oBtUM PROMPT "Conversão UM [F7]" SIZE 074, 012 OF oDlgXML ACTION XMLUM() PIXEL

	//===========================================
	//SEMI-AUTOMATIZAÇÃO DO CADASTRO DO PRODUTO	=
	//===========================================
	@ 120, 326 BUTTON oBtCad PROMPT "Semi-Cad. Produto" SIZE 074, 012 OF oDlgXML ACTION CHCADPROD() PIXEL

	//TELA DOS ITENS DO XML
	//oGetItem := MsNewGetDados():New(136,002,236,671,GD_INSERT+GD_DELETE+GD_UPDATE,/*"LINHAOK"*/,,,aAlterFields,,Len(aColsEx),/*"TUDOOK"*/,,,oDlgXML,aHeaderEx,aColsEx,,)
	oGetItem := MsNewGetDados():New(136,002,236,633,GD_INSERT+GD_DELETE+GD_UPDATE,/*"LINHAOK"*/,,,aAlterFields,,Len(aColsEx),/*"TUDOOK"*/,,,oDlgXML,aHeaderEx,aColsEx,,)
	oGetItem:oBrowse:bDelete := {|| .F.}

	//FOLDER DE AMOSTRAGEM DE INFORMAÇÕES SOBRE NFE/CTE
	@ 238, 002 FOLDER oFolder1 SIZE 630, 063 OF oDlgXML ITEMS "Informações(Doc. Selecionado)","Totalizadores(Doc. Selecionado)","Totalizadores - Geral" COLORS 0, 16777215 PIXEL

	//INFORMAÇÕES GERAIS - oFolder1:aDialogs[1]
	@ 000, 001 GROUP oGroup4 TO 044, 234 PROMPT "Dados Remetente" OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
	@ 012, 005 SAY oSay5 PROMPT "CNPJ:" SIZE 027, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 011, 045 MSGET oCgcReme VAR cCgcReme SIZE 115, 010 OF oFolder1:aDialogs[1] PICTURE "@R 99.999.999/9999-99" WHEN .F. COLORS 0, 16777215 PIXEL
	@ 030, 005 SAY oSay6 PROMPT "Nome/Razão:" SIZE 038, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 027, 045 MSGET oNomReme VAR cNomReme SIZE 182, 010 OF oFolder1:aDialogs[1] WHEN .F. COLORS 0, 16777215 PIXEL

	@ 000, 235 GROUP oGroup5 TO 044, 467 PROMPT "Dados Destinatário" OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
	@ 012, 240 SAY oSay7 PROMPT "CNPJ:" SIZE 027, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 011, 281 MSGET oCgcDest VAR cCgcDest SIZE 115, 010 OF oFolder1:aDialogs[1] PICTURE "@R 99.999.999/9999-99" WHEN .F. COLORS 0, 16777215 PIXEL
	@ 030, 240 SAY oSay8 PROMPT "Nome/Razão:" SIZE 038, 007 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 027, 281 MSGET oNomDest VAR cNomDest SIZE 182, 010 OF oFolder1:aDialogs[1] WHEN .F. COLORS 0, 16777215 PIXEL

	@ 000, 469 GROUP oGroup6 TO 044, 629 PROMPT "Observação Nota Fiscal" OF oFolder1:aDialogs[1] COLOR 0, 16777215 PIXEL
	@ 007, 472 GET oObsNf VAR cObsNf OF oFolder1:aDialogs[1] WHEN .F. MULTILINE SIZE 155, 034  COLORS 0, 16777215 HSCROLL PIXEL
	//--

	//FINANÇAS - oFolder1:aDialogs[2]
	@ 011, 002 MSGET oCondPag VAR cCondPag SIZE 060, 010 OF oFolder1:aDialogs[2] COLORS 0, 16777215 F3 "SE4" HASBUTTON PIXEL
	@ 002, 002 SAY oSay1 PROMPT "Codição de Pag." SIZE 048, 007 OF oFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL

	oBrTotais := TWBrowse():New(002,092,534,045,,aCpoTotais,{},oFolder1:aDialogs[2],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	aAdd(aBrTotais, {"Valor Total dos Produtos","Vl. Desconto","Vl. Despesas","Vl. Frete","Base de Cálculo ICMS","Valor do ICMS","Valor Total do IPI","Valor Total da NFe"})
	ATUATOTAIS()
	//--

	//TOTALIZADORES - GERAL - oFolder1:aDialogs[3]
	oBrGeral := TWBrowse():New(002,092,534,045,,aCpoGeral,{},oFolder1:aDialogs[3],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	ATUAGERAL()
	//--

	//XML - oFolder1:aDialogs[3]
	//@ 002, 002 GET oMemoXml VAR cMemoXml OF oFolder1:aDialogs[3] MULTILINE SIZE 623, 044  WHEN .F. COLORS 0, 16777215 HSCROLL PIXEL 

	@ 238, 635 BUTTON oBtClose PROMPT "Sair >>" SIZE 037, 012 OF oDlgXML ACTION oDlgXML:End() PIXEL 

	ACTIVATE MSDIALOG oDlgXML CENTERED

	SetKey(VK_F2, {|| Nil})
	SetKey(VK_F4, {|| Nil})
	SetKey(VK_F5, {|| Nil})
	SetKey(VK_F6, {|| Nil})
	SetKey(VK_F7, {|| Nil})

Return


//==============================
//REFRESH NO GRID - XML        =
//==============================
Static Function REFRESHXML()

	oProcess := MsNewProcess():New({|| XML02ATU()},"Lendo Arquivos XML...","Aguarde...",.F.)
	oProcess:Activate()

	SEEKGETXML()
	FGETXML()
	CHANGEXML()
	ATUAGERAL()

Return


//======================================
//ALTERA TIPO DE EXIBIÇÃO DAS NOTAS    =
//XML - NF-e OU CT-e                   =
//======================================
Static Function CHANGETPNF()

	MsgRun("Pesquisando "+cTpNfota+". Aguarde... ","Pesquisa "+cTpNfota,{|| SEEKGETXML(), FGETXML(), CHANGEXML(), ATUAGERAL()})

	//{"NF-e","CT-e"} 
	//ENABLE or DISABLE
	If cTpNfota == "CT-e"
		oBtPed:Disable()
		oBtDesfaz:Disable()
		oBtNCM:Disable()
		oBtUM:Disable()

		SetKey(VK_F2, {|| Nil})
		SetKey(VK_F4, {|| Nil})
		SetKey(VK_F5, {|| Nil})
		SetKey(VK_F6, {|| Nil})
		SetKey(VK_F7, {|| Nil})

	ElseIf cTpNfota == "NF-e"

		oBtPed:Enable()
		oBtDesfaz:Enable()
		oBtNCM:Enable()
		oBtUM:Enable()

		SetKey(VK_F2, {|| XML02F2()})
		SetKey(VK_F4, {|| XML02F4()})
		SetKey(VK_F5, {|| XML02F5()})
		SetKey(VK_F6, {|| XML02F6()})
		SetKey(VK_F7, {|| XMLUM()})

	EndIf

Return


//============================
//BUSCA DADOS INICIAIS       =
//============================
Static Function SEEKGETXML()

	Local aAreaXml		:= GetArea()
	Local cAliasSZX
	Local cSqlSZX
	Local aGetXmlAux
	Local i

	aGetXml := {}

	If Select("SF1") > 0
		SF1->(DbCloseArea())
	EndIf

	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))

	DbSelectArea("SZX")
	SZX->(DbSetOrder(1))

	cAliasSZX := GetNextAlias()
	cSqlSZX := "SELECT SZX.R_E_C_N_O_ AS RENOSZX "+CRLF
	cSqlSZX += "FROM "+RetSqlName("SZX")+" SZX "+CRLF
	cSqlSZX += "WHERE "+CRLF
	//cStatusXML {"Docto. não Classificado","Docto. Normal","Ambas"}
	If cStatusXML == "Docto. não Classificado"
		cSqlSZX += "      SZX.ZX_ENTRADA = 'F' AND "+CRLF
	ElseIf cStatusXML == "Docto. Normal"
		cSqlSZX += "      SZX.ZX_ENTRADA = 'T' AND "+CRLF
	EndIf
	cSqlSZX += "      SZX.ZX_FORNECE NOT IN ('000002','000636') AND "+CRLF
	cSqlSZX += "      SZX.ZX_TIPOXML = '"+IIF(cTpNfota == "NF-e","NFE  ","CTE  ")+"' AND "+CRLF
	cSqlSZX += "	  SZX.D_E_L_E_T_ = '' "+CRLF	
	cSqlSZX += "ORDER BY SZX.ZX_FILIAL, SZX.ZX_EMISSAO DESC"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZX),cAliasSZX,.T.,.F.)

	(cAliasSZX)->(DbGoTop())

	aBrGeral := {}
	aAdd(aBrGeral, {0,0,0,0,0,0,0,0})
	If !(cAliasSZX)->(Eof())
		While !(cAliasSZX)->(Eof())

			aGetXmlAux := {}

			SZX->(DbGoTo((cAliasSZX)->RENOSZX))

			//ATUALIZANDO TOTALIZADORES
			//aAdd(aBrGeral, {SZX->ZX_VALMERC,SZX->ZX_VALDESC,SZX->ZX_BASEICM,SZX->ZX_VALICM,SZX->ZX_VALIPI,SZX->ZX_VALBRUT})
			aBrGeral[1,1] += SZX->ZX_VALMERC
			aBrGeral[1,2] += SZX->ZX_VALDESC
			aBrGeral[1,3] += SZX->ZX_DESPESA
			aBrGeral[1,4] += SZX->ZX_FRETE
			aBrGeral[1,5] += SZX->ZX_BASEICM
			aBrGeral[1,6] += SZX->ZX_VALICM
			aBrGeral[1,7] += SZX->ZX_VALIPI
			aBrGeral[1,8] += SZX->ZX_VALBRUT
			//=====

			If !SF1->(DbSeek(SZX->ZX_FILIAL+SZX->ZX_CHVNFE))
				For i := 1 To Len(aCpoXml)
					If aCpoXml[i] == "COR"
						If SZX->ZX_ENTRADA
							aAdd(aGetXmlAux, oVermelho)
						Else
							aAdd(aGetXmlAux, oVerde)
						EndIf
					ElseIf aCpoXml[i] == "R_E_C_N_O_"
						aAdd(aGetXmlAux, SZX->(Recno()))
					Else
						aAdd(aGetXmlAux, SZX->&(aCpoXml[i]))
					EndIf
				Next i
				aAdd(aGetXml, aGetXmlAux)
			Else
				If !SZX->ZX_ENTRADA 
					RecLock("SZX", .F.)
					SZX->ZX_ENTRADA := .T.
					SZX->(MsUnLock())
				EndIf
				For i := 1 To Len(aCpoXml)
					If aCpoXml[i] == "COR"
						If SZX->ZX_ENTRADA
							aAdd(aGetXmlAux, oVermelho)
						Else
							aAdd(aGetXmlAux, oVerde)
						EndIf
					ElseIf aCpoXml[i] == "R_E_C_N_O_"	
						aAdd(aGetXmlAux, SZX->(Recno()))
					Else
						aAdd(aGetXmlAux, SZX->&(aCpoXml[i]))
					EndIf
				Next i
				aAdd(aGetXml, aGetXmlAux)
			EndIf
			(cAliasSZX)->(DbSkip())
		EndDo
	Else
		aGetXmlAux := {}
		For i := 1 To Len(aCpoXml)
			If aCpoXml[i] == "R_E_C_N_O_" 
				aAdd(aGetXmlAux, 0)
			ElseIf aCpoXml[i] == "COR"
				aAdd(aGetXmlAux, oVermelho)
			Else
				aAdd(aGetXmlAux, CriaVar(aCpoXml[i]))
			EndIf
		Next i
		aAdd(aGetXml, aGetXmlAux)
	EndIf
	(cAliasSZX)->(DbCloseArea())

	RestArea(aAreaXml)

Return


//=====================================
//ATUALIZA A TELA DE CABEÇALHO DO XML =
//=====================================
Static Function FGETXML()

	oGetXml:SetArray(aGetXml)
	oGetXml:bLine := {|| {aGetXml[oGetXml:nAt,1],;
	aGetXml[oGetXml:nAt,2],aGetXml[oGetXml:nAt,3],aGetXml[oGetXml:nAt,4],;
	aGetXml[oGetXml:nAt,5],aGetXml[oGetXml:nAt,6],;
	IIF(ValType(aGetXml[oGetXml:nAt,7]) == "D",aGetXml[oGetXml:nAt,7],StoD(aGetXml[oGetXml:nAt,7])),;
	aGetXml[oGetXml:nAt,8],;
	Transform(aGetXml[oGetXml:nAt,9],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,10],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,11],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,12],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,13],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,14],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,15],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,16],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,17],"@E 999,999,999.99"),;
	aGetXml[oGetXml:nAt,18],;
	Transform(aGetXml[oGetXml:nAt,19],"@E 999,999,999.99"),;
	Transform(aGetXml[oGetXml:nAt,20],"@E 999,999,999.99"),;
	aGetXml[oGetXml:nAt,21],;
	aGetXml[oGetXml:nAt,22],;
	aGetXml[oGetXml:nAt,23],;
	aGetXml[oGetXml:nAt,24],;
	aGetXml[oGetXml:nAt,25],;
	aGetXml[oGetXml:nAt,26]}}
	oGetXml:bLDblClick := {|| }
	oGetXml:nScrollType := 1
	oGetXml:Refresh()

Return


//=====================================================
//PROGRAMA EXECUTADO QUANDO CLICAMOS NO GRID DO XML   =
//=====================================================
Static Function CHANGEXML()

	Local cAliasITE
	Local cSqlITE
	Local aColsExAux
	Local i 

	aColsEx := {}

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	cAliasITE := GetNextAlias()
	cSqlITE := "SELECT * "+CRLF
	cSqlITE += "FROM "+RetSqlName("SZI")+" SZI "+CRLF
	cSqlITE += "WHERE "+CRLF 
	cSqlITE += "      SZI.ZI_FILIAL  = '"+SZX->ZX_FILIAL+"'  AND "+CRLF
	cSqlITE += "      SZI.ZI_DOC     = '"+SZX->ZX_DOC+"'     AND "+CRLF
	cSqlITE += "      SZI.ZI_SERIE   = '"+SZX->ZX_SERIE+"'   AND "+CRLF
	cSqlITE += "      SZI.ZI_FORNECE = '"+SZX->ZX_FORNECE+"' AND "+CRLF
	cSqlITE += "      SZI.ZI_LOJA    = '"+SZX->ZX_LOJA+"'    AND "+CRLF
	//cSqlITE += "      SZI.ZI_NUMPED  = '"+SZX->ZX_NUMPED+"'  AND "+CRLF
	cSqlITE += "      SZI.D_E_L_E_T_ = '' "+CRLF
	cSqlITE += "ORDER BY SZI.ZI_SEQUEN"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlITE),cAliasITE,.T.,.F.)

	(cAliasITE)->(DbGoTop())

	If !(cAliasITE)->(Eof())
		While !(cAliasITE)->(Eof())

			aColsExAux := {}

			aAdd(aColsExAux, IIF(Empty((cAliasITE)->ZI_B1COD),oCLEG2,oCLEG1)) 
			aAdd(aColsExAux, IIF(Empty((cAliasITE)->ZI_NUMPED),oCLEG2,oCLEG1))

			For i := 1 To Len(aHeaderEx)
				If !(aHeaderEx[i,2] $ "CLEG1/CLEG2")
					aAdd(aColsExAux, (cAliasITE)->&(aHeaderEx[i,2]))
				EndIf
			Next i

			aAdd(aColsExAux, .F.)
			aAdd(aColsEx, aColsExAux)

			(cAliasITE)->(DbSkip())
		EndDo
	Else
		aColsExAux := {}
		aAdd(aColsExAux, oCLEG2)
		aAdd(aColsExAux, oCLEG2)
		For i := 1 To Len(aHeaderEx)
			If !(aHeaderEx[i,2] $ "CLEG1/CLEG2")
				aAdd(aColsExAux, IIF(aHeaderEx[i,2] == "R_E_C_N_O_",0,CriaVar(aHeaderEx[i,2])))
			EndIf
		Next i
		aAdd(aColsExAux, .F.)
		aAdd(aColsEx, aColsExAux)
	EndIf
	(cAliasITE)->(DbCloseArea())

	//ATUALIZA INFORMAÇÕES DE REMETENTE E DESTINATARIO E OBS NOTA FISCAL
	cCgcReme := Posicione("SA2",1,xFilial("SA2")+SZX->ZX_FORNECE,"A2_CGC")
	cNomReme := Posicione("SA2",1,xFilial("SA2")+SZX->ZX_FORNECE,"A2_NOME")
	cCgcDest := IIF(SZX->ZX_FILIAL == "0101","05725071000175","05725071000256")
	cNomDest := IIF(SZX->ZX_FILIAL == "0101","JARACATIA DISTRIBUIDORA LTDA","JARACATIA DISTRIBUIDORA LTDA")
	cObsNf 	 := SZX->ZX_OBSNF
	//cMemoXml := SZX->ZX_XML	
	oCgcReme:Refresh()
	oNomReme:Refresh()
	oCgcDest:Refresh()
	oNomDest:Refresh()
	oObsNf:Refresh()
	//oMemoXml:Refresh()
	//--

	//ATUALIZA INFORMAÇÕES DO FINANCEIRO
	aBrTotais := {}
	aAdd(aBrTotais, {SZX->ZX_VALMERC,SZX->ZX_VALDESC,SZX->ZX_DESPESA,SZX->ZX_FRETE,SZX->ZX_BASEICM,SZX->ZX_VALICM,SZX->ZX_VALIPI,SZX->ZX_VALBRUT})
	ATUATOTAIS()
	//--

	//VALIDAÇÃO SE FOR UM CTE
	//DESATIVA OU ATIVA GRID ITENS XML
	If AllTrim(SZX->ZX_TIPOXML) == "CTE"
		oGetItem:Disable()
	Else
		oGetItem:Enable()
	EndIf

	//ATUALIZA O GRID ITENS DO XML
	oGetItem:SetArray(aColsEx)
	oGetItem:oBrowse:Refresh()
	//--

Return


//========================================
//BUSCA INFORMAÇÕES TA TELA DE XML'S     =
//GRAVA E ATUALIZA A TABELA SZX E SZI	 =
//========================================
Static Function XML02ATU()

	Local cFilXml
	Local cDescProd
	Local cDoc
	Local cSerie
	Local aFornece
	Local cFornece
	Local cLoja
	Local dEmissao
	Local cEst
	Local nFrete
	Local nDespesa
	Local nBaseIcm
	Local nValIcm
	Local nBaseIpi
	Local nValIpi
	Local nValMerc
	Local nValBrut
	Local cTipo
	Local nBriCms
	Local nIcmsRet
	Local aB1_COD
	Local cChvNFE
	Local cChvCTE
	Local cTipoXml
	Local cError 		:= ""
	Local cWarning 		:= ""
	Local aItensXml		:= {}
	Local aSX3COD
	Local cSequen 		:= 0
	Local cSequenAux	
	Local nCont
	Local cPrevErr
	Local aFiles		:= {}
	Local oXml
	Local i
	Local cXmlObsNf
	Local cLocOrig 		:= ""
	Local cLocDest 		:= ""
	Local nStatusDir
	Local cContXml
	Local cClassFis
	Local cOrig         := ""

	//ADir(AllTrim(cPatch)+"*.xml",aFiles)
	aFiles := Directory(cPatch+"*.xml", "D") 

	oProcess:SetRegua1(Len(aFiles))

	For i := 1 To Len(aFiles)

		oProcess:IncRegua1("Processando arquivos XML's.")

		cError 	 := ""
		cWarning := ""

		oXml := XmlParser(MemoRead(cPatch+aFiles[i,1]),"_",@cError,@cWarning)

		//=============================================================================================
		//CONTROLE DE ERRO DE LEITURA DO ARQUIVO XML
		If !Empty(cError)
			
			cPrevErr := "Erro na leitura do arquivo: "+cPatch+aFiles[i,1]

			nCont := Aviso("Atenção",cPrevErr+CRLF+CRLF+cError,{"Continuar","Abortar Oper."},3)

			If nCont == 1

				//=========================================
				//REMOVENDO ARQUIVO COM ERRO DE LEITURA   =
				//=========================================
				cLocOrig := ""
				cLocDest := ""

				cLocOrig := cPatch + aFiles[i,1]
				cLocDest := cDirErrLei + aFiles[i,1]
				nStatusDir := fRename(cLocOrig,cLocDest)

				If nStatusDir < 0
					MsgInfo("Num erro FError(): "+cValToChar(FError()))
				Else
					cError 		:= ""
					cWarning 	:= ""
					oXml 		:= XmlParserFile(cDirErrXml+aFiles[i,1],"_",@cError,@cWarning)

					If !Empty(cError)
						cPrevErr2 := "Erro na leitura do arquivo root: "+cDirErrXml+aFiles[i,1]
						Aviso("Atenção",cPrevErr2+CRLF+CRLF+cError,{"Continuar"},3)
						Loop
					Else
						//PEGO ARQUIVO NA cDirErrLei + aFiles[i,1]
						//JOGO NA PASTA DE IMPORTADOS
						cLocOrig := cDirErrLei + aFiles[i,1]
						cLocDest := cDirDest + aFiles[i,1]
						nStatusDir := fRename(cLocOrig,cLocDest)

						If nStatusDir < 0
							MsgInfo("Num erro FError(): "+cValToChar(FError()))
							Loop
						EndIf				
					EndIf
				EndIf
			Else
				MsgInfo("Operação Abortatada! Leitura dos arquivos XML encerrada: "+cPatch)
				Return
			EndIf
		EndIf
		//=============================================================================================

		cSequen := 0

		///cContXml := GRVMOMOXML(cPatch+aFiles[i,1]) OPERAÇÃO FOI ABORTADA O SISTEMA NÃO SUPORTA TANDO BUFFER
		cContXml := cPatch+aFiles[i,1]

		//XML - NFE		
		If XmlChildEx(oXml, "_NFEPROC") != Nil
			//
			cTipoXml := "NFE"

			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DEST,"_CNPJ") != Nil
				If oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == '05725071000175' //SM0->M0_CGC - VAREJO 0101
					cFilXml := '0101'
				ElseIf oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == '05725071000256' //SM0->M0_CGC - ATACADO 0102
					cFilXml := '0102'
				Else
					Loop
				EndIf
			Else
				Loop
			EndIf

			cDoc 	 := StrZero(Val(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),9,0)//NUMERO DOCUMENTO
			cSerie 	 := oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT//SERIE
			//cSerie := StrZero(Val(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT),3,0)//SERIE
			aFornece := XMLFOR(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT,oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT)//FUNÇÃO RETORNANDO O NUMERO DO FORNECEDOR PASSANDO O CNPJ

			If Empty(aFornece[1])

				//====================================================================
				//REMOVENDO ARQUIVO COM DIVERGENCIA NO CADASTRO COM FORNECEDORES     =
				//====================================================================
				cLocOrig := ""
				cLocDest := ""

				cLocOrig := cPatch + aFiles[i,1]
				cLocDest := cDirDivFor + aFiles[i,1]
				nStatusDir := fRename(cLocOrig,cLocDest)

				If nStatusDir < 0
					MsgInfo("Num erro FError(): "+cValToChar(FError()))
				EndIf
				//====================================================================

				Loop

			EndIf

			cXmlObsNf   := ""
			//cNomeFor 	:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT //NOME FORNECEDOR
			cNomeFor 	:= aFornece[3] //NOME FORNECEDOR
			cLoja 		:= aFornece[2] //LOJA DO FORNECEDOR
			dEmissao 	:= STOD(Replace(SubStr(oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT,1,10),"-",""))//DATA DE EMISSAO DA NOTA
			cEst 		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT//ESTADO DO FORNECEDOR
			nFrete 		:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT//FRETE
			nDespesa 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:TEXT//DESPESAS
			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VDESC") != Nil
				nValDesc 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT
			Else
				nValDesc 	:= 0
			EndIf
			nBaseIcm 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT//BASE ICM
			nValIcm 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT//VALOR ICM
			nBaseIpi 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VII:TEXT//BASE IPI
			nValIpi 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT//VALOR DO IPI
			nValMerc 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT//VALOR DA MERCADORIA
			nValBrut 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT//VALOR BRUTO
			cTipo 		:= 'N'
			nBriCms 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT// VALOR BRUTO ICMS
			nZRIcmsRet 	:= oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT//ICMS RETIDO
			cChvNFE 	:= oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT//CHAVE DE ACESSO DO DOCUMENTO

			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE,"_INFADIC") != Nil		
				If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_INFADIC,"_INFADFISCO") != Nil
					cXmlObsNf += oXml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT
				EndIf
				If !Empty(cXmlObsNf)
					cXmlObsNf += CRLF
				EndIf
				If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_INFADIC,"_INFCPL") != Nil
					cXmlObsNf += oXml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT
				EndIf
			EndIf

			If Len(cSerie) == 1
				cSerie := cSerie+"  "
			ElseIf Len(cSerie) == 2
				cSerie := cSerie+" "
			EndIf

			DbSelectArea("SZX")
			SZX->(DbSetOrder(1))
			If !SZX->(DbSeek(cFilXml+cDoc+cSerie+cChvNFE))

				RecLock("SZX", .T.)
				SZX->ZX_FILIAL 	:= cFilXml
				SZX->ZX_DOC 	:= cDoc
				SZX->ZX_SERIE 	:= cSerie
				SZX->ZX_FORNECE := aFornece[1]
				SZX->ZX_NOMEFOR := cNomeFor
				SZX->ZX_LOJA 	:= cLoja
				SZX->ZX_EMISSAO := dEmissao
				SZX->ZX_EST 	:= cEst
				SZX->ZX_FRETE 	:= Val(nFrete)
				SZX->ZX_DESPESA := Val(nDespesa)
				SZX->ZX_VALDESC := Val(nValDesc)
				SZX->ZX_BASEICM := Val(nBaseIcm)
				SZX->ZX_VALICM 	:= Val(nValIcm)
				SZX->ZX_BASEIPI := Val(nBaseIpi)
				SZX->ZX_VALIPI 	:= Val(nValIpi)
				SZX->ZX_VALMERC := Val(nValMerc)
				SZX->ZX_VALBRUT := Val(nValBrut)
				SZX->ZX_TIPO 	:= cTipo
				SZX->ZX_BRICMS 	:= Val(nBriCms)
				SZX->ZX_ICMSRET := Val(nZRIcmsRet)
				SZX->ZX_CHVNFE 	:= cChvNFE
				SZX->ZX_ENTRADA := .F.
				SZX->ZX_OBSNF	:= cXmlObsNf
				SZX->ZX_TIPOXML	:= cTipoXml
				//SZX->ZX_XML		:= cContXml
				SZX->(MsUnLock())

			EndIf

			//ITENS DA NOTA FISCAL XML
			DbSelectArea("SZI")
			SZI->(DbSetOrder(4)) //ZI_FILIAL+ZI_DOC+ZI_SERIE+ZI_FORNECE+ZI_SEQUEN+ZI_CODPROD

			If ValType(oXml:_NFEPROC:_NFE:_INFNFE:_DET) == "O"

				oProcess:SetRegua2(1)

				oProcess:IncRegua2("Processando itens do XML.")

				cProd 		:= oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				cEAN		:= oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT		
				cDescProd   := Upper(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT)
				nQtd 		:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				nVunit 		:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
				nValDesc 	:= 0 //só de desegurança, zero a variavel
				If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD, "_VDESC") != Nil
					nValDesc	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
				Else
					nValDesc	:= 0
				EndIf
				nVlUnIndex 	:= oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT
				nVlUnIndex  += Space(TamSX3('ZI_VUNIT')[1]-Len(nVlUnIndex))//CORREÇÃO DO INDEX
				cUm 		:= oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT
				cNcm		:= oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD, "_CFOP") != Nil
					cCfop	:= oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT+Space(TamSx3("ZI_CF")[1] - Len(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT))
				Else
					cCfop := Space(TamSx3("ZI_CF")[1])
				EndIf

				//PARTE DE REUNIÃO DE VALORES DE IMPOSTO - ICMS E SUAS PARTICULARIDADES
				nVICMSRet := 0
				If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO, "_ICMS") != Nil
					If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS00") != Nil
						nPICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
						nVICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS10") != Nil
						nPICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
						nVICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS20") != Nil
						nPICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT)
						nVICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT)
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS20:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS20:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS30") != Nil
						nPICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS30:_PICMSST:TEXT)
						nVICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS30:_VICMSST:TEXT)
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS30:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS30:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS40") != Nil
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40, "_PICMS") != Nil .AND. ;
						XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40, "_VICMS") != Nil
							nPICMS := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_PICMS:TEXT)
							nVICMS := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_VICMS:TEXT)
						Else
							nPICMS := 0
							nVICMS := 0
						EndIf
						cClassFis  := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_CST:TEXT
						cOrig      := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS51") != Nil
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS51, "_PICMS") != Nil
							nPICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS51:_PICMS:TEXT)
						Else
							nPICMS := 0
						EndIf
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS51, "_VICMS") != Nil
							nVICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS51:_VICMS:TEXT)
						Else
							nVICMS := 0
						EndIf
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS51:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS51:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS60") != Nil
						//nPICMS	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT)
						nPICMS		:= 0
						nVICMS		:= 0
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_VICMSSTRET") != Nil
							nVICMSRet 	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_VICMSSTRET:TEXT)
						EndIf
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS70") != Nil
						nPICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS70:_PICMS:TEXT)
						nVICMS	  := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS70:_VICMS:TEXT)
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS70:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS70:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMS90") != Nil
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90, "_PICMS") != Nil
							nPICMS	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT)
							nVICMS	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_VICMS:TEXT)
						Else
							nPICMS := 0
							nVICMS := 0
						EndIf
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_CST:TEXT
						cOrig     := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT
					ElseIf XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS, "_ICMSPart") != Nil				
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSPart, "_PICMS") != Nil .AND. ;
						XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSPart, "_VICMS") != Nil
							nPICMS	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSPart:_PICMS:TEXT)
							nVICMS	:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSPart:_VICMS:TEXT)
						Else
							nPICMS	:= 0
							nVICMS	:= 0
						EndIf
						cClassFis := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSPart:_CST:TEXT
						cOrig 	  := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMSPart:_ORIG:TEXT
					Else
						nPICMS	  := 0
						nVICMS    := 0
						nVICMSRet := 0
						cClassFis := "   "
						cOrig	  := ""
					EndIf
				Else	
					nPICMS	  := 0
					nVICMS    := 0
					nVICMSRet := 0
					cClassFis := "   "
					cOrig     := ""
				EndIf

				//PARTE DE REUNIÃO DE VALORES DE IMPOSTO - IPI E SUAS PARTICULARIDADES
				If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO, "_IPI") != Nil
					If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI, "_IPITRIB") != Nil
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB, "_PIPI") != Nil
							nPIPI := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
						Else
							nPIPI := 0
						EndIf
						If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB, "_VIPI") != Nil
							nVIPI := Val(oXml:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
						Else
							nVIPI := 0
						EndIf
					Else
						nPIPI := 0
						nVIPI := 0
					EndIf
				Else
					nPIPI := 0
					nVIPI := 0
				EndIf

				//30 = TAMANHO DO CAMPO SZI->ZI_CODPROD
				aSX3COD := {}
				aSX3COD := TamSX3('ZI_CODPROD')
				cProd 	+= Space(aSX3COD[1]-Len(cProd))
				cSequen++

				cSequenAux := StrZero(cSequen,3,0)
				////ZI_FILIAL+ZI_DOC+ZI_SERIE+ZI_FORNECE+ZI_SEQUEN+ZI_CODPROD
				If !SZI->(DbSeek(cFilXml+cDoc+cSerie+aFornece[1]+cSequenAux+cProd))

					//BUSCA AMARRAÇÃO EXISTENTE PRODUTO X FORNECEDOR
					//JA GRAVA REGISTRO NA TABELA COM AMARRAÇÃO ENCONTRADA
					aB1_COD := GRVAMARRCAD(aFornece[1],aFornece[2],cProd)

					RecLock("SZI", .T.)
					SZI->ZI_FILIAL 	:= cFilXml
					SZI->ZI_SEQUEN	:= cSequenAux
					SZI->ZI_CODPROD := cProd
					SZI->ZI_FDESC	:= cDescProd
					SZI->ZI_QTD 	:= nQtd
					SZI->ZI_VUNIT 	:= nVunit
					SZI->ZI_VALDESC	:= nValDesc
					SZI->ZI_TOTAL 	:= nVunit * nQtd
					SZI->ZI_UM 		:= Upper(cUm)
					SZI->ZI_POSIPI  := cNcm
					SZI->ZI_B1COD 	:= aB1_COD[1]
					SZI->ZI_SDESC 	:= aB1_COD[2]
					SZI->ZI_DOC 	:= cDoc
					SZI->ZI_SERIE 	:= cSerie
					SZI->ZI_FORNECE := aFornece[1]
					SZI->ZI_NOMEFOR := cNomeFor
					SZI->ZI_LOJA    := aFornece[2]
					SZI->ZI_PICM	:= nPICMS
					SZI->ZI_VALICM	:= nVICMS
					SZI->ZI_IPI		:= nPIPI	
					SZI->ZI_VALIPI  := nVIPI
					SZI->ZI_CF		:= cCfop
					SZI->ZI_ICMSRET := nVICMSRet
					SZI->ZI_CLASFIS := cClassFis
					SZI->ZI_ORIG	:= cOrig
					SZI->ZI_CODBAR	:= cEAN
					SZI->(MsUnLock())

				EndIf

			ElseIf ValType(oXml:_NFEPROC:_NFE:_INFNFE:_DET) == "A"

				aItensXml := {}
				aItensXml := oXml:_NFEPROC:_NFE:_INFNFE:_DET

				oProcess:SetRegua2(Len(aItensXml))

				For x := 1 To Len(aItensXml)

					oProcess:IncRegua2("Processando itens do XML.")

					cProd 		:= aItensXml[x]:_PROD:_CPROD:TEXT
					cEAN		:= aItensXml[x]:_PROD:_CEAN:TEXT
					cDescProd   := Upper(aItensXml[x]:_PROD:_XPROD:TEXT)
					nQtd 		:= Val(aItensXml[x]:_PROD:_QCOM:TEXT)
					nVunit 		:= Val(aItensXml[x]:_PROD:_VUNCOM:TEXT)
					If XmlChildEx(aItensXml[x]:_PROD, "_VDESC") != Nil
						nValDesc	:= Val(aItensXml[x]:_PROD:_VDESC:TEXT)
					Else
						nValDesc	:= 0
					EndIf
					nVlUnIndex 	:= aItensXml[x]:_PROD:_VUNCOM:TEXT
					nVlUnIndex  += Space(TamSX3('ZI_VUNIT')[1]-Len(nVlUnIndex))//CORREÇÃO DO INDEX
					cUm 		:= aItensXml[x]:_PROD:_UCOM:TEXT
					cNcm		:= aItensXml[x]:_PROD:_NCM:TEXT
					If XmlChildEx(aItensXml[x]:_PROD, "_CFOP") != Nil
						cCfop	:= aItensXml[x]:_PROD:_CFOP:TEXT+Space(TamSx3("ZI_CF")[1] - Len(aItensXml[x]:_PROD:_CFOP:TEXT))
					Else
						cCfop := Space(TamSx3("ZI_CF")[1])
					EndIf

					//PARTE DE REUNIÃO DE VALORES DE IMPOSTO - ICMS E SUAS PARTICULARIDADES
					nVICMSRet := 0
					If XmlChildEx(aItensXml[x]:_IMPOSTO, "_ICMS") != Nil
						If XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS00") != Nil
							nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
							nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS00:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS10") != Nil
							nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
							nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS10:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS20") != Nil
							nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT)
							nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT)
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS20:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS20:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS30") != Nil
							nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS30:_PICMSST:TEXT)
							nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS30:_VICMSST:TEXT)
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS30:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS30:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS40") != Nil
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS40, "_PICMS") != Nil .AND. XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS40, "_VICMS") != Nil
								nPICMS := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS40:_PICMS:TEXT)
								nVICMS := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS40:_VICMS:TEXT)
							Else
								nPICMS := 0
								nVICMS := 0
							EndIf
							cClassFis  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS40:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS51") != Nil
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS51, "_PICMS") != Nil
								nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS51:_PICMS:TEXT)
							Else
								nPICMS := 0
							EndIf
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS51, "_VICMS") != Nil
								nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS51:_VICMS:TEXT)
							Else
								nVICMS := 0
							EndIf
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS51:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS51:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS60") != Nil
							//nPICMS	:= Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT)
							nPICMS 		:= 0
							nVICMS 		:= 0
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_VICMSSTRET") != Nil
								nVICMSRet 	:= Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS60:_VICMSSTRET:TEXT)
							EndIf
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS60:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT					
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS70") != Nil
							nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS70:_PICMS:TEXT)
							nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS70:_VICMS:TEXT)
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS70:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS70:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMS90") != Nil
							nPICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT)
							nVICMS	  := Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMS90:_VICMS:TEXT)
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS90:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT
						ElseIf XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS, "_ICMSPart") != Nil
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS:_ICMSPart, "_PICMS") != Nil .AND. ;
							XmlChildEx(aItensXml[x]:_IMPOSTO:_ICMS:_ICMSPart, "_VICMS") != Nil
								nPICMS	:= Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMSPart:_PICMS:TEXT)
								nVICMS	:= Val(aItensXml[x]:_IMPOSTO:_ICMS:_ICMSPart:_VICMS:TEXT)
							Else
								nPICMS	:= 0
								nVICMS	:= 0
							EndIf
							cClassFis := aItensXml[x]:_IMPOSTO:_ICMS:_ICMSPart:_CST:TEXT
							cOrig 	  := aItensXml[x]:_IMPOSTO:_ICMS:__ICMSPart:_ORIG:TEXT
						Else
							nPICMS	  := 0
							nVICMS    := 0
							nVICMSRet := 0
							cClassFis := "   "
							cOrig	  := "" 
						EndIf
					Else
						nPICMS	  := 0
						nVICMS    := 0
						nVICMSRet := 0
						cClassFis := "   "
						cOrig	  := "" 
					EndIf

					//PARTE DE REUNIÃO DE VALORES DE IMPOSTO - IPI E SUAS PARTICULARIDADES
					If XmlChildEx(aItensXml[x]:_IMPOSTO, "_IPI") != Nil
						If XmlChildEx(aItensXml[x]:_IMPOSTO:_IPI, "_IPITRIB") != Nil
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_IPI:_IPITRIB, "_PIPI") != Nil
								nPIPI := Val(aItensXml[x]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT)
							Else
								nPIPI := 0
							EndIf
							If XmlChildEx(aItensXml[x]:_IMPOSTO:_IPI:_IPITRIB, "_VIPI") != Nil
								nVIPI := Val(aItensXml[x]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT)
							Else
								nVIPI := 0
							EndIf
						Else
							nPIPI := 0
							nVIPI := 0
						EndIf
					Else
						nPIPI := 0
						nVIPI := 0
					EndIf

					//30 = TAMANHO DO CAMPO SZI->ZI_CODPROD
					aSX3COD := {}
					aSX3COD := TamSX3('ZI_CODPROD')
					cProd 	+= Space(aSX3COD[1]-Len(cProd))
					cSequen++

					cSequenAux := StrZero(cSequen,3,0)

					If !SZI->(DbSeek(cFilXml+cDoc+cSerie+aFornece[1]+cSequenAux+cProd))

						//BUSCA AMARRAÇÃO EXISTENTE PRODUTO X FORNECEDOR
						//JA GRAVA REGISTRO NA TABELA COM AMARRAÇÃO ENCONTRADA
						aB1_COD := GRVAMARRCAD(aFornece[1],aFornece[2],cProd)

						RecLock("SZI", .T.)
						SZI->ZI_FILIAL 	:= cFilXml
						SZI->ZI_SEQUEN	:= cSequenAux
						SZI->ZI_CODPROD := cProd
						SZI->ZI_FDESC	:= cDescProd
						SZI->ZI_QTD 	:= nQtd
						SZI->ZI_VUNIT 	:= nVunit
						SZI->ZI_VALDESC	:= nValDesc
						SZI->ZI_TOTAL 	:= nVunit * nQtd
						SZI->ZI_UM 		:= Upper(cUm)
						SZI->ZI_POSIPI  := cNcm
						SZI->ZI_B1COD 	:= aB1_COD[1]
						SZI->ZI_SDESC 	:= aB1_COD[2]
						SZI->ZI_DOC 	:= cDoc
						SZI->ZI_SERIE 	:= cSerie
						SZI->ZI_FORNECE := aFornece[1]
						SZI->ZI_NOMEFOR := cNomeFor
						SZI->ZI_LOJA 	:= aFornece[2]
						SZI->ZI_PICM	:= nPICMS
						SZI->ZI_VALICM	:= nVICMS
						SZI->ZI_IPI		:= nPIPI	
						SZI->ZI_VALIPI  := nVIPI
						SZI->ZI_CF		:= cCfop
						SZI->ZI_ICMSRET := nVICMSRet
						SZI->ZI_CLASFIS := cClassFis
						SZI->ZI_ORIG	:= cOrig
						SZI->ZI_CODBAR	:= cEAN
						SZI->(MsUnLock())

					EndIf

				Next x

			EndIf

			//====================================================================
			//REMOVENDO ARQUIVO APÓS A LEITURA E GRAVAÇÃO NAS TABELAS SZX E SZI  =
			//====================================================================
			cLocOrig := ""
			cLocDest := ""

			cLocOrig := cPatch + aFiles[i,1]
			cLocDest := cDirDest + aFiles[i,1]
			nStatusDir := fRename(cLocOrig,cLocDest)

			If nStatusDir < 0
				MsgInfo("Num erro FError(): "+cValToChar(FError()))
			EndIf
			//====================================================================

			//===============
			//XML - CTE     =
			//===============
		ElseIf XmlChildEx(oXml, "_CTEPROC") != Nil

			cTipoXml := "CTE"

			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_DEST,"_CNPJ") != Nil
				If oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT == '05725071000175' //SM0->M0_CGC - VAREJO 0101
					cFilXml := '0101'
				ElseIf oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT == '05725071000256' //SM0->M0_CGC - ATACADO 0102
					cFilXml := '0102'
				Else
					Loop
				EndIf
			Else
				Loop
			EndIf

			cDoc 	 := StrZero(Val(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT),9,0)//NUMERO DOCUMENTO
			cSerie 	 := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT//SERIE
			//cSerie := StrZero(Val(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT),3,0)//SERIE
			aFornece := XMLFOR(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT,oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)//FUNÇÃO RETORNANDO O NUMERO DO FORNECEDOR PASSANDO O CNPJ

			If Empty(aFornece[1])

				//====================================================================
				//REMOVENDO ARQUIVO COM DIVERGENCIA NO CADASTRO COM FORNECEDORES     =
				//====================================================================
				cLocOrig := ""
				cLocDest := ""

				cLocOrig := cPatch + aFiles[i,1]
				cLocDest := cDirDivFor + aFiles[i,1]
				nStatusDir := fRename(cLocOrig,cLocDest)

				If nStatusDir < 0
					MsgInfo("Num erro FError(): "+cValToChar(FError()))
				EndIf
				//====================================================================

				Loop

			EndIf

			//cNomeFor 	:= oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT //NOME FORNECEDOR
			cNomeFor 	:= aFornece[3] //NOME FORNECEDOR
			cLoja 		:= aFornece[2] //LOJA DO FORNECEDOR
			dEmissao 	:= STOD(Replace(SubStr(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,1,10),"-",""))//DATA DE EMISSAO DA NOTA
			cEst 		:= oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT//ESTADO DO FORNECEDOR
			nFrete 		:= 0 //FRETE
			nDespesa 	:= 0 //DESPESAS
			nBaseIcm 	:= 0 //BASE ICM
			nValIcm 	:= 0 //VALOR ICM
			nBaseIpi 	:= 0 //BASE IPI
			nValIpi 	:= 0 //VALOR DO IPI
			nValMerc 	:= oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT//VALOR DA MERCADORIA
			nValBrut 	:= oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT//VALOR BRUTO
			cTipo 		:= 'N'
			nBriCms 	:= 0 // VALOR BRUTO ICMS
			nZXIcmsRet 	:= 0 //ICMS RETIDO
			cChvCTE 	:= oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT//CHAVE DE ACESSO DO DOCUMENTO
			cXmlObsNf   := ""
			//cXmlObsNf 	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_COMPL:_OBSCONT:_XTEXTO:TEXT) //OBSERVAÇÃO DA NOTA - CTE

			If Len(cSerie) == 1
				cSerie := cSerie+"  "
			ElseIf Len(cSerie) == 2
				cSerie := cSerie+" "
			EndIf

			DbSelectArea("SZX")
			SZX->(DbSetOrder(1))
			If !SZX->(DbSeek(cFilXml+cDoc+cSerie+cChvCTE))

				RecLock("SZX", .T.)
				SZX->ZX_FILIAL 	:= cFilXml
				SZX->ZX_DOC 	:= cDoc
				SZX->ZX_SERIE 	:= cSerie
				SZX->ZX_FORNECE := aFornece[1]
				SZX->ZX_NOMEFOR := cNomeFor
				SZX->ZX_LOJA 	:= aFornece[2]
				SZX->ZX_EMISSAO := dEmissao
				SZX->ZX_EST 	:= cEst
				SZX->ZX_FRETE 	:= nFrete
				SZX->ZX_DESPESA := nDespesa
				SZX->ZX_BASEICM := nBaseIcm
				SZX->ZX_VALICM 	:= nValIcm
				SZX->ZX_BASEIPI := nBaseIpi
				SZX->ZX_VALIPI 	:= nValIpi
				SZX->ZX_VALMERC := Val(nValMerc)
				SZX->ZX_VALBRUT := Val(nValBrut)
				SZX->ZX_TIPO 	:= cTipo
				SZX->ZX_BRICMS 	:= nBriCms
				SZX->ZX_ICMSRET := nZXIcmsRet
				SZX->ZX_CHVNFE 	:= cChvCTE
				SZX->ZX_ENTRADA := .F.
				SZX->ZX_OBSNF	:= cXmlObsNf
				SZX->ZX_TIPOXML	:= cTipoXml
				//SZX->ZX_XML		:= cContXml
				SZX->(MsUnLock())

			EndIf

			//====================================================================
			//REMOVENDO ARQUIVO APÓS A LEITURA E GRAVAÇÃO NAS TABELAS SZX E SZI  =
			//====================================================================
			cLocOrig := ""
			cLocDest := ""

			cLocOrig := cPatch + aFiles[i,1]
			cLocDest := cDirDest + aFiles[i,1]
			nStatusDir := fRename(cLocOrig,cLocDest)

			If nStatusDir < 0
				MsgInfo("Num erro FError(): "+cValToChar(FError()))
			EndIf
			//====================================================================

		EndIf

		oXml := Nil

	Next i

Return


//==============================================================
//BUSCA AMARRAÇÃO DO PRODUTO X FORNECEDOR NA LEITURA DO XML    =
//==============================================================
Static Function GRVAMARRCAD(cFornece,cLoja,cProd)

	Local nCodRet  	:= ""
	Local cDescRet 	:= ""
	Local aArea 	:= GetArea()
	Local cSlqSZ5
	Local cAliasSZ5 := GetNextAlias()

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	cSlqSZ5 := "SELECT * "+CRLF 
	cSlqSZ5 += "FROM "+RetSqlName("SZ5")+" SZ5 "+CRLF 
	cSlqSZ5 += "WHERE "+CRLF 
	cSlqSZ5 += "      SZ5.Z5_FORNECE = '"+cFornece+"'       AND "+CRLF 
	cSlqSZ5 += "      SZ5.Z5_LOJA    = '"+cLoja+"'          AND "+CRLF 
	cSlqSZ5 += "      SZ5.Z5_CODPRF  = '"+AllTrim(cProd)+"' AND "+CRLF 
	cSlqSZ5 += "      SZ5.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSlqSZ5),cAliasSZ5,.T.,.F.)

	(cAliasSZ5)->(DbGoTop())

	If !(cAliasSZ5)->(Eof())
		If SB1->(DbSeek(xFilial("SB1")+(cAliasSZ5)->Z5_PRODUTO))
			nCodRet		:= SB1->B1_COD
			cDescRet	:= SB1->B1_DESC
		EndIf
	EndIf

	(cAliasSZ5)->(DbCloseArea())

	RestArea(aArea)

Return {nCodRet,cDescRet}


//====================================
//BUSCA FORNECEDOR PASSANDO O CNPJ   =
//====================================
Static Function XMLFOR(cCnpj,cNomeFor)

	Local cSqlSA2
	Local cAliasSA2
	Local cFornece
	Local cLoja
	Local cNome

	cAliasSA2 := GetNextAlias()
	cSqlSA2 := "SELECT TOP 1 SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME "+CRLF 
	cSqlSA2 += "FROM "+RetSqlName("SA2")+" SA2 "+CRLF
	cSqlSA2 += "WHERE "+CRLF
	cSqlSA2 += "      SA2.A2_MSBLQL   != '1'        AND "+CRLF
	cSqlSA2 += "      SA2.A2_CGC LIKE '%"+cCnpj+"%' AND "+CRLF
	cSqlSA2 += "      SA2.D_E_L_E_T_  = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSA2),cAliasSA2,.T.,.F.)

	cFornece := AllTrim((cAliasSA2)->A2_COD)
	cLoja 	 := (cAliasSA2)->A2_LOJA
	cNome	 := AllTrim((cAliasSA2)->A2_NOME)

	(cAliasSA2)->(DbCloseArea())

	If Empty(cFornece)
		MsgInfo("Favor verificar o cadastro do fornecedor! "+CRLF+CRLF+;
		"Rasão Social: "+cNomeFor+CRLF+;
		"CNPJ: "+Transform(cCnpj,"@R 99.999.999/9999-99")+CRLF+CRLF+;
		"Acesse -> Nf.Div/Fornece <- para realizar manutenção de Fornecedores com Divergência no cadastro!","Verificar Fornecedor")
	EndIf

Return {cFornece,cLoja,cNome}


//=================================================
//VALIDAÇÃO DO TIPO DE XML - NFE OU CTE           =
//PARA CADA TIPO DE NOTA UMA CHAMADA DIFERENTE    =
//=================================================
Static Function VALNFECTE()

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	//SE FOR CTE
	//INCLUSÃO DA NOTA/PRE-NOTA - CTE
	//CHAMA PROGRAMA DE IMPORTAÇÃO DE CTE
	If AllTrim(SZX->ZX_TIPOXML) == "CTE"

		If !SZX->ZX_ENTRADA
			APJMATA116()
		EndIf

	Else //SE FOR NFE

		If SZX->ZX_ENTRADA
			Return
		EndIf

		//VALIDAÇÃO DOS PRODUTOS
		//PRODUTOS QUE JA FORAM VINDULADOS PRODUTOS X FORNECEDOR
		//DEVE PASSAR POR NOVAS VALIDAÇÕES 
		//VALIDAÇÕES: N.C.M.
		If PREVALPROD()

			//AJUSTES NA CHAMADA DO PROGRAMA DE AJUSTE DE PREÇO
			//SOMETE USUARIOS AUTORIZADOS PODEM REALIZAR AJUSTE DE PREÇO
			If cUserName $ "DARLAN/VIRGILIO/MAYCON.ADMIN"
				If MsgYesNo("Deseja realizar Ajuste de Preço dos itens relacionado neste XML?","Atenção")
					AJUSTAPRC()
				EndIf
			EndIf

			//INCLUSÃO DA NOTA/PRE-NOTA - NFE
			//VALIDAÇÃO DE CONTROLE DE GERAÇÃO DE PRE NOTA
			If MsgYesNo("Deseja gerar Pré-Nota de Entrada?","Atenção")
				APJMATA140()
			EndIf

		EndIf
	EndIf

Return


//==================================================
//INCLUSÃO DA NOTA/PRE-NOTA - CTE                  =
//==================================================
Static Function APJMATA116()

	Local aCabec        := {}
	Local aItens        := {}
	Local aLinha        := {}
	Local aRatcc        := {}
	Local nX            := 0
	Local nY            := 0
	Local nTamFilial    := 0
	Local lOk           := .T.
	Local cFilSF1       := ""
	Local cCondCte		:= "002"
	Local aRecnoSF1		:= {}
	Local cFilAux 		:= cFilAnt
	Local cNumAux 		:= cNumEmp
	Local oBtBusca
	Local oBtClose
	Local oBtOk
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local cForCte
	Local oForCte
	Local cLojaCte
	Local oLojaCte
	Local dDtEmCte
	Local oDtEmCte
	Local cNumCte
	Local oNumCte
	Local nValorCte
	Local oValorCte
	Local cSerieCte
	Local oSerieCte
	Local cChaveCte
	Local oChaveCte
	Local oFontAzul 	:= TFont():New("MS Sans Serif",,016,,.F.,,,,,.F.,.F.)
	Local Confirm		:= .F.

	Private oForOrig
	Private cForOrig 	:= Space(6)
	Private oLojOrig
	Private cLojOrig 	:= Space(2)
	Private oDtAteCte
	Private dDtAteCte 	:= Date()
	Private oDtDeCte
	Private dDtDeCte 	:= Date()
	Private oDlgCte
	Private oOkCte 		:= LoadBitmap( GetResources(), "LBOK")
	Private oNoCte 		:= LoadBitmap( GetResources(), "LBNO")
	Private oBrNfCte
	Private aBrNfCte 	:= {}
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private cDocEnt		:= Space(9)
	Private oDocEnt		
	Private cSerieEnt	:= Space(3)
	Private oSerieEnt

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	cForCte		:= SZX->ZX_FORNECE
	cLojaCte	:= SZX->ZX_LOJA
	dDtEmCte	:= SZX->ZX_EMISSAO
	cNumCte		:= SZX->ZX_DOC
	cSerieCte	:= SZX->ZX_SERIE
	nValorCte	:= SZX->ZX_VALBRUT
	cChaveCte	:= SZX->ZX_CHVNFE

	dDtDeCte	:= dDataBase - 60
	dDtAteCte	:= dDataBase

	//TELA DE SELEÇÃO DE FORNECEDOR DE ORIGEM
	//SELEÇÃO DAS NOTAS FISCAIS DE ENTRADA

	DEFINE MSDIALOG oDlgCte TITLE "Seleção de notas de Entrada" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL

	//DADOS CT-E
	@ 002, 002 GROUP oGroup2 TO 058, 356 PROMPT "Dados CT-e" OF oDlgCte COLOR 0, 16777215 PIXEL
	@ 009, 005 SAY oSay3 PROMPT "Fornecedor" SIZE 035, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 017, 005 MSGET oForCte VAR cForCte SIZE 060, 010 OF oDlgCte WHEN .F. COLORS 0, 16777215 F3 "SA2" HASBUTTON PIXEL

	@ 009, 076 SAY oSay6 PROMPT "Loja" SIZE 035, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 017, 076 MSGET oLojaCte VAR cLojaCte SIZE 030, 010 OF oDlgCte WHEN .F. COLORS 0, 16777215 HASBUTTON PIXEL

	@ 009, 205 SAY oSay7 PROMPT "Emissão CT-e" SIZE 039, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 017, 204 MSGET oDtEmCte VAR dDtEmCte SIZE 060, 010 OF oDlgCte WHEN .F. COLORS 0, 16777215 HASBUTTON PIXEL

	@ 032, 005 SAY oSay8 PROMPT "Num CT-e" SIZE 035, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 040, 005 MSGET oNumCte VAR cNumCte SIZE 101, 010 OF oDlgCte WHEN .F. COLORS 0, 16777215 HASBUTTON PIXEL

	@ 009, 288 SAY oSay9 PROMPT "Valor CT-e" SIZE 035, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 017, 288 MSGET oValorCte VAR nValorCte SIZE 060, 010 OF oDlgCte WHEN .F. PICTURE "@E 99,999,999,999.99" COLORS 0, 16777215 HASBUTTON PIXEL

	@ 032, 117 SAY oSay10 PROMPT "Serie CT-e" SIZE 032, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 040, 117 MSGET oSerieCte VAR cSerieCte SIZE 035, 010 OF oDlgCte WHEN .F. COLORS 0, 16777215 HASBUTTON PIXEL

	@ 032, 165 SAY oSay11 PROMPT "Chave CT-e" SIZE 032, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 040, 165 MSGET oChaveCte VAR cChaveCte SIZE 183, 010 OF oDlgCte COLORS 0, 16777215 HASBUTTON PIXEL
	//--

	//DADOS SOBRE NOTA FISCAL DE ENTRADA A SER BUSCADA
	@ 063, 002 GROUP oGroup1 TO 119, 356 PROMPT "Nota Fiscal de Entrada" OF oDlgCte COLOR 0, 16777215 PIXEL
	@ 070, 005 SAY oSay12 PROMPT "Doc. Entrada" SIZE 035, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 078, 005 MSGET oDocEnt VAR cDocEnt SIZE 060, 010 OF oDlgCte COLORS 0, 16777215 HASBUTTON PIXEL

	@ 070, 076 SAY oSay13 PROMPT "Serie" SIZE 035, 007 OF oDlgCte COLORS 0, 16777215 PIXEL
	@ 078, 076 MSGET oSerieEnt VAR cSerieEnt SIZE 030, 010 OF oDlgCte COLORS 0, 16777215 HASBUTTON PIXEL

	@ 078, 109 BUTTON oBtSeekNf PROMPT "..." SIZE 012, 010 OF oDlgCte ACTION SEEKNFCTE(cDocEnt,cSerieEnt) PIXEL

	@ 093, 005 SAY oSay1 PROMPT "Fornecedor" SIZE 035, 007 OF oDlgCte FONT oFontAzul COLORS 16711680, 16777215 PIXEL
	@ 101, 005 MSGET oForOrig VAR cForOrig SIZE 060, 010 OF oDlgCte COLORS 0, 16777215 F3 "SA2" HASBUTTON PIXEL

	@ 093, 076 SAY oSay2 PROMPT "Loja" SIZE 035, 007 OF oDlgCte FONT oFontAzul COLORS 16711680, 16777215 PIXEL
	@ 101, 076 MSGET oLojOrig VAR cLojOrig SIZE 030, 010 OF oDlgCte COLORS 0, 16777215 HASBUTTON PIXEL

	@ 070, 178 SAY oSay4 PROMPT "Entrada De:" SIZE 035, 007 OF oDlgCte FONT oFontAzul COLORS 16711680, 16777215 PIXEL
	@ 078, 178 MSGET oDtDeCte VAR dDtDeCte SIZE 060, 010 OF oDlgCte COLORS 0, 16777215 HASBUTTON PIXEL

	@ 070, 258 SAY oSay5 PROMPT "Entrada Até:" SIZE 035, 007 OF oDlgCte FONT oFontAzul COLORS 16711680, 16777215 PIXEL
	@ 078, 258 MSGET oDtAteCte VAR dDtAteCte SIZE 060, 010 OF oDlgCte COLORS 0, 16777215 HASBUTTON PIXEL

	oBrNfCte := TWBrowse():New(124,002,395,107,,{"","Empresa","Num Doc","Serie","Fornecedor","Loja","Valor Bruto Entrada"},;
	{},oDlgCte,,,,{|| },,,,,,,,.F.,,.T.,,.F.,,,)
	aAdd(aBrNfCte,{.F.,"","","","","",""})
	TELACTE()

	@ 066, 358 BUTTON oBtBusca PROMPT "Buscar" SIZE 037, 012 OF oDlgCte ACTION SEEKREGCTE(cForOrig,cLojOrig,dDtDeCte,dDtAteCte,cDocEnt,cSerieEnt) PIXEL

	@ 235, 317 BUTTON oBtOk PROMPT "Confirmar" SIZE 037, 012 OF oDlgCte ACTION {|| Confirm := .T., oDlgCte:End()} PIXEL
	@ 235, 359 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlgCte ACTION oDlgCte:End() PIXEL

	ACTIVATE MSDIALOG oDlgCte CENTERED

	If Confirm

		//PREENCHIMENTO DA LISTA DE NOTAS SELECIONADAS
		//ORGANIZO OS RECNO DAS NOTAS FISCAIS SELECIONAS EM UM OUTRO ARRAY POR CONTA DE ORGANIZAÇÃO
		aRecnoSF1 := {}
		For i := 1 To Len(aBrNfCte)
			If aBrNfCte[i,1]
				aAdd(aRecnoSF1, aBrNfCte[i,Len(aBrNfCte[i])])
			EndIf
		Next i

		//SE ARRAY DAS NOTAS FISCAIS ESTIVER PREENCIDO
		//ENTRA NA INCLUSÃO DE CT-E
		If !Empty(aRecnoSF1)

			DbSelectArea("SF1")
			SF1->(DbSetOrder(1))

			cFilSF1    := xFilial("SF1")
			nTamFilial := Len(cFilSF1)

			For i := 1 To Len(aRecnoSF1)

				SF1->(DbGoTo(aRecnoSF1[i]))

				aAdd(aItens, {{"PRIMARYKEY",AllTrim(SubStr(&(IndexKey()),nTamFilial + 1))}}) //Tratamento para Gestao Empresas

			Next i             

			aAdd(aCabec, {""			,dDtDeCte})       	  //Data Inicial        
			aAdd(aCabec, {""			,dDtAteCte})          //Data Final        
			aAdd(aCabec, {""			,2})                  //2-Inclusao;1=Exclusao        
			aAdd(aCabec, {""			,cForOrig})           //Fornecedor do documento de Origem          
			aAdd(aCabec, {""			,cLojOrig})           //Loja de origem        
			aAdd(aCabec, {""			,1})                  //Tipo da nota de origem: 1=Normal;2=Devol/Benef        
			aAdd(aCabec, {""			,2})                  //1=Aglutina;2=Nao aglutina        
			aAdd(aCabec, {"F1_EST"		,""})        
			aAdd(aCabec, {""			,SZX->ZX_VALBRUT})    //Valor do conhecimento        
			aAdd(aCabec, {"F1_FORMUL"	,1})        
			aAdd(aCabec, {"F1_DOC"		,SZX->ZX_DOC})     	  //..Numero da NF de Conhecimento de Frete        
			aAdd(aCabec, {"F1_SERIE"	,SZX->ZX_SERIE})        
			aAdd(aCabec, {"F1_FORNECE"	,SZX->ZX_FORNECE})        
			aAdd(aCabec, {"F1_LOJA"		,SZX->ZX_LOJA})        
			aAdd(aCabec, {""			,"300"})              //TES        
			aAdd(aCabec, {"F1_BASERET"	,0})        
			aAdd(aCabec, {"F1_ICMRET"	,0})        
			aAdd(aCabec, {"F1_COND"		,cCondCte})        
			aAdd(aCabec, {"F1_EMISSAO"	,SZX->ZX_EMISSAO})        
			aAdd(aCabec, {"F1_ESPECIE"	,"CTE  "})        
			aAdd(aCabec, {"E2_NATUREZ"	,"203002"}) 
			aAdd(aCabec, {"F1_CHVNFE"	,SZX->ZX_CHVNFE})                            

			//ALTERANDO A EMPRESA DE ACORDO COM A FILIAL DA NOTA
			cNumEmp := "01"+SZX->ZX_FILIAL
			cFilAnt := SZX->ZX_FILIAL
			DbSelectArea("SM0")
			SM0->(DbSeek(cNumEmp))

			//MATA116(xAutoCab,xAutoItens,lAutoGFE,lPreNota,aRatcc)
			MsgRun("Gerando CT-e. Aguarde... ","Geração de CT-e",{|| MATA116(aCabec,aItens,.F.,.T.)})

			//VOLTA EMPRESA
			cNumEmp := cNumAux
			cFilAnt := cFilAux
			SM0->(DbSeek(cNumEmp))

			If lMsErroAuto 
				MsgStop("Erro!")         
				MostraErro()                 
			Else           

				//ATUALIZA O STATUS DO CABEÇALHO DA NOTA FISCAL
				SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))
				RecLock("SZX", .F.)
				SZX->ZX_ENTRADA := .T.
				SZX->(MsUnLock())

				SF1->(DbSetOrder(1))
				If SF1->(DbSeek(SZX->ZX_FILIAL+SZX->ZX_DOC+SZX->ZX_SERIE+SZX->ZX_FORNECE+SZX->ZX_LOJA))
					RecLock("SF1", .F.)
					SF1->F1_CHVNFE := SZX->ZX_CHVNFE
					SF1->(MsUnLock())
				EndIf

				//ATUALIZA OS ITENS DA NOTA FISCAL DE ENTRADA/CTE -> D1_TES
				ATAUMATA116()

				MsgInfo("CT-e Incluido com sucesso!")

				//ATUALIZA GRID DO CABEÇALHO
				SEEKGETXML()
				FGETXML()
				CHANGEXML()

			Endif

		EndIf

	EndIf

Return


//============================================================
//ATAULIZA A TELA DE AMOSTRAGEM DAS NOTAS PARA EMITIR O CTE  =
//============================================================
Static Function TELACTE()

	oBrNfCte:SetArray(aBrNfCte)
	oBrNfCte:bLine := {|| {If(aBrNfCte[oBrNfCte:nAT,1],oOkCte,oNoCte),;
	aBrNfCte[oBrNfCte:nAt,2],aBrNfCte[oBrNfCte:nAt,3],aBrNfCte[oBrNfCte:nAt,4],;
	aBrNfCte[oBrNfCte:nAt,5],aBrNfCte[oBrNfCte:nAt,6],aBrNfCte[oBrNfCte:nAt,7]}}
	oBrNfCte:bLDblClick := {|| aBrNfCte[oBrNfCte:nAt,1] := !aBrNfCte[oBrNfCte:nAt,1],oBrNfCte:DrawSelect()}
	oBrNfCte:nScrollType := 1
	oBrNfCte:Refresh()

Return


//====================================================================
//BUSCA REGISTRO DO FORNECEDOR COM BASE NOS PARAMETROS INFORMADOS    =
//====================================================================
Static Function SEEKREGCTE(cForOrig,cLojOrig,dDtDeCte,dDtAteCte,cDocEnt,cSerieEnt)

	Local cSql
	Local cAliasSql	:= GetNextAlias()

	If Empty(cForOrig) .OR. Empty(cLojOrig) .OR. Empty(dDtDeCte) .OR. Empty(dDtAteCte)
		MsgStop("Existe campos à serem preenchidos!")
		Return
	EndIf

	aBrNfCte := {}

	cSql := "SELECT SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, "+CRLF 
	cSql += "SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_VALBRUT, SF1.R_E_C_N_O_ AS RECNOSF1 "+CRLF
	cSql += "FROM "+RetSqlName("SF1")+" SF1 "+CRLF
	cSql += "WHERE "+CRLF
	cSql += "	   SF1.F1_FILIAL  = '"+SZX->ZX_FILIAL+"' AND "+CRLF 
	cSql += "	   SF1.F1_FORNECE = '"+cForOrig+"' AND "+CRLF
	cSql += "	   SF1.F1_LOJA    = '"+cLojOrig+"' AND "+CRLF
	cSql += "	   SF1.F1_DTDIGIT BETWEEN "+ValToSql(dDtDeCte)+" AND "+ValToSql(dDtAteCte)+" AND "+CRLF
	If !Empty(cDocEnt) .AND. !Empty(cSerieEnt)
		cSql += "      SF1.F1_DOC   = '"+cDocEnt+"' AND "+CRLF
		cSql += "      SF1.F1_SERIE = '"+cSerieEnt+"' AND "+CRLF
	EndIf
	cSql += "	   SF1.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

	(cAliasSql)->(DbGoTop())

	If !(cAliasSql)->(Eof())
		While !(cAliasSql)->(Eof())

			aAdd(aBrNfCte, {.F.,(cAliasSql)->F1_FILIAL,(cAliasSql)->F1_DOC,(cAliasSql)->F1_SERIE,;
			(cAliasSql)->F1_FORNECE,(cAliasSql)->F1_LOJA,(cAliasSql)->F1_VALBRUT,(cAliasSql)->RECNOSF1})

			(cAliasSql)->(DbSkip())
		EndDo
	Else
		aAdd(aBrNfCte,{.F.,"","","","","",""})
	EndIf
	(cAliasSql)->(DbCloseArea())

	//ATAULIZA A TELA DE AMOSTRAGEM DAS NOTAS PARA EMITIR O CTE
	TELACTE()

Return


//================================================
//BUSCA FORNECEDOR DECORRENTE A NOTA INFORMADA   =
//================================================
Static Function SEEKNFCTE(cDocEnt,cSerieEnt)

	Local cSlq
	Local cAliasSql	:= GetNextAlias()
	Local oDlgForCte
	Local oBrNfCte
	Local aBrNfCte 	:= {}

	cDocEnt := StrZero(Val(cDocEnt),9,0)

	cSql := "SELECT SF1.F1_FORNECE, SF1.F1_LOJA, SA2.A2_NOME, SA2.A2_CGC "+CRLF
	cSql += "FROM "+RetSqlName("SF1")+" SF1 "+CRLF
	cSql += "JOIN "+RetSqlName("SA2")+" SA2 "+CRLF
	cSql += "ON "+CRLF
	cSql += "   SA2.A2_COD     = SF1.F1_FORNECE AND "+CRLF
	cSql += "   SA2.A2_LOJA    = SF1.F1_LOJA    AND "+CRLF
	cSql += "   SA2.D_E_L_E_T_ = '' "+CRLF
	cSql += "WHERE "+CRLF
	cSql += "      SF1.F1_DOC   = '"+StrZero(Val(cDocEnt),9,0)+"' AND "+CRLF
	cSql += "      SF1.F1_SERIE = '"+cSerieEnt+"' AND "+CRLF
	cSql += "	   SF1.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

	(cAliasSql)->(DbGoTop())

	If !(cAliasSql)->(Eof())
		While !(cAliasSql)->(Eof())

			aAdd(aBrNfCte, {(cAliasSql)->F1_FORNECE,(cAliasSql)->F1_LOJA,(cAliasSql)->A2_NOME,(cAliasSql)->A2_CGC})

			(cAliasSql)->(DbSkip())
		EndDo	
	Else

		MsgStop("Nenhum Forncedor encontrado!")

		(cAliasSql)->(DbCloseArea())

		cForOrig := Space(6)
		cLojOrig := Space(2)
		oForOrig:Refresh()
		oLojOrig:Refresh()

		Return
	EndIf
	(cAliasSql)->(DbCloseArea())

	//SE TIVER UNICO REGISTRO, NÃO TEM NECESSIDADE DE EXIBIR A TELA
	/*
	If Len(aBrNfCte) == 1

	cForOrig := aBrNfCte[1,1]
	cLojOrig := aBrNfCte[1,2]
	oForOrig:Refresh()
	oLojOrig:Refresh()

	Return
	EndIf
	*/

	DEFINE MSDIALOG oDlgForCte TITLE "Fornecedor" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

	oBrNfCte := TWBrowse():New(002,002,246,144,,{"Fornecedor","Loja","Razão Social","CNJ/CPF"},{},oDlgForCte,,,,{|| },,,,,,,,.F.,,.T.,,.F.,,,)
	oBrNfCte:SetArray(aBrNfCte)
	oBrNfCte:bLine := {|| {aBrNfCte[oBrNfCte:nAt,1],aBrNfCte[oBrNfCte:nAt,2],aBrNfCte[oBrNfCte:nAt,3],aBrNfCte[oBrNfCte:nAt,4]}}
	oBrNfCte:bLDblClick := {|| cForOrig := aBrNfCte[oBrNfCte:nAt,1], cLojOrig := aBrNfCte[oBrNfCte:nAt,2],;
	oForOrig:Refresh(), oLojOrig:Refresh(), oDlgForCte:End()}
	oBrNfCte:nScrollType := 1

	ACTIVATE MSDIALOG oDlgForCte CENTERED

Return


//==================================================
//INCLUSÃO DA NOTA/PRE-NOTA - NFE                  =
//==================================================
Static Function APJMATA140()

	Local nOpc 			:= 3
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
	Local cSqlPnf
	Local cAliasPnf
	Local cFilAux 		:= cFilAnt
	Local cNumAux 		:= cNumEmp
	Local cTes
	Local aNotProd 		:= {}
	Local oNotProd
	Local oSayNot
	Local cNumPed		
	Local oBtClose
	Local nX
	Local aCabecPed 	:= {}
	Local aItensPed 	:= {}
	Local aLinhaPed 	:= {}
	Local cAliasSD1
	Local cSqlSD1

	Local aItensXML 	:= {}
	Local aItensPED 	:= {}
	Local aItensPRE 	:= {}
	Local oBtCancel
	Local oBtCorrigi
	Local oFont1 		:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
	Local oSay1
	Local oDlgDiv
	Local oItensDiv
	Local aItensDiv 	:= {}
	Local nAtuaDesc		:= 0

	Private oSayCond1      
	Private oCondPag     
	Private oSayCond2 
	Private oDescCond
	Private oDlgCond                  
	Private cDescCond
	Private lMsErroAuto := .F.
	Private lWhile 		:= .T.

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	cNumPed := SZX->ZX_NUMPED

	//======================================================
	//GERAÇÃO DA PRE-NOTA COM PEDIDO DE VENDA VINCULADO    =
	//PEGAR ITENS DO SZI VINCULADO AO PEDIDO               =
	//======================================================
	If !Empty(cNumPed)	

		If SZX->ZX_VALDESC > 0	
			nAtuaDesc := Aviso("Continuar Geração Pré-Nota","Documento Possui DESCONTO, Deseja Atualizar o Pedido de Compra para que o Desconto seja Validado?",{"Sim","Não","Abortar"},3) 
		EndIf

		If nAtuaDesc == 3
			Return
		EndIf

		cAliasPnf := GetNextAlias()
		cSqlPnf := "SELECT * FROM "+RetSqlname("SZI")+" SZI "+CRLF
		cSqlPnf += "WHERE "+CRLF
		cSqlPnf += "	  SZI.ZI_FILIAL  = '"+SZX->ZX_FILIAL+"'  AND "+CRLF
		cSqlPnf += "      SZI.ZI_DOC     = '"+SZX->ZX_DOC+"'     AND "+CRLF
		cSqlPnf += "      SZI.ZI_SERIE   = '"+SZX->ZX_SERIE+"'   AND "+CRLF
		cSqlPnf += "      SZI.ZI_FORNECE = '"+SZX->ZX_FORNECE+"' AND "+CRLF
		cSqlPnf += "      SZI.ZI_LOJA    = '"+SZX->ZX_LOJA+"'    AND "+CRLF
		cSqlPnf += "      SZI.ZI_NUMPED  != ''                   AND "+CRLF
		cSqlPnf += "	  SZI.D_E_L_E_T_ = '' "+CRLF
		cSqlPnf += "ORDER BY SZI.ZI_SEQUEN"	
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlPnf),cAliasPnf,.T.,.F.)

		While !(cAliasPnf)->(Eof())

			If Empty((cAliasPnf)->ZI_RECNOC7)
				MsgStop("Existe linha com Recno SC7 sem preencher. Favor reavalizar!")
				(cAliasPnf)->(DbCloseArea())
				Return
			EndIf

			(cAliasPnf)->(DbSkip())
		EndDo

		(cAliasPnf)->(DbGoTop())

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))

		While !(cAliasPnf)->(Eof())

			nRecnoSC7 := Val(AllTrim((cAliasPnf)->ZI_RECNOC7))

			SC7->(DbGoTo(nRecnoSC7))

			cCondPag := SC7->C7_COND

			SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))

			//ATUALIZA O CODBAR DO PRODUTO
			If !Empty((cAliasPnf)->ZI_CODBAR)
				RecLock("SB1", .F.)
				SB1->B1_CODBAR := (cAliasPnf)->ZI_CODBAR
				SB1->(MsUnLock())
			EndIf

			//ATUALIZA A ORIGEM DO PRODUTO - SB1/SBZ
			If !Empty((cAliasPnf)->ZI_ORIG)

				DbSelectArea("SX5")
				SX5->(DbSetOrder(1))
				If SX5->(DbSeek(xFilial("SX5")+"S0"+(cAliasPnf)->ZI_ORIG+Space(5)))

					RecLock("SB1", .F.)
					SB1->B1_ORIGEM := (cAliasPnf)->ZI_ORIG
					SB1->(MsUnLock())

					//ATUALIZA SBZ
					ATUASBZ()

				Else
					MsgStop("Origem do Produto Informado no XML não consta com os Cadastrado no Sistema. Favor Rever o XML.")
					Return
				EndIf

			EndIf

			aItens := {}

			//ATUALIZA O DESCONTO QUE FOI DADO NO XML
			If nAtuaDesc == 1
				RecLock("SC7", .F.)
				SC7->C7_VLDESC := (cAliasPnf)->ZI_VALDESC
				SC7->(MsUnLock())
			EndIf

			aItens := {;
			{"D1_ITEM"	 ,StrZero(Val((cAliasPnf)->ZI_SEQUEN),4,0)	,Nil},;
			{"D1_COD"	 ,SB1->B1_COD								,Nil},;
			{"D1_UM"	 ,SC7->C7_UM								,Nil},;
			{"D1_QUANT"	 ,(cAliasPnf)->ZI_QTD						,Nil},;
			{"D1_VUNIT"	 ,(cAliasPnf)->ZI_VUNIT						,Nil},; 
			{"D1_VALDESC",SC7->C7_VLDESC							,Nil},;
			{"D1_TOTAL"	 ,(cAliasPnf)->ZI_TOTAL						,Nil},;
			{"D1_IPI"    ,SC7->C7_IPI								,Nil},;
			{"D1_PICM"   ,SC7->C7_PICM								,Nil},;
			{"D1_TES"    ,SC7->C7_TES								,Nil},;
			{"D1_PEDIDO" ,SC7->C7_NUM								,Nil},;
			{"D1_ITEMPC" ,SC7->C7_ITEM								,Nil},;
			{"D1_EMISSAO",SZX->ZX_EMISSAO							,Nil},;
			{"D1_DTDIGIT",dDataBase									,Nil},;
			{"D1_DTVALID",dDataBase									,Nil},;
			{"D1_GRUPO"  ,SB1->B1_GRUPO								,Nil},;
			{"D1_LOCAL"	 ,SC7->C7_LOCAL								,Nil},;
			{"D1_TIPO"   ,"N"										,Nil},;
			{"D1_TP"     ,"ME"										,Nil},;
			{"D1_YCFISOR",(cAliasPnf)->ZI_CLASFIS					,Nil};
			}

			aAdd(aLinha,aItens)

			(cAliasPnf)->(DbSkip())
		EndDo
		(cAliasPnf)->(DbCloseArea())

	Else	

		//CONFIRMAÇÃO DA CONTINUAÇÃO
		If !MsgYesNo(cUserName+" você esta incluindo uma Pré Nota de Entrada sem vinculação de Pedido de Compra. Deseja realmente continuar?")
			Return
		EndIf

		//=======================================================
		//GERAÇÃO DA PRE-NOTA SEM PEDIDO DE COMPRA VINCULADO	=
		//=======================================================
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))//xFilial("SB1")+B1_COD

		cAliasPnf := GetNextAlias()
		cSqlPnf := "SELECT * FROM "+RetSqlname("SZI")+" SZI "+CRLF
		cSqlPnf += "WHERE "+CRLF
		cSqlPnf += "	  SZI.ZI_FILIAL  = '"+SZX->ZX_FILIAL+"'  AND "+CRLF
		cSqlPnf += "	  SZI.ZI_DOC     = '"+SZX->ZX_DOC+"'     AND "+CRLF
		cSqlPnf += "	  SZI.ZI_SERIE   = '"+SZX->ZX_SERIE+"'   AND "+CRLF 
		cSqlPnf += "	  SZI.ZI_FORNECE = '"+SZX->ZX_FORNECE+"' AND "+CRLF
		cSqlPnf += "	  SZI.D_E_L_E_T_ = '' "+CRLF
		cSqlPnf += "ORDER BY SZI.ZI_SEQUEN"	
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlPnf),cAliasPnf,.T.,.F.)

		//VERIFICAÇÃO DA AMARRAÇÃO DO PRODUTO
		(cAliasPnf)->(DbGoTop())
		While !(cAliasPnf)->(Eof())
			If Empty((cAliasPnf)->ZI_B1COD)
				MsgStop("Existe produto sem amarração -> Produto vs Fornecedor. Favor realizar devida amarração.",'ALERTA')
				Return
			EndIf
			(cAliasPnf)->(DbSkip())
		EndDo

		(cAliasPnf)->(DbGoTop())
		While !(cAliasPnf)->(Eof())

			SB1->(DbSeek(xFilial("SB1")+(cAliasPnf)->ZI_B1COD))

			//ATUALIZA O CODBAR DO PRODUTO
			If !Empty((cAliasPnf)->ZI_CODBAR)
				RecLock("SB1", .F.)
				SB1->B1_CODBAR := (cAliasPnf)->ZI_CODBAR
				SB1->(MsUnLock())
			EndIf

			//ATUALIZA A ORIGEM DO PRODUTO - SB1/SBZ
			If !Empty((cAliasPnf)->ZI_ORIG)

				DbSelectArea("SX5")
				SX5->(DbSetOrder(1))
				If SX5->(DbSeek(xFilial("SX5")+"S0"+(cAliasPnf)->ZI_ORIG+Space(5)))

					RecLock("SB1", .F.)
					SB1->B1_ORIGEM := (cAliasPnf)->ZI_ORIG
					SB1->(MsUnLock())

					//ATUALIZA SBZ
					ATUASBZ()

				Else
					MsgStop("Origem do Produto Informado no XML não consta com os Cadastrado no Sistema. Favor Rever o XML.")
					Return
				EndIf

			EndIf

			aItens := {;
			{"D1_ITEM"	 ,StrZero(Val((cAliasPnf)->ZI_SEQUEN),4,0)	,Nil},;
			{"D1_COD"	 ,SB1->B1_COD								,Nil},;
			{"D1_UM"	 ,SB1->B1_UM             					,Nil},;
			{"D1_QUANT"	 ,(cAliasPnf)->ZI_QTD    					,Nil},;
			{"D1_VUNIT"	 ,(cAliasPnf)->ZI_VUNIT  					,Nil},;
			{"D1_VALDESC",(cAliasPnf)->ZI_VALDESC					,Nil},;
			{"D1_TOTAL"	 ,(cAliasPnf)->ZI_TOTAL  					,Nil},;
			{"D1_EMISSAO",SZX->ZX_EMISSAO		 			    	,Nil},;
			{"D1_DTDIGIT",dDataBase				 					,Nil},;
			{"D1_DTVALID",dDataBase				 					,Nil},;
			{"D1_GRUPO"  ,SB1->B1_GRUPO			 					,Nil},;
			{"D1_LOCAL"	 ,SB1->B1_LOCPAD         					,Nil},;
			{"D1_TIPO"   ,"N"					 					,Nil},;
			{"D1_TP"     ,"ME"					 					,Nil},;
			{"D1_YCFISOR",(cAliasPnf)->ZI_CLASFIS					,Nil};
			}
			//
			aAdd(aLinha,aItens)
			aItens := {}
			//
			(cAliasPnf)->(DbSkip())
			//
		EndDo
		(cAliasPnf)->(DbCloseArea())
		//
	EndIf

	//MONTAGEM DO CABEÇALHO DA NOTA FISCAL DE ENTRADA
	aCabec := {;
	{"F1_DOC"		,SZX->ZX_DOC		  	,Nil},;
	{"F1_SERIE"		,SZX->ZX_SERIE		  	,Nil},;
	{"F1_TIPO"		,"N"				  	,Nil},;
	{"F1_ESPECIE"	,"SPED"			      	,Nil},;
	{"F1_FORNECE"	,SZX->ZX_FORNECE		,Nil},;
	{"F1_LOJA"		,SZX->ZX_LOJA		  	,Nil},;
	{"F1_EMISSAO"	,SZX->ZX_EMISSAO        ,Nil},;
	{"F1_DTDIGIT"   ,dDataBase            	,Nil},;
	{"F1_RECBMTO"	,dDataBase 			  	,Nil},;
	{"F1_EST"		,SZX->ZX_EST		  	,Nil},;
	{"F1_COND"		,cCondPag		      	,Nil},;
	{"F1_FRETE"		,SZX->ZX_FRETE		  	,Nil},;
	{"F1_DESPESA"	,SZX->ZX_DESPESA		,Nil},;
	{"F1_DESCONT"	,SZX->ZX_VALDESC		,Nil},;
	{"F1_CHVNFE"	,SZX->ZX_CHVNFE		  	,Nil};
	}

	//ALTERANDO A EMPRESA DE ACORDO COM A FILIAL DA NOTA
	cNumEmp := "01"+SZX->ZX_FILIAL
	cFilAnt := SZX->ZX_FILIAL
	DbSelectArea("SM0")
	SM0->(DbSeek(cNumEmp))

	lMsErroAuto := .F.
	//CHAMADA DO EXECAUTO MATA140 - PRE-NOTA
	MsgRun("Gerando Pré-Nota. Aguarde... ","Geração de Pré-Nota",{|| MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aLinha,nOpc)})

	//VOLTA EMPRESA

	cFilAnt := cFilAux
	SM0->(DbSeek(cNumEmp))

	If lMsErroAuto
		MostraErro()
	Else

		//ATUALIZA O STATUS DO CABEÇALHO DA NOTA FISCAL
		SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))
		RecLock("SZX", .F.)
		SZX->ZX_ENTRADA := .T.
		SZX->(MsUnLock())

		//========================================
		//MANUTENÇÃO NO DOCUMENTO DE ENTRADA     =
		//PREENCHENDO CAMPOS CUSTOMIZADOS        =
		//========================================		
		cAliasSD1 := GetNextAlias()
		cSqlSD1 := "SELECT SD1.R_E_C_N_O_ AS RECNOSD1 "+CRLF
		cSqlSD1 += "FROM "+RetSqlName("SD1")+" SD1 "+CRLF
		cSqlSD1 += "WHERE "+CRLF
		cSqlSD1 += "      SD1.D1_FILIAL  = '"+SF1->F1_FILIAL+"'  AND "+CRLF
		cSqlSD1 += "      SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND "+CRLF
		cSqlSD1 += "      SD1.D1_LOJA    = '"+SF1->F1_LOJA+"'    AND "+CRLF
		cSqlSD1 += "	  SD1.D1_DOC     = '"+SF1->F1_DOC+"'     AND "+CRLF
		cSqlSD1 += "	  SD1.D1_SERIE   = '"+SF1->F1_SERIE+"'   AND "+CRLF
		cSqlSD1 += "	  SD1.D_E_L_E_T_ = ''"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSD1),cAliasSD1,.T.,.F.)

		(cAliasSD1)->(DbGoTop())

		aAreaAnt := GetArea()
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))

		While !(cAliasSD1)->(Eof())

			SD1->(DbGoTo((cAliasSD1)->RECNOSD1))

			lMono := u_PRODREAL(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI")) //CONSULTA O TIPO DE TRIBUTAÇÃO DO PRODUTO

			RecLock("SD1", .F.)
			SD1->D1_YPOSIPI := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI")
			SD1->D1_YCREPF  := IIF(lMono,"MONOFASICO","TRIBUTADO")
			SD1->D1_YCEST	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_CEST")
			SD1->D1_YORIGEM	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_ORIGEM")
			SD1->D1_YCLAFIS	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_CLASFIS")
			SD1->(MsUnLock())

			(cAliasSD1)->(DbSkip())
		EndDo
		(cAliasSD1)->(DbCloseArea())
		RestArea(aAreaAnt)
		//========================================

		MsgInfo("Pré-Nota gerada com sucesso!","Pré-Nota Gerada")

		//ATUALIZA GRID DO CABEÇALHO
		SEEKGETXML()
		FGETXML()
		CHANGEXML()

		//ENVIA E-MAIL PARA FISCAL
		//MsgRun("Enviando e-mail de confimação para fiscal...","Geração de Pré-Nota",{|| ENVMAIL(SF1->F1_DOC)})

	EndIf

Return


//===========================================
//RETORNA POSIÇÃO DO CAMPO DENTRO DO ARRAY  =
//===========================================
Static Function POSCPO(cCpo,aCpos)

	Local nPos
	Local i

	For i := 1 To Len(aCpos)
		If AllTrim(cCpo) == AllTrim(aCpos[i])
			nPos := i
			Exit
		EndIf
	Next i

Return nPos


//=======================================================
//SELECÃO CONDIÇÃO DE PAGAMENTO VALIDAÇÃO DOS CAMPOS    =
//=======================================================
Static Function XMLCONDPG(cCondPag)

	Local lRet := .T.

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+cCondPag))
		cCondPag  := SE4->E4_CODIGO
		cDescCond := SE4->E4_DESCRI
	Else
		MsgStop("Condição de pagamento inexistente!")		
		cCondPag  := ""
		cDescCond := ""        
		oCondPag:CtrlRefresh() 
		oDescCond:CtrlRefresh()
		lRet      := .F.
	EndIf

Return lRet


//======================================================
//BUSCA PEDIDO DE COMPRA VINCULADO AO XML              =
//PASSANDO O COD DO FORNECEDOR PARA BUSCAR PED COMPRA  =
//======================================================
Static Function XML02F4()

	Local oBtClose
	Local oBtOk
	Local oFornece
	Local cFornece 	
	Local oGroup1
	Local oProduto
	Local cProduto 	
	Local oSay1
	Local oSay2
	Local cAliasSC7
	Local cSqlSC7
	Local oOk 			:= LoadBitmap(GetResources(), "LBOK")
	Local oNo 			:= LoadBitmap(GetResources(), "LBNO")
	Local aItemX		:= {}
	Local lDiv 			:= .F.
	Local nX1 
	Local cNotIn		:= ""
	Local aNotIn		:= {}

	Private aItemXml 	:= {}
	Private oItemXml
	Private oItensPed
	Private aItensPed 	:= {}
	Private oDlg_PED

	DbSelectArea("SZX")
	SZX->(DbSetOrder(1))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	/*
	For nX1 := 1 To Len(oGetItem:ACOLS)
	If !Empty(oGetItem:ACOLS[nX1,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])
	If ValType(oGetItem:ACOLS[nX1,FG_POSVAR("ZI_RECNOC7","aHeaderEx")]) == "N"
	aAdd(aNotIn, {cValToChar(oGetItem:ACOLS[nX1,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])})
	Else
	aAdd(aNotIn, {AllTrim(oGetItem:ACOLS[nX1,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])})
	EndIf
	EndIf
	Next nX1

	For nX1 := 1 To Len(aNotIn)
	cNotIn += "'"+aNotIn[nX1,1]+"'"
	If nX1+1 <= Len(aNotIn)
	cNotIn += ','
	EndIf
	Next nX1
	*/

	cFornece := AllTrim(SZX->ZX_FORNECE)+"-"+AllTrim(SZX->ZX_LOJA)+"-"+SZX->ZX_NOMEFOR

	SB1->(DbSeek(xFilial("SB1")+oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]))
	cProduto := AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_CODITE)+"-"+SB1->B1_DESC

	//"Produto XML","Quantidade XML","Preço XML","Total XML"
	aAdd(aItemXml, {oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")],;
	oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_QTD","aHeaderEx")],;
	oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_VUNIT","aHeaderEx")],;
	oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_TOTAL","aHeaderEx")],;
	oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]})

	cAliasSC7 := GetNextAlias()
	cSqlSC7 := "SELECT SC7.C7_PRODUTO,(SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA) AS C7_QUANT, SC7.C7_PRECO, "+CRLF
	cSqlSC7 += "SC7.C7_TOTAL, SC7.C7_NUM, SC7.R_E_C_N_O_ AS RECNOSC7 "+CRLF
	cSqlSC7 += "FROM "+RetSqlName("SC7")+" SC7 "+CRLF
	cSqlSC7 += "WHERE "+CRLF
	cSqlSC7 += "      SC7.C7_FILIAL  =  '"+SZX->ZX_FILIAL+"'  AND "+CRLF
	cSqlSC7 += "      SC7.C7_FORNECE =  '"+SZX->ZX_FORNECE+"' AND "+CRLF
	cSqlSC7 += "      SC7.C7_LOJA    =  '"+SZX->ZX_LOJA+"'    AND "+CRLF
	cSqlSC7 += "      SC7.C7_PRODUTO =  '"+SB1->B1_COD+"'     AND "+CRLF
	cSqlSC7 += "      SC7.C7_RESIDUO != 'S'                   AND "+CRLF
	cSqlSC7 += "      (SC7.C7_QUANT-SC7.C7_QUJE-C7_QTDACLA) >= '"+cValToChar(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_QTD","aHeaderEx")])+"' AND "+CRLF
	//cSqlSC7 += "      SC7.C7_QTDACLA = '0'                   AND "+CRLF
	If !Empty(cNotIn)
		cSqlSC7 += "      SC7.R_E_C_N_O_ NOT IN ("+cNotIn+") AND "+CRLF
	EndIf
	cSqlSC7 += "      SC7.D_E_L_E_T_ = ''" 
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSC7),cAliasSC7,.T.,.F.)

	(cAliasSC7)->(DbGoTop())

	If !(cAliasSC7)->(Eof())
		While !(cAliasSC7)->(Eof())

			aAdd(aItensPed, {.F.,(cAliasSC7)->C7_PRODUTO,(cAliasSC7)->C7_QUANT,(cAliasSC7)->C7_PRECO,;
			(cAliasSC7)->C7_TOTAL,(cAliasSC7)->C7_NUM,(cAliasSC7)->RECNOSC7})

			(cAliasSC7)->(DbSkip())
		EndDo
	Else

		If !Empty(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])
			If MsgYesNo("Vinculação Item do Ped. Compra ja Realizada, Deseja Dessamarrar Item do Ped. Compra?")
				DEITEMPED()
			EndIf
		Else
			MsgStop("Nenhum Pedido de Compra relacionado para este Fornecedor x Produto ou"+CRLF+;
					"Verifique a Quantidade presente na Nota x Pedido!")
		EndIf

		(cAliasSC7)->(DbCloseArea())
		Return
	EndIf
	(cAliasSC7)->(DbCloseArea())

	DEFINE MSDIALOG oDlg_PED TITLE "Produtos  x  Pedido de Compra" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL

	@ 001, 002 GROUP oGroup1 TO 058, 397 OF oDlg_PED COLOR 0, 16777215 PIXEL

	@ 007, 005 SAY oSay1 PROMPT "Fornecedor" SIZE 031, 007 OF oDlg_PED COLORS 0, 16777215 PIXEL
	@ 015, 005 MSGET oFornece VAR cFornece SIZE 351, 010 OF oDlg_PED WHEN .F. COLORS 0, 16777215 PIXEL

	@ 034, 005 SAY oSay2 PROMPT "Produto" SIZE 031, 007 OF oDlg_PED COLORS 0, 16777215 PIXEL
	@ 042, 005 MSGET oProduto VAR cProduto SIZE 351, 010 OF oDlg_PED WHEN .F. COLORS 0, 16777215 PIXEL

	//ITEM DO XML
	oItemXml := TWBrowse():New(065,002,395,038,,{"Produto XML","Quantidade XML","Preço XML","Total XML","Num Ped XML"},;
	{50,50,50,50,50},oDlg_PED,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oItemXml:SetArray(aItemXml)
	oItemXml:bLine := {|| {aItemXml[oItemXml:nAt,1],aItemXml[oItemXml:nAt,2],aItemXml[oItemXml:nAt,3],aItemXml[oItemXml:nAt,4],aItemXml[oItemXml:nAt,5]}}
	oItemXml:bLDblClick := {|| }
	oItemXml:nScrollType := 1

	//ITENS DO PEDIDO DE COMPRA
	oItensPed := TWBrowse():New(109,002,395,122,,{"","Produto SC7","Quantidade SC7","Preço SC7","Total SC7","Num Ped SC7"},;
	{5,50,50,50,50,50},oDlg_PED,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oItensPed:SetArray(aItensPed)
	oItensPed:bLine := {|| {If(aItensPed[oItensPed:nAT,1],oOk,oNo),aItensPed[oItensPed:nAt,2],aItensPed[oItensPed:nAt,3],;
	aItensPed[oItensPed:nAt,4],aItensPed[oItensPed:nAt,5],aItensPed[oItensPed:nAt,6]}}
	oItensPed:bLDblClick := {|| aItensPed[oItensPed:nAt,1] := !aItensPed[oItensPed:nAt,1],;
	oItensPed:DrawSelect(),;
	aItemX := aItensPed[oItensPed:nAt],;
	oDlg_PED:End()}
	oItensPed:nScrollType := 1

	@ 234, 002 BUTTON oBtAcerta PROMPT "Acertar Pedido de Compra" SIZE 072, 012 OF oDlg_PED ACTION ACITEMPED(aItemXml[oItemXml:nAt],aItensPed[oItensPed:nAt]) PIXEL
	@ 234, 080 BUTTON oBtDesf PROMPT "Desamarra Item Ped x XML" SIZE 072, 012 OF oDlg_PED ACTION DEITEMPED(aItemXml[oItemXml:nAt],aItensPed[oItensPed:nAt]) PIXEL
	//@ 234, 316 BUTTON oBtOk PROMPT "Confirmar" SIZE 037, 012 OF oDlg_PED PIXEL
	@ 234, 359 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlg_PED ACTION oDlg_PED:End() PIXEL

	ACTIVATE MSDIALOG oDlg_PED CENTERED

	If !Empty(aItemX)

		If !aItemX[3] >= oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_QTD","aHeaderEx")]
			MsgStop("Divergência na Quantidade do Produto no Pedido de Compra.")
			lDiv := .T.
		EndIf
		If !aItemX[4] == oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_VUNIT","aHeaderEx")]
			MsgStop("Divergência no Valor Unitário do Produto no Pedido de Compra.")
			lDiv := .T.
		EndIf
		/*
		If !aItemX[5] == oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_TOTAL","aHeaderEx")]
		MsgStop("Divergência no Valor Total do Produto no Pedido de Compra.")
		lDiv := .T.
		EndIf
		*/

		//NENHUMA DIVERGENCIA, ATUALIZA SZI COM NUM DO PED E COM RECNO SC7
		If !lDiv

			If MsgYesNo("Deseja continuar com amarração do Pedido de Compra com Item do XML?","Atenção")

				//For i := 1 To Len(oGetItem:ACOLS)
				//	If oGetItem:nAt != i
				//		If AllTrim(cValTochar(oGetItem:ACOLS[i,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])) == AllTrim(cValToChar(aItemX[7]))
				//			MsgStop("Este Item do Pedido de Compra já esta amarrado ao Item do XML!")
				//			Return
				//		EndIf
				//	EndIf
				//Next i

				oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]  := aItemX[6]
				oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_RECNOC7","aHeaderEx")] := aItemX[7]
				oGetItem:oBrowse:Refresh()

				oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG1","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]),oCLEG2,oCLEG1)
				oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG2","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]),oCLEG2,oCLEG1)
				oGetItem:oBrowse:Refresh()

				DbSelectArea("SZI")
				SZI->(DbGoTo(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("R_E_C_N_O_","aHeaderEx")]))
				RecLock("SZI", .F.)	
				SZI->ZI_NUMPED  := oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]
				SZI->ZI_RECNOC7 := cValTochar(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])
				SZI->(MsUnLock())

				DbSelectArea("SZX")
				SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))
				RecLock("SZX", .F.)
				SZX->ZX_NUMPED := "XXXXXX"
				SZX->(MsUnLock())

			EndIf

		EndIf

	EndIf


Return


//========================================================
//MONTA E VALIDA PRODUTO DO XML COM PRODUTOS DO PEDIDO   =
//REALIZANDO CONSULTA NA SZ5(PRODUTO VS FORNECEDOR)      =
//========================================================
Static Function XMLxPED(nNumPed)

	Local cAliasPED
	Local cSqlPED
	Local cAliasSZI
	Local cSqlSZI
	Local aItensPED
	Local aItensSZI
	Local lCont 	:= .T.

	Private lDiverj

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	cAliasSZI := GetNextAlias()
	cSqlSZI := "SELECT * "+CRLF
	cSqlSZI += "FROM "+RetSqlName("SZI")+" SZI "+CRLF
	cSqlSZI += "WHERE "+CRLF
	cSqlSZI += "      SZI.ZI_FILIAL  = '"+SZX->ZX_FILIAL+"'  AND "+CRLF
	cSqlSZI += "      SZI.ZI_DOC     = '"+SZX->ZX_DOC+"'     AND "+CRLF
	cSqlSZI += "      SZI.ZI_SERIE   = '"+SZX->ZX_SERIE+"'   AND "+CRLF
	cSqlSZI += "      SZI.ZI_FORNECE = '"+SZX->ZX_FORNECE+"' AND "+CRLF
	cSqlSZI += "      SZI.ZI_LOJA    = '"+SZX->ZX_LOJA+"'    AND "+CRLF
	cSqlSZI += "      SZI.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZI),cAliasSZI,.T.,.F.)

	(cAliasSZI)->(DbGoTop())

	While !(cAliasSZI)->(Eof())
		If Empty((cAliasSZI)->ZI_B1COD)
			MsgStop("Existe produtos sem amarração Produto x Forncedor: "+CRLF+;
			"Produto XML: "+(cAliasSZI)->ZI_CODPROD+CRLF+;
			"Cod Interno: ???")
			(cAliasSZI)->(DbCloseArea())
			Return
		EndIf 
		(cAliasSZI)->(DbSkip())
	EndDo

	(cAliasSZI)->(DbGoTop())

	DbSelectArea("SZI")

	While !(cAliasSZI)->(Eof())

		SZI->(DbGoTo((cAliasSZI)->R_E_C_N_O_))

		RecLock("SZI", .F.)
		SZI->ZI_NUMPED := nNumPed
		SZI->(MsUnLock())

		(cAliasSZI)->(DbSkip())
	EndDo

	(cAliasSZI)->(DbCloseArea())

	RecLock("SZX", .F.)
	SZX->ZX_NUMPED := nNumPed
	SZX->(MsUnLock())

	//ATUALIZAÇÃO DO GRID oGetItem (FILIAL,DOC,SERIE,FORNECEDOR,LOJA,NUMPED)
	PED01F5(oGet_XML:ACOLS[oGet_XML:nAt][1],oGet_XML:ACOLS[oGet_XML:nAt][2],oGet_XML:ACOLS[oGet_XML:nAt][3],;
	oGet_XML:ACOLS[oGet_XML:nAt][5],oGet_XML:ACOLS[oGet_XML:nAt][7],nNumPed)

Return


//===============================
//FUNÇÃO DE VALIDAÇÃO DE CAMPO  =
//===============================
User Function XML02CPO()

	Local lRet 		:= .T.
	Local aAreaVar	:= GetArea()
	Local cB1_COD
	Local cFornece
	Local cLoja
	Local cCodPrf
	Local cNomeFor
	Local aItensSZ5 := {}
	Local nRecnoSZI
	Local lTravaReg

	//CHAMADA DO CAMPO ZI_B1COD
	If ReadVar() == "M->ZI_B1COD"	

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		DbSelectArea("SZ5")                                                                                                                          
		SZ5->(DbSetOrder(2))//FILIAL+FORNECEDOR+LOJA+CODPRODFOR

		cB1_COD := StrZero(Val(M->ZI_B1COD),6,0)

		If !SB1->(DbSeek(xFilial("SB1")+cB1_COD))

			//BUSCA SECUNDARIO PELO COD DO ITEM = B1_CODITE
			cB1_COD := B1CODF3(M->ZI_B1COD)

			If cB1_COD == "Erro" .OR. Empty(cB1_COD)
				Return .F.
			EndIf
		EndIf

		If SB1->(DbSeek(xFilial("SB1")+cB1_COD))

			cFornece  := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_FORNECE","aHeaderEx")]
			cLoja	  := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_LOJA"   ,"aHeaderEx")]
			cNomeFor  := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_NOMEFOR","aHeaderEx")]
			cCodPrf   := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_CODPROD","aHeaderEx")]
			nRecnoSZI := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("R_E_C_N_O_","aHeaderEx")]

			cAliasSZ5 := GetNextAlias()
			cSqlSZ5 := "SELECT SZ5.R_E_C_N_O_ AS RECNOSZ5, * "+CRLF
			cSqlSZ5 += "FROM "+RetSqlName("SZ5")+" SZ5 "+CRLF
			cSqlSZ5 += "WHERE "+CRLF
			cSqlSZ5 += "	  SZ5.Z5_FORNECE = '"+cFornece+"' AND "+CRLF
			cSqlSZ5 += "	  SZ5.Z5_LOJA    = '"+cLoja+"'    AND "+CRLF
			cSqlSZ5 += "	  SZ5.Z5_CODPRF  = '"+cCodPrf+"'  AND "+CRLF
			cSqlSZ5 += "	  SZ5.D_E_L_E_T_ = ''"
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZ5),cAliasSZ5,.T.,.F.)

			(cAliasSZ5)->(DbGoTop())
			While !(cAliasSZ5)->(Eof())

				aAdd(aItensSZ5, {(cAliasSZ5)->Z5_FORNECE,(cAliasSZ5)->Z5_LOJA,;
				(cAliasSZ5)->Z5_CODPRF,(cAliasSZ5)->Z5_PRODUTO})

				(cAliasSZ5)->(DbSkip())
			EndDo

			If Len(aItensSZ5) > 1
				MsgStop("Existe mais de uma amarração para este Fornecedor/Loja e Produto!")
				Return .F.
			EndIf

			(cAliasSZ5)->(DbGoTop())
			If !(cAliasSZ5)->(Eof())

				SZ5->(DbGoTo((cAliasSZ5)->RECNOSZ5))

				If AllTrim(SZ5->Z5_CODPRF) == AllTrim(cCodPrf) .AND. AllTrim(SZ5->Z5_PRODUTO) == AllTrim(SB1->B1_COD)

					M->ZI_B1COD := SZ5->Z5_PRODUTO
					oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] := M->ZI_B1COD
					M->ZI_SDESC := SZ5->Z5_NOMPROD
					oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")] := M->ZI_SDESC
					oGetItem:oBrowse:Refresh()

					SZI->(DbGoTo(nRecnoSZI))
					RecLock("SZI", .F.)
					SZI->ZI_B1COD := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]
					SZI->ZI_SDESC := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")]
					SZI->(MsUnLock())

					//Return .T.

				Else
					If MsgYesNo("Produto: "+cValToChar(cCodPrf)+" Já possui amarração para este Fornecedor/Loja."+CRLF+;
					"Deseja substituir amarração atual?","Atenção")

						lTravaReg := SEEKREGSZ5(cFornece,cLoja,SB1->B1_COD,cCodPrf)
						If lTravaReg
							MsgStop("Controle de gravação de registro unico na amarração de Produto x Fornecedor. Desfaça a amarração entre:"+CRLF+CRLF+;
							"Fornecedor  : "+cFornece+CRLF+;
							"Loja        : "+cLoja+CRLF+CRLF+;
							"Prod Fornece: "+AllTrim(cCodPrf)+CRLF+;
							"Cod Interno : "+AllTrim(SB1->B1_COD))
							Return .F.
						EndIf

						RecLock("SZ5", .F.)
						SZ5->Z5_FILIAL 	:= xFilial("SZ5")
						SZ5->Z5_FORNECE := cFornece
						SZ5->Z5_LOJA 	:= cLoja
						SZ5->Z5_NOMEFOR := cNomeFor
						SZ5->Z5_PRODUTO := SB1->B1_COD
						SZ5->Z5_NOMPROD := SB1->B1_DESC
						SZ5->Z5_CODPRF 	:= AllTrim(cCodPrf)
						SZ5->(MsUnLock())

						M->ZI_B1COD := SZ5->Z5_PRODUTO
						oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] := M->ZI_B1COD
						M->ZI_SDESC := SZ5->Z5_NOMPROD
						oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")] := M->ZI_SDESC
						oGetItem:oBrowse:Refresh()

						SZI->(DbGoTo(nRecnoSZI))
						RecLock("SZI", .F.)
						SZI->ZI_B1COD := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]
						SZI->ZI_SDESC := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")]
						SZI->(MsUnLock())

					Else

						/*
						M->ZI_B1COD := CriaVar("ZI_B1COD")
						oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] := M->ZI_B1COD
						M->ZI_SDESC :=CriaVar("ZI_SDESC")
						oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")] := M->ZI_SDESC
						oGetItem:oBrowse:Refresh()

						SZI->(DbGoTo(nRecnoSZI))
						RecLock("SZI", .F.)
						SZI->ZI_B1COD := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]
						SZI->ZI_SDESC := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")]
						SZI->(MsUnLock())
						*/

						Return .F.
					EndIf
				EndIf
			Else
				If MsgYesNo("Produto sem amarração Produto x Fornecedor!"+CRLF+CRLF+;
				"Deseja realizar amarração?"+CRLF+CRLF+;
				"Produto interno:"+CRLF+;
				SB1->B1_COD+CRLF+;
				SB1->B1_CODITE+CRLF+;
				SB1->B1_DESC+CRLF+CRLF+CRLF+;
				"Produto fornecedor:"+CRLF+;
				oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_CODPROD","aHeaderEx")]+CRLF+;
				oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_FDESC","aHeaderEx")],"Atenção")

					lTravaReg := SEEKREGSZ5(cFornece,cLoja,SB1->B1_COD,cCodPrf)
					If lTravaReg
						MsgStop("Controle de gravação de registro único na amarração de Produto x Fornecedor. Desfaça a amarração entre:"+CRLF+CRLF+;
						"Fornecedor  : "+cFornece+CRLF+;
						"Loja        : "+cLoja+CRLF+CRLF+;
						"Prod Fornece: "+AllTrim(cCodPrf)+CRLF+;
						"Cod Interno : "+AllTrim(SB1->B1_COD))
						Return .F.
					EndIf

					RecLock("SZ5", .T.)
					SZ5->Z5_FILIAL 	:= xFilial("SZ5")
					SZ5->Z5_FORNECE := cFornece
					SZ5->Z5_LOJA 	:= cLoja
					SZ5->Z5_NOMEFOR := cNomeFor
					SZ5->Z5_PRODUTO := SB1->B1_COD
					SZ5->Z5_NOMPROD := SB1->B1_DESC
					SZ5->Z5_CODPRF 	:= AllTrim(cCodPrf)
					SZ5->(MsUnLock())

					M->ZI_B1COD := SZ5->Z5_PRODUTO
					oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] := M->ZI_B1COD
					M->ZI_SDESC := SZ5->Z5_NOMPROD
					oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")] := M->ZI_SDESC
					oGetItem:oBrowse:Refresh()

					SZI->(DbGoTo(nRecnoSZI))
					RecLock("SZI", .F.)
					SZI->ZI_B1COD := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]
					SZI->ZI_SDESC := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")]
					SZI->(MsUnLock())
				Else
					M->ZI_B1COD := CriaVar("ZI_B1COD")
					oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] := M->ZI_B1COD
					Return .F.
				EndIf
			EndIf

			//ANALISA O NCM DO PRODUTO CADASTRADO NO SISTEMA COM O NCM QUE ESTA NO XML 
			NCMXML02(M->ZI_B1COD)

			//ATUALIZA CEST DE ACORDO COM TABELA DO GOVERNO
			CESTXML02()

			//BUSCA PEDIDO DE COMPRA VINCULADO AO XML              
			//PASSANDO O COD DO FORNECEDOR PARA BUSCAR PED COMPRA  
			XML02F4()

		Else
			MsgStop("Produto não cadastrado!")
			Return .F.
		EndIf

		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG1","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]),oCLEG2,oCLEG1)
		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG2","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]),oCLEG2,oCLEG1)
		oGetItem:oBrowse:Refresh()

	EndIf

	RestArea(aAreaVar)

Return lRet


//==================================================
//ATUALIZA CEST DE ACORDO COM TABELA DO GOVERNO    =
//==================================================
Static Function CESTXML02()

	Local aArea			:= GetArea()
	Local cSqlSZA
	Local cAliasSZA	
	Local oBrNcmCest
	Local aBrNcmCest 	:= {}
	Local lConfirm		:= .F.
	Local oGetProd
	Local cGetProd		:= AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_CODITE)+" - "+AllTrim(SB1->B1_DESC)
	Local cCest
	Local cPosipi

	DbSelectArea("SYD")
	SYD->(DbSetOrder(1)) //YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM+YD_DESTAQU

	cPosipi := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_POSIPI","aHeaderEx")]

	If SYD->(DbSeek(xFilial("SYD")+cPosipi))

		For i := Len(AllTrim(SYD->YD_TEC)) To 1 Step -1

			cAliasSZA := GetNextAlias()
			cSqlSZA := "SELECT * "+CRLF
			cSqlSZA += "FROM "+RetSqlName("SZA")+" SZA "+CRLF
			cSqlSZA += "WHERE "+CRLF
			cSqlSZA += "      SZA.ZA_POSIPI  = '"+SubStr(AllTrim(SYD->YD_TEC),1,i)+"' AND "+CRLF
			//cSqlSZA += "      SZA.ZA_SEGCEST = '01. Autopeças' AND "+CRLF
			cSqlSZA += "      SZA.D_E_L_E_T_ = ''"
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZA),cAliasSZA,.T.,.F.)

			(cAliasSZA)->(DbGoTop())

			If !(cAliasSZA)->(Eof())
				While !(cAliasSZA)->(Eof())

					aAdd(aBrNcmCest, {(cAliasSZA)->ZA_POSIPI,AllTrim((cAliasSZA)->ZA_CEST),AllTrim((cAliasSZA)->ZA_SEGCEST)})

					(cAliasSZA)->(DbSkip())
				EndDo
			EndIf
			(cAliasSZA)->(DbCloseArea())

		Next i

		If Empty(aBrNcmCest)
			MsgStop("Pos.IPI/NCM sem relacionamento com CEST - (Tabela - SZA)."+CRLF+CRLF+;
			"Favor conferir a tabela disponibilizada pelo Governo Federal e fazer o devido relacionamento!")
			Return
		Else

			DEFINE MSDIALOG oDlgNcmCest TITLE "Pos.IPI/NCM vs CEST" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

			@ 004, 002 MSGET oGetProd VAR cGetProd SIZE 294, 010 OF oDlgNcmCest WHEN .F. COLORS 0, 16777215 PIXEL

			oBrNcmCest := TWBrowse():New(017,002,294,129,,{"Pos.IPI/NCM","CEST","Segmento"},{50,50,50},oDlgNcmCest,,,,,{|| },,,,,,,.F.,,.T.,,.F.,,,)

			oBrNcmCest:SetArray(aBrNcmCest)

			oBrNcmCest:bLine := {|| {aBrNcmCest[oBrNcmCest:nAt,1],;
			aBrNcmCest[oBrNcmCest:nAt,2],;
			aBrNcmCest[oBrNcmCest:nAt,3]}}

			oBrNcmCest:bLDblClick := {|| cCest := aBrNcmCest[oBrNcmCest:nAt,2], lConfirm := .T., oDlgNcmCest:End()}

			ACTIVATE MSDIALOG oDlgNcmCest CENTERED

		EndIf

		If lConfirm

			DbSelectArea("F0G")
			F0G->(DbSetOrder(1))

			If F0G->(DbSeek(xFilial("F0G")+cCest))

				If MsgYesNo("Deseja atualizar Cod. Especificador ST (CEST) do produto: "+SB1->B1_COD+"?"+CRLF+CRLF+;
				"CEST Atual : " + Transform(SB1->B1_CEST ,"@R 99.999.99")+CRLF+;
				"CEST Novo  : " + Transform(F0G->F0G_CEST,"@R 99.999.99"))

					RecLock("SB1", .F.)
					SB1->B1_CEST := F0G->F0G_CEST
					SB1->(MsUnLock())

					MsgInfo("Cod. Especificador ST (CEST) do produto atualizado!")

				EndIf

			Else
				MsgInfo("CEST não cadastrado no sistema! F0G.")
			EndIf

		EndIf

	Else
		MsgStop("Pos.IPI/NCM não encontrado na tabela de Nomenclatura Comum do Mercosul (N.C.M)!"+CRLF+CRLF+;
		"Realize o cadastro do Pos.IPI/NCM: "+cPosipi+" na tabela SYD!")            
	EndIf

	RestArea(aArea)

Return


//==================================================
//BUSCA SECUNDARIO PELO COD DO ITEM = B1_CODITE    =
//==================================================
Static Function B1CODF3(cCodIte)

	Local cSqlF3
	Local cAliasF3 	:= GetNextAlias()
	Local oItemF3
	Local aItemF3	:= {}
	Local cRet		:= CriaVar("ZI_B1COD")
	Local oDlgF3

	cSqlF3 := "SELECT * "+CRLF
	cSqlF3 += "FROM "+RetSqlName("SB1")+" SB1 "+CRLF
	cSqlF3 += "WHERE "+CRLF
	cSqlF3 += "      SB1.B1_CODITE LIKE '%"+AllTrim(cCodIte)+"%' AND "+CRLF
	cSqlF3 += "      SB1.B1_MSBLQL != '1'                        AND "+CRLF
	cSqlF3 += "      SB1.D_E_L_E_T_ = ''"+CRLF
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlF3),cAliasF3,.T.,.F.)

	(cAliasF3)->(DbGoTop())

	If !(cAliasF3)->(Eof())
		While !(cAliasF3)->(Eof())

			aAdd(aItemF3, {(cAliasF3)->B1_COD,(cAliasF3)->B1_CODITE,(cAliasF3)->B1_DESC})

			(cAliasF3)->(DbSkip())
		EndDo
	Else
		MsgStop("Produto não encontrado!")
		cRet := "Erro"
		Return cRet
	EndIf
	(cAliasF3)->(DbCloseArea())

	If Len(aItemF3) > 1

		DEFINE MSDIALOG oDlgF3 TITLE "Produto Pedido de Compra" FROM 000, 000 TO 300, 700 COLORS 0, 16777215 PIXEL

		oItemF3 := TWBrowse():New(004,003,342,141,,{"Cod","Cod Item","Descrição"},{30,50,50},oDlgF3,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)

		oItemF3:SetArray(aItemF3)
		oItemF3:bLine := {|| {aItemF3[oItemF3:nAt,1],aItemF3[oItemF3:nAt,2],aItemF3[oItemF3:nAt,3]}}
		oItemF3:bLDblClick := {|| cRet := aItemF3[oItemF3:nAt,1], oDlgF3:End()}
		oItemF3:nScrollType := 1

		ACTIVATE MSDIALOG oDlgF3 CENTERED

	ElseIf Len(aItemF3) == 1
		cRet := aItemF3[1,1]
	EndIf

Return cRet


//================================================================
//CONTROLE DE TRAVAÇÃO DO RESGISTRO UNICO DA SZ5                 =
//SZ5 TEM CONTROLE DE UNIQ ID = FILIAL+FORCENEDER+LOJA+PRODUTO   =
//================================================================
Static Function SEEKREGSZ5(cFornece,cLoja,cCodProd,cCodPrf)

	Local lTrava 		:= .F.
	Local cSqlTrav
	Local cAliasTrav	:= GetNextAlias()

	cSqlTrav := "SELECT SZ5.R_E_C_N_O_ AS RECNOSZ5 "+CRLF
	cSqlTrav += "FROM "+RetSqlName("SZ5")+" SZ5 "+CRLF
	cSqlTrav += "WHERE "+CRLF
	cSqlTrav += "      SZ5.Z5_FORNECE = '"+cFornece+"' AND "+CRLF
	cSqlTrav += "      SZ5.Z5_LOJA    = '"+cLoja+"'    AND "+CRLF
	cSqlTrav += "      SZ5.Z5_PRODUTO = '"+cCodProd+"' AND "+CRLF
	cSqlTrav += "      SZ5.Z5_CODPRF  = '"+cCodPrf+"'  AND "+CRLF 
	cSqlTrav += "      SZ5.D_E_L_E_T_ = ''
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlTrav),cAliasTrav,.T.,.F.)

	(cAliasTrav)->(DbGoTop())

	If !(cAliasTrav)->(Eof())
		lTrava := .T.
	EndIf
	(cAliasTrav)->(DbCloseArea())

Return lTrava


//===========================================================
//DESFAZ AMARRAÇÃO DO PRODUTO								=
//APENAS LIMPA AMARRAÇÃO DO PRODUTO DA LINHA SELECIONADA	=
//===========================================================
Static Function XML02F5()

	Local nRecnoSZI := oGetItem:Acols[oGetItem:nAt,Len(oGetItem:Acols[oGetItem:nAt])-1]
	Local aAreaSZI  := GetArea()
	Local cAliasSZ5
	Local cSqlSZ5	

	If !MsgYesNo("Deseja desfazer essa amarração?","Atenção")
		Return
	EndIf

	DbSelectArea("SZI")
	SZI->(DbGoTo(nRecnoSZI))

	cAliasSZ5 := GetNextAlias()

	cSqlSZ5 := "SELECT SZ5.R_E_C_N_O_ AS RECNOSZ5 "+CRLF
	cSqlSZ5 += "FROM "+RetSqlName("SZ5")+" SZ5 "+CRLF
	cSqlSZ5 += "WHERE "+CRLF
	cSqlSZ5 += "      SZ5.Z5_FORNECE = '"+SZI->ZI_FORNECE+"' AND "+CRLF
	cSqlSZ5 += "      SZ5.Z5_LOJA    = '"+SZI->ZI_LOJA+"'    AND "+CRLF
	cSqlSZ5 += "      SZ5.Z5_CODPRF  = '"+SZI->ZI_CODPROD+"' AND "+CRLF
	cSqlSZ5 += "      SZ5.Z5_PRODUTO = '"+SZI->ZI_B1COD+"'   AND "+CRLF
	cSqlSZ5 += "      SZ5.D_E_L_E_T_ = ''
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZ5),cAliasSZ5,.T.,.F.)

	(cAliasSZ5)->(DbGoTop())

	If !(cAliasSZ5)->(Eof())

		(cAliasSZ5)->(DbGoTop())

		DbSelectArea("SZ5")
		SZ5->(DbGoTo((cAliasSZ5)->RECNOSZ5))
		RecLock("SZ5", .F.)
		DbDelete()
		SZ5->(MsUnLock())

		RecLock("SZI", .F.)
		SZI->ZI_B1COD := CriaVar("ZI_B1COD")
		SZI->ZI_SDESC := CriaVar("ZI_SDESC")
		SZI->(MsUnLock())

		M->ZI_B1COD := CriaVar("ZI_B1COD")
		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] := M->ZI_B1COD
		M->ZI_SDESC := CriaVar("ZI_SDESC")
		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_SDESC","aHeaderEx")] := M->ZI_SDESC
		oGetItem:oBrowse:Refresh()

		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG1","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]),oCLEG2,oCLEG1)
		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG2","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]),oCLEG2,oCLEG1)
		oGetItem:oBrowse:Refresh()

		MsgInfo("Amarração desfeita!")

	EndIf
	(cAliasSZ5)->(DbCloseArea())

	RestArea(aAreaSZI)

Return


//=====================================================
//CORRIGE A DIFERENÇA DOS PREÇOS 					  =
//ENTRE ITENS DO XML COM ITENS DO PEDIDO DE COMPRA    =
//=====================================================
Static Function ACERTAALL(aItensDiv)

	Local aAreaDiv 	:= GetArea()
	Local nPerAcert	:= 5/100 //5% MARGEM QUE PODERA SER ACERTADO PELO CORREÇÃO AUTOMATICA
	Local aCabec 	:= {}
	Local aItens 	:= {}

	Local cNumAux 	:= cNumEmp
	Local cFilAux 	:= cFilAnt

	Local cUpdSZ7
	Local nStatus
	Local cAliasSZ8
	Local cSqlSZ8
	Local cAliasSC7
	Local cSqlSC7
	Local cAliasSZ7
	Local cSqlSZ7

	Private lMsErroAuto	:= .F.

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))

	For i := 1 To Len(aItensDiv)

		nDif 	:= (aItensDiv[i,4] - aItensDiv[i,9]) * -1
		nDif 	:= IIF(nDif<0,nDif*-1,nDif)
		nValDif := aItensDiv[i,4] * nPerAcert

		If (nValDif - nDif) > 0

			SC7->(DbGoTo(aItensDiv[i,11]))

			If Empty(aCabec)
				aAdd(aCabec,{"C7_FILIAL" 	,SC7->C7_FILIAL	})
				aAdd(aCabec,{"C7_NUM" 		,SC7->C7_NUM	})
				aAdd(aCabec,{"C7_EMISSAO" 	,SC7->C7_EMISSAO})
				aAdd(aCabec,{"C7_FORNECE" 	,SC7->C7_FORNECE})
				aAdd(aCabec,{"C7_LOJA" 		,SC7->C7_LOJA	})
				aAdd(aCabec,{"C7_COND" 		,SC7->C7_COND	})
				aAdd(aCabec,{"C7_CONTATO" 	,SC7->C7_CONTATO})
				aAdd(aCabec,{"C7_FILENT" 	,SC7->C7_FILENT	})
			EndIf

			aLinha := {}
			aAdd(aLinha,{"C7_ITEM"		,SC7->C7_ITEM		,Nil})
			aAdd(aLinha,{"C7_PRODUTO"	,SC7->C7_PRODUTO	,Nil})
			aAdd(aLinha,{"C7_QUANT"		,aItensDiv[i,8]		,Nil})
			aAdd(aLinha,{"C7_PRECO"		,aItensDiv[i,9]		,Nil})
			aAdd(aLinha,{"C7_TOTAL"		,aItensDiv[i,10]	,Nil})
			aAdd(aLinha,{"C7_REC_WT" 	,SC7->(Recno()) 	,Nil})

			aAdd(aItens,aLinha)

		EndIf

	Next i

	If !Empty(aCabec) .AND. !Empty(aItens)

		//ALTERANDO A EMPRESA DE ACORDO COM A FILIAL DA NOTA
		cNumEmp := "01"+oGet_XML:ACOLS[oGetItem:nAt,FG_POSVAR("ZX_FILIAL","aHeaderEx1")]
		cFilAnt := oGet_XML:ACOLS[oGetItem:nAt,FG_POSVAR("ZX_FILIAL","aHeaderEx1")]
		DbSelectArea("SM0")
		SM0->(DbSeek(cNumEmp))

		//MsgRun("Acertando Pedido de Compra. Aguarde...","Processando",{|| MSExecAuto({ |v,x,y,z| MATA120(v,x,y,z)},1,aCabec,aItens,4)})
		MsgRun("Acertando Pedido de Compra. Aguarde...","Processando",{|| MATA120(1,aCabec,aItens,4)})
		//MATA120(1,aCabec,aItens,4)

		//VOLTA EMPRESA
		cNumEmp := cNumAux
		cFilAnt := cFilAux
		SM0->(DbSeek(cNumEmp))

		If lMsErroAuto
			MostraErro()
		Else
			//ALTERA VALORES NA SOLICITAÇÃO DE PEDIDO DE COMPRA
			//RECRIA A SOLICITAÇÃO DE COMPRA DE ACORDO COM PEDIDO ALTERADO...
			//DELETA TODA A SOLICITAÇÃO DE COMPRA E RECRIA COM OS ITENS DO PEDIDO DE COMPRA USANDO MESMO NUM DA SOLICITAÇÃO

			DbSelectArea("SZ8")
			SZ8->(DbSetOrder(1))

			//DELETANDO OS PRODUTOS DA SOLICITAÇÃO PARA RECRIAR DE ACORDO COM PED DE COMPRA ATUALIZADO 
			DbSelectArea("SZ7")
			SZ7->(DbSetOrder(1))
			cUpdSZ7 := "UPDATE "+RetSqlName("SZ7")+" SET D_E_L_E_T_ = '*' "+CRLF 
			cUpdSZ7 += "WHERE "+CRLF
			cUpdSZ7 += "      Z7_FILIAL  = '"+aCabec[1,2]+"' AND "+CRLF
			cUpdSZ7 += "      Z7_NUMPED  = '"+aCabec[2,2]+"' AND "+CRLF
			cUpdSZ7 += "      D_E_L_E_T_ = ''
			nStatus := TCSqlExec(cUpdSZ7)
			If (nStatus < 0)
				MsgStop("TCSQLError() " + TCSQLError())
				Return
			Endif

			//SELECIONANDO CABEÇALHO DA SOLICITAÇÃO DE COMPRA
			cAliasSZ8 := GetNextAlias()
			cSqlSZ8 := "SELECT SZ8.R_E_C_N_O_ AS RECNOSZ8  "+CRLF
			cSqlSZ8 += "FROM "+RetSqlName("SZ8")+" SZ8 "+CRLF
			cSqlSZ8 += "WHERE "+CRLF
			cSqlSZ8 += "      SZ8.Z8_FILIAL  = '"+aCabec[1,2]+"' AND "+CRLF
			cSqlSZ8 += "      SZ8.Z8_NUMPED  = '"+aCabec[2,2]+"' AND "+CRLF
			cSqlSZ8 += "      SZ8.D_E_L_E_T_ = ''"
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZ8),cAliasSZ8,.T.,.F.)

			(cAliasSZ8)->(DbGoTop())

			SZ8->(DbGoTo((cAliasSZ8)->RECNOSZ8))
			(cAliasSZ8)->(DbCloseArea())

			//CRIANDO NOVOS ITENS PARA A MESMA SOLICITAÇÃO DE COMPRA
			cAliasSC7 := GetNextAlias()
			cSqlSC7 := "SELECT * "+CRLF
			cSqlSC7 += "FROM "+RetSqlName("SC7")+" SC7 "+CRLF
			cSqlSC7 += "WHERE "+CRLF
			cSqlSC7 += "      SC7.C7_FILIAL  = '"+aCabec[1,2]+"' AND "+CRLF
			cSqlSC7 += "	  SC7.C7_NUM     = '"+aCabec[2,2]+"' AND "+CRLF 
			cSqlSC7 += "	  SC7.D_E_L_E_T_ = '' "+CRLF
			cSqlSC7 += "ORDER BY SC7.C7_ITEM"		
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSC7),cAliasSC7,.T.,.F.)

			(cAliasSC7)->(DbGoTop())

			While !(cAliasSC7)->(Eof())

				Reclock("SZ7", .T.)
				SZ7->Z7_FILIAL	:= SZ8->Z8_FILIAL	
				SZ7->Z7_NUMPED	:= SZ8->Z8_NUMPED
				SZ7->Z7_NUM		:= SZ8->Z8_NUM
				SZ7->Z7_ITEM	:= (cAliasSC7)->C7_ITEM
				SZ7->Z7_PRODUTO	:= (cAliasSC7)->C7_PRODUTO
				SZ7->Z7_CODITE	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSC7)->C7_PRODUTO,"B1_CODITE")
				SZ7->Z7_DESC	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSC7)->C7_PRODUTO,"B1_DESC")
				SZ7->Z7_TES		:= (cAliasSC7)->C7_TES
				SZ7->Z7_QUANT	:= (cAliasSC7)->C7_QUANT
				SZ7->Z7_PRECO	:= (cAliasSC7)->C7_PRECO
				SZ7->Z7_TOTAL	:= (cAliasSC7)->C7_TOTAL
				SZ7->Z7_CONDPAG	:= (cAliasSC7)->C7_COND
				SZ7->Z7_FORNECE	:= (cAliasSC7)->C7_FORNECE
				SZ7->Z7_LOJA	:= (cAliasSC7)->C7_LOJA
				SZ7->Z7_NOMEFOR	:= Posicione("SA2",1,xFilial("SA2")+(cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA,"A2_NOME")
				SZ7->Z7_SOLICIT	:= SZ8->Z8_SOLICIT
				SZ7->Z7_DTSOLIC	:= SZ8->Z8_DTSOLIC
				SZ7->Z7_STATUS	:= SZ8->Z8_STATUS
				SZ7->Z7_DTAPNEG	:= SZ8->Z8_DTAPNEG
				SZ7->Z7_IPI		:= (cAliasSC7)->C7_IPI
				SZ7->(MsUnLock())

				(cAliasSC7)->(DbSkip())
			EndDo
			(cAliasSC7)->(DbCloseArea())

			//ACERTANDO O TOTAL DA SOLICITAÇÃO DE COMPRA
			cAliasSZ7 := GetNextAlias()
			cSqlSZ7 := "SELECT SUM(SZ7.Z7_TOTAL) AS TOTAL "+CRLF
			cSqlSZ7 += "FROM "+RetSqlName("SZ7")+" SZ7 "+CRLF
			cSqlSZ7 += "WHERE "+CRLF
			cSqlSZ7 += "      SZ7.Z7_FILIAL  = '"+aCabec[1,2]+"' AND "+CRLF
			cSqlSZ7 += "      SZ7.Z7_NUMPED  = '"+aCabec[2,2]+"' AND "+CRLF
			cSqlSZ7 += "      SZ7.D_E_L_E_T_ = ''
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZ7),cAliasSZ7,.T.,.F.)

			(cAliasSZ7)->(DbGoTop())

			Reclock("SZ8", .F.)
			SZ8->Z8_TOTAL := (cAliasSZ7)->TOTAL
			SZ8->(MsUnLock())

			MsgInfo("Alteração concluída com sucesso!")

		EndIf
	Else
		MsgInfo("Correção automática não pode ser executada, entre em contado com o criador do Pedido de Compra para correção manual.")
	EndIf

	RestArea(aAreaDiv)

Return


//=====================================================
//CORRIGE A DIFERENÇA DOS PREÇOS 					  =
//ENTRE ITENS DO XML COM ITENS DO PEDIDO DE COMPRA    =
//=====================================================
Static Function ACITEMPED(aItemXml,aItemPed)

	Local aAreaDiv 		:= GetArea()
	Local nDif
	Local nValDif
	Local nPerAcert		:= 5/100 //5% MARGEM QUE PODERA SER ACERTADO PELO CORREÇÃO AUTOMATICA
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aLinha 		:= {}
	Local nRecno		:= aItemPed[7]
	Local cNumAux 		:= cNumEmp
	Local cFilAux 		:= cFilAnt 

	Private lMsErroAuto := .F.

	//NÃO POSSO ACERTAR ITEM DO PEDIDO SE ELE JA ESTIVER VINCULADO EM ALGUM ITEM DO XML
	For i := 1 To Len(oGetItem:ACOLS)
		If oGetItem:nAt != i
			If AllTrim(cValTochar(oGetItem:ACOLS[i,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])) == AllTrim(cValToChar(nRecno))
				MsgStop("Este Item do Pedido de Compra já esta amarrado ao Item do XML. Portando não pode ser corrigido. Desamarre este Item para continuar!")
				Return
			EndIf
		EndIf
	Next i

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	nDif 	:= (aItemPed[4] - aItemXml[3]) * -1
	nDif 	:= IIF(nDif < 0,nDif * -1,nDif)
	//nValDif := aItemPed[4] * nPerAcert

	If MsgYesNo("Deseja Continua com acerto do Pedido de Compra?","Atenção")
		BEGIN TRANSACTION

			SC7->(DbGoTo(nRecno))

			SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))

			//CABEÇALHO
			aAdd(aCabec,{"C7_NUM" 		,SC7->C7_NUM	})
			aAdd(aCabec,{"C7_EMISSAO" 	,SC7->C7_EMISSAO})
			aAdd(aCabec,{"C7_FORNECE" 	,SC7->C7_FORNECE})
			aAdd(aCabec,{"C7_LOJA" 		,SC7->C7_LOJA	})
			aAdd(aCabec,{"C7_COND" 		,SC7->C7_COND	})
			aAdd(aCabec,{"C7_CONTATO" 	,SC7->C7_CONTATO})
			aAdd(aCabec,{"C7_FILENT" 	,SC7->C7_FILENT	})

			//ITENS
			aAdd(aLinha,{"C7_ITEM"		,SC7->C7_ITEM	,Nil})
			aAdd(aLinha,{"C7_PRODUTO"	,SC7->C7_PRODUTO,Nil})
			If aItemXml[2] > aItemPed[3]
				aAdd(aLinha,{"C7_QUANT"		,aItemXml[2]	,Nil})
			Else
				aAdd(aLinha,{"C7_QUANT"		,SC7->C7_QUANT	,Nil})
			EndIf
			aAdd(aLinha,{"C7_PRECO"		,aItemXml[3]	,Nil})
			aAdd(aLinha,{"C7_DESCRI"	,SC7->C7_DESCRI	,Nil})
			aAdd(aLinha,{"C7_YPOSIPI"	,SB1->B1_POSIPI ,Nil})
			aAdd(aLinha,{"C7_YCREPF"	,SC7->C7_YCREPF ,Nil})		
			aAdd(aLinha,{"C7_YORIGEM"	,SB1->B1_ORIGEM ,Nil})
			aAdd(aLinha,{"C7_REC_WT" 	,SC7->(Recno()) ,Nil})

			aAdd(aItens,aLinha)

			cNumEmp := "01"+SZX->ZX_FILIAL
			cFilAnt := SZX->ZX_FILIAL
			DbSelectArea("SM0")
			SM0->(DbSeek(cNumEmp))

			MsgRun("Acertando Pedido de Compra. Aguarde...","Processando",{|| MATA120(1,aCabec,aItens,4)})

			cNumEmp := cNumAux
			cFilAnt := cFilAux
			SM0->(DbSeek(cNumEmp))

			If lMsErroAuto
				MostraErro()
			Else
				//ALTERA VALORES NA SOLICITAÇÃO DE PEDIDO DE COMPRA
				//RECRIA A SOLICITAÇÃO DE COMPRA DE ACORDO COM PEDIDO ALTERADO...
				//DELETA TODA A SOLICITAÇÃO DE COMPRA E RECRIA COM OS ITENS DO PEDIDO DE COMPRA USANDO MESMO NUM DA SOLICITAÇÃO

				SC7->(DbGoTo(nRecno))

				For i := 1 To Len(oItensPed:aArray)
					If oItensPed:aArray[i,7] == SC7->(Recno())
						oItensPed:aArray[i,3] := SC7->C7_QUANT
						oItensPed:aArray[i,4] := SC7->C7_PRECO
						oItensPed:aArray[i,5] := SC7->C7_TOTAL
						Exit
					EndIf
				Next i

				oItensPed:Refresh()

				MsgInfo("Alteração concluída com sucesso!")

			EndIf

		END TRANSACTION
	EndIf

	RestArea(aAreaDiv)

	SetKey(VK_F4, {|| XML02F4()})

Return


//=====================================================
//DESSAMARRA PRODUTO              					  =
//ENTRE ITENS DO XML COM ITENS DO PEDIDO DE COMPRA    =
//=====================================================
Static Function DEITEMPED(aItemXml,aItemPed)

	Local aAreaDe := GetArea()

	If !Empty(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]) .AND. ;
	!Empty(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_RECNOC7","aHeaderEx")])

		oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]  := CriaVar("ZI_NUMPED")
		oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_RECNOC7","aHeaderEx")] := CriaVar("ZI_NUMPED")
		oGetItem:oBrowse:Refresh()

		DbSelectArea("SZI")
		SZI->(DbGoTo(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("R_E_C_N_O_","aHeaderEx")]))
		RecLock("SZI", .F.)	
		SZI->ZI_NUMPED  := CriaVar("ZI_NUMPED")
		SZI->ZI_RECNOC7 := CriaVar("ZI_RECNOC7")
		SZI->(MsUnLock())

		MsgInfo("Dessamarração concluida!")

		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG1","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")]),oCLEG2,oCLEG1)
		oGetItem:Acols[oGetItem:nAt,FG_POSVAR("CLEG2","aHeaderEx")] := IIF(Empty(oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_NUMPED","aHeaderEx")]),oCLEG2,oCLEG1)
		oGetItem:oBrowse:Refresh()

	EndIf

	RestArea(aAreaDe)

Return	


//===================================
//ATUALIZA TELA DE TOTALIZADORES    =
//===================================
Static Function ATUATOTAIS()

	oBrTotais:SetArray(aBrTotais)
	oBrTotais:bLine := {|| {;
	Transform(aBrTotais[oBrTotais:nAt,1],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,2],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,3],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,4],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,5],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,6],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,7],"@E 999,999,999.99"),;
	Transform(aBrTotais[oBrTotais:nAt,8],"@E 999,999,999.99")}}
	oBrTotais:bLDblClick := {|| }
	oBrTotais:nScrollType := 1
	oBrTotais:Refresh()

Return	


//=======================================
//ATUALIZA TELA DE TOTALIZADORES GERAIS	=
//=======================================
Static Function ATUAGERAL()

	oBrGeral:SetArray(aBrGeral)
	oBrGeral:bLine := {|| {;
	Transform(aBrGeral[oBrGeral:nAt,1],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,2],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,3],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,4],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,5],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,6],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,7],"@E 999,999,999.99"),;
	Transform(aBrGeral[oBrGeral:nAt,8],"@E 999,999,999.99")}}
	oBrGeral:bLDblClick := {|| }
	oBrGeral:nScrollType := 1
	oBrGeral:Refresh()

Return	


//=======================================
//FILTRO NOS DOCUMENTOS - XML           =
//FACILITANDO A BUSCA DAS NOTAS         =
//=======================================
Static Function XMLFILTRO()

	Local aAreaXml		:= GetArea()
	Local cAliasSZX
	Local cSqlSZX
	Local aGetXmlAux
	Local i

	If Pergunte("APJXML02", .T.)

		DbSelectArea("SF1")
		SF1->(DbSetOrder(8))

		cAliasSZX := GetNextAlias()
		//cSqlSZX := "SELECT ISNULL(CONVERT(VARCHAR(4047), CONVERT(VARBINARY(4047), ZX_OBSNF)),'') AS ZX_OBSNF, * "+CRLF
		cSqlSZX := "SELECT SZX.R_E_C_N_O_ AS RECNOSZX "+CRLF
		cSqlSZX += "FROM "+RetSqlName("SZX")+" SZX "+CRLF
		cSqlSZX += "WHERE "+CRLF
		cSqlSZX += "      SZX.ZX_FORNECE NOT IN ('000002','000636') AND "+CRLF
		cSqlSZX += "      SZX.ZX_TIPOXML = '"+IIF(cTpNfota == "NF-e","NFE  ","CTE  ")+"' AND "+CRLF

		//cStatusXML {"Docto. não Classificado","Docto. Normal","Ambas"}
		If cStatusXML == "Docto. não Classificado"
			cSqlSZX += "      SZX.ZX_ENTRADA = 'F' AND "+CRLF
		ElseIf cStatusXML == "Docto. Normal"
			cSqlSZX += "      SZX.ZX_ENTRADA = 'T' AND "+CRLF
		EndIf

		/*
		If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cSqlSZX += "      SZX.ZX_FORNECE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "+CRLF
		EndIf
		If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
		cSqlSZX += "      SZX.ZX_LOJA    BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "+CRLF
		EndIf
		If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
		cSqlSZX += "      SZX.ZX_DOC     BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "+CRLF
		EndIf
		If !Empty(MV_PAR07) .OR. !Empty(MV_PAR08)
		cSqlSZX += "      SZX.ZX_SERIE   BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "+CRLF
		EndIf
		If MV_PAR09 != cTod("  /  /    ") .AND. MV_PAR10 != cTod("  /  /    ")
		cSqlSZX += "      SZX.ZX_EMISSAO BETWEEN  "+ValToSql(MV_PAR09)+" AND "+ValToSql(MV_PAR10)+" AND "+CRLF
		EndIf
		If !Empty(MV_PAR11) .OR. !Empty(MV_PAR12)
		cSqlSZX += "      SZX.ZX_CHVNFE  BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "+CRLF
		EndIf
		*/
		cSqlSZX += "      SZX.ZX_FORNECE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "+CRLF
		cSqlSZX += "      SZX.ZX_LOJA    BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "+CRLF
		cSqlSZX += "      SZX.ZX_DOC     BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "+CRLF
		cSqlSZX += "      SZX.ZX_SERIE   BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "+CRLF
		cSqlSZX += "      SZX.ZX_EMISSAO BETWEEN  "+ValToSql(MV_PAR09)+" AND "+ValToSql(MV_PAR10)+" AND "+CRLF
		cSqlSZX += "      SZX.ZX_CHVNFE  BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "+CRLF
		cSqlSZX += "	  SZX.D_E_L_E_T_ = '' "+CRLF	
		cSqlSZX += "ORDER BY SZX.ZX_FILIAL"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSZX),cAliasSZX,.T.,.F.)

		(cAliasSZX)->(DbGoTop())

		If !(cAliasSZX)->(Eof())
			aGetXml  := {}
			aBrGeral := {}
			aAdd(aBrGeral, {0,0,0,0,0,0,0,0})
			While !(cAliasSZX)->(Eof())

				aGetXmlAux := {}

				//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				//If !SF1->(DbSeek((cAliasSZX)->ZX_FILIAL+(cAliasSZX)->ZX_DOC+(cAliasSZX)->ZX_SERIE+(cAliasSZX)->ZX_FORNECE+(cAliasSZX)->ZX_LOJA+(cAliasSZX)->ZX_TIPO))

				SZX->(DbGoTo((cAliasSZX)->RECNOSZX))

				//ATUALIZANDO TOTALIZADORES
				//aAdd(aBrGeral, {SZX->ZX_VALMERC,SZX->ZX_VALDESC,SZX->ZX_BASEICM,SZX->ZX_VALICM,SZX->ZX_VALIPI,SZX->ZX_VALBRUT})
				aBrGeral[1,1] += SZX->ZX_VALMERC
				aBrGeral[1,2] += SZX->ZX_VALDESC
				aBrGeral[1,3] += SZX->ZX_DESPESA
				aBrGeral[1,4] += SZX->ZX_FRETE
				aBrGeral[1,5] += SZX->ZX_BASEICM
				aBrGeral[1,6] += SZX->ZX_VALICM
				aBrGeral[1,7] += SZX->ZX_VALIPI
				aBrGeral[1,8] += SZX->ZX_VALBRUT
				//=====

				If !SF1->(DbSeek(SZX->ZX_FILIAL+SZX->ZX_CHVNFE))

					For i := 1 To Len(aCpoXml)
						If aCpoXml[i] == "COR"
							If SZX->ZX_ENTRADA
								aAdd(aGetXmlAux, oVermelho)
							Else
								aAdd(aGetXmlAux, oVerde)
							EndIf
						ElseIf aCpoXml[i] == "R_E_C_N_O_"
							aAdd(aGetXmlAux, SZX->(Recno()))
						Else
							aAdd(aGetXmlAux, SZX->&(aCpoXml[i]))
						EndIf
					Next i

					aAdd(aGetXml, aGetXmlAux)
				Else

					If !SZX->ZX_ENTRADA
						RecLock("SZX", .F.)
						SZX->ZX_ENTRADA := .T.
						SZX->(MsUnLock())
					EndIf

				EndIf

				(cAliasSZX)->(DbSkip())
			EndDo
		Else
			MsgStop("Nenhum registro encontrado!")
			(cAliasSZX)->(DbCloseArea())
			RestArea(aAreaXml)
			Return
		EndIf
		(cAliasSZX)->(DbCloseArea())

		RestArea(aAreaXml)

		FGETXML()
		CHANGEXML()
		ATUAGERAL()

	EndIf

Return


//============================================================================
//ANALISA O NCM DO PRODUTO CADASTRADO NO SISTEMA COM O NCM QUE ESTA NO XML   =
//============================================================================
Static Function NCMXML02(cProdNcm)

	Local cNcmXml 	:= oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_POSIPI","aHeaderEx")]
	Local nAtuaProd
	Local aAreaManu
	Local aArea		:= GetArea()

	If SB1->(DbSeek(xFilial("SB1")+cProdNcm))
		If SB1->B1_POSIPI != cNcmXml

			nAtuaProd := Aviso("Aviso","O N.C.M. do produto (Interno): "+CRLF+AllTrim(SB1->B1_COD)+CRLF+AllTrim(SB1->B1_DESC)+CRLF+;
			"Esta diferente do N.C.M. encontrado na Nota Fiscal de Entrada (XML)."+CRLF+CRLF+;
			"Deseja Atualiza N.C.M. do produto (Interno)?"+CRLF+;
			"N.C.M. Produto (Interno): "+SB1->B1_POSIPI+CRLF+;
			"N.C.M. Produto (XML)    : "+cNcmXml,{"Sim","Não"},3)

			//ATUALIZA O NCM DO PRODUTO
			If nAtuaProd == 1

				aAreaManu := GetArea()

				//VERIFICA SE O NCM ESTA CADASTRADO NA TABELA SYD
				DbSelectArea("SYD")
				SYD->(DbSetOrder(1))//SYD->YD_FILIAL+SYD->YD_TEC

				If SYD->(DbSeek(xFilial("SYD")+cNcmXml))

					//ATUALIZA O N.C.M. DO PRODUTO CADASTRADO
					Reclock("SB1", .F.)
					SB1->B1_POSIPI := SYD->YD_TEC
					SB1->(MsUnLock())

					MsgInfo("N.C.M. Produto (Interno) atualizado!",'Atualizado')

				Else
					MsgStop("N.C.M. Produto (XML): "+cNcmXml+" não esta cadastrado na tabela de N.C.M. (SYD) do sistema!",'Alerta')
				EndIf

				RestArea(aAreaManu)				
			Else
				RestArea(aArea)
			EndIf			  
		EndIf
	EndIf

Return


//=========================================
//REVALIDAÇÃO DOS PRODUTOS X FORNECEDOR   =
//N.C.M									  =
//=========================================
Static Function PREVALPROD()

	Local lRet 			:= .T.
	Local cAliasPval 	:= GetNextAlias()
	Local cSqlPval
	Local aAreaPval		:= GetArea()
	Local oFontPval 	:= TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.T.)
	Local oGroup1
	Local oSay1
	Local lConfPval		:= .F.

	Private oDlgPval
	Private oOkPval 	:= LoadBitmap( GetResources(), "LBOK")
	Private oNoPval 	:= LoadBitmap( GetResources(), "LBNO")
	Private oBrPval
	Private aBrPval 	:= {}

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	cSqlPval := "SELECT * FROM "+RetSqlname("SZI")+" SZI "+CRLF
	cSqlPval += "WHERE "+CRLF
	cSqlPval += "	   SZI.ZI_FILIAL  = '"+SZX->ZX_FILIAL+"'  AND "+CRLF
	cSqlPval += "      SZI.ZI_DOC     = '"+SZX->ZX_DOC+"'     AND "+CRLF
	cSqlPval += "      SZI.ZI_SERIE   = '"+SZX->ZX_SERIE+"'   AND "+CRLF
	cSqlPval += "      SZI.ZI_FORNECE = '"+SZX->ZX_FORNECE+"' AND "+CRLF
	cSqlPval += "      SZI.ZI_LOJA    = '"+SZX->ZX_LOJA+"'    AND "+CRLF
	cSqlPval += "	   SZI.D_E_L_E_T_ = '' "+CRLF
	cSqlPval += "ORDER BY SZI.ZI_SEQUEN"	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlPval),cAliasPval,.T.,.F.)

	(cAliasPval)->(DbGoTop())

	While !(cAliasPval)->(Eof())

		If SB1->(DbSeek(xFilial("SB1")+(cAliasPval)->ZI_B1COD))
			If SB1->B1_POSIPI != (cAliasPval)->ZI_POSIPI
				aAdd(aBrPval, {.T.,SB1->B1_COD,SB1->B1_POSIPI,"<-->",(cAliasPval)->ZI_CODPROD,(cAliasPval)->ZI_POSIPI})
			EndIf
		EndIf

		(cAliasPval)->(DbSkip())
	EndDo

	(cAliasPval)->(DbCloseArea())

	//NOTIFICAÇÃO DOS PRODUTOS COM DIVERGENCIA NOS N.C.M.
	If !Empty(aBrPval)

		DEFINE MSDIALOG oDlgPval TITLE "Divergência N.C.M. dos Produtos" FROM 000, 000  TO 490, 800 COLORS 0, 16777215 PIXEL

		@ 002, 002 GROUP oGroup1 TO 035, 397 OF oDlgPval COLOR 0, 16777215 PIXEL
		@ 012, 123 SAY oSay1 PROMPT "Divergência nos N.C.M." SIZE 120, 015 OF oDlgPval FONT oFontPval COLORS 255, 16777215 PIXEL

		oBrPval := TWBrowse():New(037,002,395,190,,{"","Cod Interno","N.C.M. Interno","<-->","Produto Forncedor","N.C.M. Fornecedor"},;
		{},oDlgPval,,,,{|| },,,,,,,,.F.,,.T.,,.F.,,,)

		oBrPval:SetArray(aBrPval)

		oBrPval:bLine := {|| {If(aBrPval[oBrPval:nAT,1],oOkPval,oNoPval),;
		aBrPval[oBrPval:nAt,2],aBrPval[oBrPval:nAt,3],;
		aBrPval[oBrPval:nAt,4],aBrPval[oBrPval:nAt,5],;
		aBrPval[oBrPval:nAt,6]}}

		oBrPval:bLDblClick := {|| aBrPval[oBrPval:nAt,1] := !aBrPval[oBrPval:nAt,1], oBrPval:DrawSelect()}
		oBrPval:nScrollType := 1

		//@ 230, 002 BUTTON oButton1 PROMPT "Reverter Seleção" SIZE 055, 012 OF oDlgPval PIXEL
		@ 230, 289 BUTTON oBt PROMPT "Cancelar" SIZE 037, 012 OF oDlgPval ACTION {|| lRet := .F., oDlgPval:End()} PIXEL
		@ 230, 331 BUTTON oButton2 PROMPT "Atualizar e Continuar  >>" SIZE 065, 012 OF oDlgPval ACTION {|| lConfPval := .T., oDlgPval:End()} PIXEL

		ACTIVATE MSDIALOG oDlgPval CENTERED

		If lConfPval

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))

			DbSelectArea("SYD")
			SYD->(DbSetOrder(1))//SYD->YD_FILIAL+SYD->YD_TEC	

			For i := 1 To Len(aBrPval)
				If aBrPval[i,1] //PRODUTO MARCADO PARA ATUALIZAÇÃO DO N.C.M.
					If SB1->(DbSeek(xFilial("SB1")+aBrPval[i,2]))
						If SYD->(DbSeek(xFilial("SYD")+aBrPval[i,6]))

							//ATUALIZA O N.C.M. DO PRODUTO CADASTRADO
							Reclock("SB1", .F.)
							SB1->B1_POSIPI := SYD->YD_TEC
							SB1->(MsUnLock())

						EndIf
					EndIf
				EndIf
			Next i

		EndIf
	EndIf

	RestArea(aAreaPval)

Return lRet


//==================================
//VERIFICA NCM X CEST DO PRODUTO   =
//==================================
Static Function XML02F6()

	Local cReadVar := ReadVar()

	If Empty(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")])
		MsgStop("Cod Interno não informado!")
		Return
	EndIf

	__ReadVar := "M->ZI_B1COD"

	M->ZI_B1COD := oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_B1COD","aHeaderEx")] 

	u_XML02CPO()

	__ReadVar := cReadVar

Return


//==================================================
//FACILITADOR DE AMARRAÇÃO PRODUTO VS FORNECEDOR   =
//==================================================
Static Function XML02F2()

	Local cReadVar := ReadVar()

	__ReadVar := "M->ZI_B1COD"

	M->ZI_B1COD := oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_CODPROD","aHeaderEx")]

	u_XML02CPO()

	__ReadVar := cReadVar

Return


//==================================================================
//CONFIRMAÇÃO DA ENTRADA DA NOTA FISCAL NO SISTEMA				   =
//POR ALGUM MOTIVO A NOTA JA FOI DADO ENTRADA NÃO SOME DO GRID     =
//==================================================================
Static Function CONFENTRA()

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	If MsgYesNo("Deseja confirmar a entrada da Nota Fiscal? "+CRLF+;
	"Doc: "+SZX->ZX_DOC+" - "+SZX->ZX_SERIE+CRLF+;
	"Fornecedor: "+SZX->ZX_FORNECE+" - "+SZX->ZX_LOJA)

		RecLock("SZX", .F.)
		SZX->ZX_ENTRADA := .T.
		SZX->(MsUnLock())

		MsgInfo("Entrada confirmada!")

		//ATUALIZA GRID DO CABEÇALHO
		SEEKGETXML()
		FGETXML()
		CHANGEXML()

	EndIf

Return


//======================================================
//AJUSTE DE PREÇO    								   =
//======================================================
Static Function AJUSTAPRC()

	DbSelectArea("SZX")
	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	u_XMLPRECO()

Return


//=============================================
//PROGRAMA DE CONVERSÃO DE UNIDADE DE MEDIDA  =
//=============================================
Static Function XMLUM()

	Local oBtClose
	Local oBtInclui
	Local oBtOk
	Local oGetProd
	Local cGetProd	:= AllTrim(oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_CODPROD","aHeaderEx")])+" - "+oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_FDESC","aHeaderEx")] 	
	Local oGetUm
	Local cGetUm 	:= oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_UM","aHeaderEx")]	
	Local oGroup1
	Local oGroup2
	Local oSay1
	Local oSay2
	Local cSqlNNX
	Local cAliasNNX	:= GetNextAlias()
	Local nQtd	 	:= oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_QTD","aHeaderEx")]
	Local oQtd
	Local nQtdCo
	Local lConfirm	:= .F.
	Local nRecnoSZI
	Local aConvert	:= {}

	Private oDlgCoUm
	Private oBrCoUm
	Private aBrCoUm := {}

	cSqlNNX := "SELECT * "+CRLF
	cSqlNNX += "FROM "+RetSqlName("NNX")+" NNX "+CRLF
	cSqlNNX += "WHERE "+CRLF
	cSqlNNX += "      NNX.NNX_UMORIG = '"+Upper(cGetUm)+"' AND "+CRLF
	cSqlNNX += "      NNX.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlNNX),cAliasNNX,.T.,.F.)

	(cAliasNNX)->(DbGoTop())

	If !(cAliasNNX)->(Eof())
		While !(cAliasNNX)->(Eof())

			If (cAliasNNX)->NNX_OPERA == "*"
				nQtdCo := nQtd * (cAliasNNX)->NNX_FATOR
			ElseIf (cAliasNNX)->NNX_OPERA == "/"
				nQtdCo := nQtd / (cAliasNNX)->NNX_FATOR
			EndIf

			//"Unid. Orig.","Operador","Fator"," ","Qtd. Convertida","Unid. Dest."
			aAdd(aBrCoUm, {(cAliasNNX)->NNX_UMORIG,(cAliasNNX)->NNX_OPERA,(cAliasNNX)->NNX_FATOR," = ",nQtdCo,(cAliasNNX)->NNX_UMDEST})

			(cAliasNNX)->(DbSkip())
		EndDo
	Else
		MsgStop("UM: "+cGetUm+" Não encontrada na Tabela de Conversão de UM."+CRLF+;
		"Favor realizar o cadastro do mesmo na Rotina AGRA060() ou clique em Incluir!")
		aAdd(aBrCoUm, {"","",0," = ",0,""})        
	EndIf
	(cAliasNNX)->(DbCloseArea())

	DEFINE MSDIALOG oDlgCoUm TITLE "Unidade de Conversão de Medida" FROM 000, 000  TO 500, 815 COLORS 0, 16777215 PIXEL

	@ 002, 002 GROUP oGroup1 TO 070, 407 PROMPT "Unidade de Medida Item do XML - Doc Entrada" OF oDlgCoUm COLOR 0, 16777215 PIXEL

	@ 015, 005 SAY oSay1 PROMPT "Produto" SIZE 025, 007 OF oDlgCoUm COLORS 0, 16777215 PIXEL
	@ 022, 005 MSGET oGetProd VAR cGetProd SIZE 241, 010 OF oDlgCoUm WHEN .F. COLORS 0, 16777215 PIXEL

	@ 044, 005 SAY oSay3 PROMPT "Quantidade" SIZE 054, 007 OF oDlgCoUm COLORS 0, 16777215 PIXEL
	@ 052, 005 MSGET oQtd VAR nQtd SIZE 060, 010 OF oDlgCoUm WHEN .F. PICTURE "@E 999,999,999,999.99" COLORS 0, 16777215 HASBUTTON PIXEL 

	@ 045, 075 SAY oSay2 PROMPT "Unidade de Medida" SIZE 054, 007 OF oDlgCoUm COLORS 0, 16777215 PIXEL
	@ 053, 075 MSGET oGetUm VAR cGetUm SIZE 045, 010 OF oDlgCoUm WHEN .F. COLORS 0, 16777215 PIXEL

	@ 076, 002 GROUP oGroup2 TO 232, 407 PROMPT "Unidade de Conversão de Medida" OF oDlgCoUm COLOR 0, 16777215 PIXEL
	oBrCoUm := TWBrowse():New(085,005,399,143,,{"Unid. Orig.","Operador","Fator","","Qtd. Convertida","Unid. Dest."},;
	{},oDlgCoUm,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrCoUm:SetArray(aBrCoUm)
	oBrCoUm:bLine := {|| {aBrCoUm[oBrCoUm:nAt,1],aBrCoUm[oBrCoUm:nAt,2],;
	Transform(aBrCoUm[oBrCoUm:nAt,3],"@E 999,999.999999"),aBrCoUm[oBrCoUm:nAt,4],;
	Transform(aBrCoUm[oBrCoUm:nAt,5],"@E 999,999,999,999.99"),aBrCoUm[oBrCoUm:nAt,6]}}
	oBrCoUm:bLDblClick := {|| IIF(MsgYesNo("Deseja continuar com esta conversão?"),;
	(lConfirm := .T., aConvert := aBrCoUm[oBrCoUm:nAt], oDlgCoUm:End()),Nil)}
	oBrCoUm:nScrollType := 1

	@ 235, 002 BUTTON oBtInclui PROMPT "Incluir" SIZE 037, 012 OF oDlgCoUm ACTION {|| XMLUMINC()} PIXEL
	@ 235, 324 BUTTON oBtOk PROMPT "Confirmar" SIZE 037, 012 OF oDlgCoUm ACTION {|| IIF(MsgYesNo("Deseja continuar com esta conversão?"),;
	(lConfirm := .T., aConvert := aBrCoUm[oBrCoUm:nAt], oDlgCoUm:End()),Nil)} PIXEL
	@ 235, 367 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlgCoUm ACTION oDlgCoUm:End() PIXEL

	ACTIVATE MSDIALOG oDlgCoUm CENTERED

	If lConfirm

		nRecnoSZI := oGetItem:Acols[oGetItem:nAt,FG_POSVAR("R_E_C_N_O_","aHeaderEx")]

		SZI->(DbGoTo(nRecnoSZI))

		Begin Transaction

			RecLock("SZI", .F.)
			SZI->ZI_QTD		:= aConvert[5]
			SZI->ZI_VUNIT   := IIF(aConvert[2] == "*",(SZI->ZI_VUNIT/aConvert[3]),(SZI->ZI_VUNIT*aConvert[3]))    
			SZI->ZI_UM		:= aConvert[6]
			SZI->(MsUnLock())

			oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_QTD"  ,"aHeaderEx")]	:= SZI->ZI_QTD
			oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_VUNIT","aHeaderEx")]	:= SZI->ZI_VUNIT
			oGetItem:Acols[oGetItem:nAt,FG_POSVAR("ZI_UM"   ,"aHeaderEx")]	:= SZI->ZI_UM
			oGetItem:oBrowse:Refresh()

		End Transaction

	EndIf

Return


//==============================================================
//INCLUSÃO DE UNIDADE DE CONVERSÃO NA TABELA DE CONVERSÃO UM   =
//==============================================================
Static Function XMLUMINC()

	Local aArea			:= GetArea()
	Local nOpcConf
	Local aButtons		:= {}
	Local cSqlNNX
	Local cAliasNNX
	Local nQtd	 		:= oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_QTD","aHeaderEx")]
	Local cGetUm 		:= oGetItem:ACOLS[oGetItem:nAt,FG_POSVAR("ZI_UM","aHeaderEx")]	
	Local nQtdCo
	Local aSize    		:= MsAdvSize()
	Local aObjects 		:= {{100,100,.T.,.T.},{100,100,.T.,.T.},{100,015,.T.,.F.}}
	Local aInfo    		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  		:= MsObjSize(aInfo,aObjects)
	Local nOpcX    		:= 3
	Local nOpcA    		:= 0
	Local nY       		:= 0

	Private aGets  		:= Array(0)
	Private aTela  		:= Array(0,0)
	Private oDlg
	Private oEnch
	Private cCadastro 	:= "Tabela de Conversão de UM"

	INCLUI := .T.

	DbSelectArea("NNX")
	NNX->(DbSetOrder(1))

	RegToMemory('NNX',(nOpcX==3))

	M->NNX_UMORIG := Upper(cGetUm)

	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NNX',0,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.T.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(XMLUMINCV(nOpcX), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

	If nOpcA == 1 .AND. (nOpcX == 3 .OR. nOpcX == 4 .OR. nOpcX == 5)

		Begin Transaction
			dbSelectArea('NNX')
			dbSetOrder(1)
			dbSeek(xFilial('NNX')+M->NNX_UMORIG+M->NNX_UMDEST)
			If nOpcX == 3
				If RecLock('NNX',.T.)
					For nY := 1 To FCount()
						&(FieldName(nY)) := &('M->'+FieldName(nY))
					Next nY
					NNX->NNX_FILIAL := xFilial('NNX')
					MsUnLock()
				EndIf
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
			If nOpcX == 4
				If RecLock('NNX',.F.)
					For nY := 1 To FCount()
						&(FieldName(nY)) := &('M->'+FieldName(nY))
					Next nY
					msUnLock()
				EndIf
			EndIf
			If nOpcX == 5
				If RecLock('NNX',.F.)
					dbDelete()
					msUnLock()
				EndIf
			EndIf
		End Transaction
	Else
		If nOpcX == 3
			If __lSX8
				RollBackSX8()
			EndIf
		EndIf
	EndIf

	If nOpcA == 1 .AND. nOpcX == 3

		cAliasNNX := GetNextAlias()
		aBrCoUm := {}

		cSqlNNX := "SELECT * "+CRLF
		cSqlNNX += "FROM "+RetSqlName("NNX")+" NNX "+CRLF
		cSqlNNX += "WHERE "+CRLF
		cSqlNNX += "      NNX.NNX_UMORIG = '"+Upper(cGetUm)+"' AND "+CRLF
		cSqlNNX += "      NNX.D_E_L_E_T_ = ''"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlNNX),cAliasNNX,.T.,.F.)

		(cAliasNNX)->(DbGoTop())

		If !(cAliasNNX)->(Eof())
			While !(cAliasNNX)->(Eof())

				If (cAliasNNX)->NNX_OPERA == "*"
					nQtdCo := nQtd * (cAliasNNX)->NNX_FATOR
				ElseIf (cAliasNNX)->NNX_OPERA == "/"
					nQtdCo := nQtd / (cAliasNNX)->NNX_FATOR
				EndIf

				//"Unid. Orig.","Operador","Fator"," ","Qtd. Convertida","Unid. Dest."
				aAdd(aBrCoUm, {(cAliasNNX)->NNX_UMORIG,(cAliasNNX)->NNX_OPERA,(cAliasNNX)->NNX_FATOR," = ",nQtdCo,(cAliasNNX)->NNX_UMDEST})

				(cAliasNNX)->(DbSkip())
			EndDo
		Else
			MsgStop("UM: "+cGetUm+" Não encontrada na Tabela de Conversão de UM."+CRLF+;
			"Favor realizar o cadastro do mesmo na Rotina AGRA060() ou clique em Incluir!")
			aAdd(aBrCoUm, {"","",0," = ",0,""})        
		EndIf
		(cAliasNNX)->(DbCloseArea())

		oBrCoUm:SetArray(aBrCoUm)
		oBrCoUm:bLine := {|| {aBrCoUm[oBrCoUm:nAt,1],aBrCoUm[oBrCoUm:nAt,2],;
		Transform(aBrCoUm[oBrCoUm:nAt,3],"@E 999,999.999999"),aBrCoUm[oBrCoUm:nAt,4],;
		Transform(aBrCoUm[oBrCoUm:nAt,5],"@E 999,999,999,999.99"),aBrCoUm[oBrCoUm:nAt,6]}}
		oBrCoUm:bLDblClick := {|| IIF(MsgYesNo("Deseja continuar com esta conversão?"),;
		(lConfirm := .T., aConvert := aBrCoUm[oBrCoUm:nAt], oDlgCoUm:End()),Nil)}
		oBrCoUm:nScrollType := 1
		oBrCoUm:Refresh()

	EndIf

	RestArea(aArea)

Return


//===========================================
//VALIDAÇÃO DOS CAMPOS OBRIGATÓRIOS         =
//INCLUSÃO - TABELALA DE CONVERSÃO DE UM    =
//===========================================
Static Function XMLUMINCV(nOpcX)

	Local lRetorno := .T.

	If nOpcX == 3 .OR. nOpcX == 4
		lRetorno := Obrigatorio(aGets,aTela)
	EndIf

Return lRetorno


//============================================
//PROGRAMA DE MANUTENÇÃO DE FORNECEDORES     =
//DIVERGENCIA/CADASTRAMENTO                  =
//============================================
Static Function XMLDIVFOR()

	Local aAreaDiv		:= GetArea()
	Local nX
	Local aColsSA2 		:= {}
	Local aFieldFill 	:= {}
	Local aFieldsSA2	:= {"A2_LOJA","A2_NOME","A2_NREDUZ","A2_NATUREZ","A2_END","A2_NR_END","A2_BAIRRO","A2_EST","A2_COD_MUN","A2_MUN","A2_CEP","A2_TIPO","A2_GRPTRIB","A2_CGC","A2_DDI","A2_DDD","A2_TEL","A2_FAX","A2_INSCR","A2_INSCRM"}
	Local aAlterSA2 	:= {"A2_LOJA","A2_NOME","A2_NREDUZ","A2_NATUREZ","A2_END","A2_NR_END","A2_BAIRRO","A2_EST","A2_COD_MUN","A2_MUN","A2_CEP","A2_TIPO","A2_GRPTRIB","A2_CGC","A2_DDI","A2_DDD","A2_TEL","A2_FAX","A2_INSCR","A2_INSCRM"}
	Local oDadosSA2
	Local aButtons 		:= {}
	Local oDlgDivFor
	Local lConfirm		:= .F.
	Local aFiles		
	Local cError
	Local cWarning
	Local oXml
	Local lLoop			:= .F.
	Local oFont1 		:= TFont():New("MS Sans Serif",,020,,.F.,,,,,.F.,.F.)    

	Private aHeaderSA2 	:= {}
	Private lMsErroAuto := .F.

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))

	//REUNINDO TODOS FORNECEDORES/ARQUIVOS XML COM DIVERGENCIA
	aFiles := Directory(cDirDivFor+"*.xml", "D") 
	If Empty(aFiles)
		MsgStop("Não exitem Notas Fiscais com divergência de Fornecedor(Nf.Div/Fornece) no momento!")
		RestArea(aAreaDiv)
		Return
	EndIf

	For i := 1 To Len(aFiles)

		cError 	 := ""
		cWarning := ""

		oXml := XmlParser(MemoRead(cDirDivFor+aFiles[i,1]),"_",@cError,@cWarning)

		//=============================================================================================
		//CONTROLE DE ERRO DE LEITURA DO ARQUIVO XML
		If !Empty(cError)
			Return
		EndIf
		//=============================================================================================

		cSequen := 0

		//XML - NFE		
		If XmlChildEx(oXml, "_NFEPROC") != Nil

			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_DEST,"_CNPJ") != Nil
				If oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == '05725071000175' //SM0->M0_CGC - VAREJO 0101
					cFilXml := '0101'
				ElseIf oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == '05725071000256' //SM0->M0_CGC - ATACADO 0102
					cFilXml := '0102'
				Else
					Loop
				EndIf
			Else
				Loop
			EndIf

			/*
			lLoop := .F.
			For nX := 1 To Len(aColsSA2)
			If AllTrim(aColsSA2[nX,FG_POSVAR("A2_CGC","aHeaderSA2")]) == AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
			lLoop := .T.
			Exit
			EndIf
			Next nX
			If lLoop
			Loop
			EndIf
			*/

			cA2_NOME 	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT)
			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT, "_XFANT") != Nil
				cA2_NREDUZ := Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XFANT:TEXT) 
			Else
				cA2_NREDUZ := Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT)
			EndIf
			cA2_NATUREZ := "203001"
			cA2_END		:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT)
			cA2_NR_END	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT)
			cA2_BAIRRO	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT)
			cA2_EST		:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT)
			cA2_COD_MUN := Posicione("CC2",4,xFilial("CC2")+cA2_EST+Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT),"CC2_CODMUN")
			//cA2_COD_MUN	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT)
			cA2_MUN		:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT)
			cA2_CEP		:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT)
			cA2_CGC 	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
			If SA2->(DbSeek(xFilial("SA2")+cA2_CGC))
				Loop
			EndIf
			cA2_TIPO	:= IIF(Len(cA2_CGC) == 14, "J", "F")
			cA2_GRPTRIB := CriaVar("A2_GRPTRIB")
			cA2_DDI		:= "55"
			cA2_DDD		:= CriaVar("A2_DDD")
			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT, "_FONE") != Nil
				cA2_TEL	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT)
				cA2_FAX	:= Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT)
			Else
				cA2_TEL	:= CriaVar("A2_TEL")
				cA2_FAX := CriaVar("A2_FAX")
			EndIf
			If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT, "_IE") != Nil
				cA2_INSCR := Upper(oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT)	
			Else
				cPara := ""
			EndIf
			cA2_INSCRM := CriaVar("A2_INSCRM")

			aFieldFill := {}

			aAdd(aFieldFill, "01") 			//A2_LOJA
			aAdd(aFieldFill, SubStr(cA2_NOME,1,TamSx3("A2_NOME")[1])) 		//A2_NOME
			aAdd(aFieldFill, SubStr(cA2_NREDUZ,1,TamSx3("A2_NREDUZ")[1])) 	//A2_NREDUZ
			aAdd(aFieldFill, cA2_NATUREZ)									//NATUREZA
			aAdd(aFieldFill, SubStr(cA2_END,1,TamSx3("A2_END")[1])) 		//A2_END
			aAdd(aFieldFill, SubStr(cA2_NR_END,1,TamSx3("A2_NR_END")[1])) 	//A2_NR_END
			aAdd(aFieldFill, SubStr(cA2_BAIRRO,1,TamSx3("A2_BAIRRO")[1])) 	//A2_BAIRRO
			aAdd(aFieldFill, cA2_EST) 		//A2_EST
			aAdd(aFieldFill, cA2_COD_MUN) 	//A2_COD_MUN
			aAdd(aFieldFill, cA2_MUN) 		//A2_MUN
			aAdd(aFieldFill, cA2_CEP) 		//A2_CEP
			aAdd(aFieldFill, cA2_TIPO) 		//A2_TIPO
			aAdd(aFieldFill, cA2_GRPTRIB)   //A2_GRPTRIB
			aAdd(aFieldFill, cA2_CGC) 		//A2_CGC
			aAdd(aFieldFill, cA2_DDI) 		//A2_DDI
			aAdd(aFieldFill, cA2_DDD) 		//A2_DDD
			aAdd(aFieldFill, cA2_TEL) 		//A2_TEL
			aAdd(aFieldFill, cA2_FAX) 		//A2_FAX
			aAdd(aFieldFill, cA2_INSCR) 	//A2_INSCR
			aAdd(aFieldFill, cA2_INSCRM) 	//A2_INSCRM

			aAdd(aFieldFill, aFiles[i,1])	//NOME DO ARQUIVO
			aAdd(aFieldFill, .F.)
			aAdd(aColsSA2, aFieldFill)


			//===============
			//XML - CTE     =
			//===============
		ElseIf XmlChildEx(oXml, "_CTEPROC") != Nil

			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_DEST,"_CNPJ") != Nil
				If oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT == '05725071000175' //SM0->M0_CGC - VAREJO 0101
					cFilXml := '0101'
				ElseIf oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT == '05725071000256' //SM0->M0_CGC - ATACADO 0102
					cFilXml := '0102'
				Else
					Loop                                                              
				EndIf
			Else
				Loop
			EndIf

			/*
			lLoop := .F.
			For nX := 1 To Len(aColsSA2)
			If AllTrim(aColsSA2[nX,FG_POSVAR("A2_CGC","aHeaderSA2")]) == AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT)
			lLoop := .T.
			Exit
			EndIf
			Next nX
			If lLoop
			Loop
			EndIf
			*/

			cA2_NOME 	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)
			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT, "_XFANT") != Nil
				cA2_NREDUZ := Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XFANT:TEXT) 
			Else
				cA2_NREDUZ := Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)
			EndIf
			cA2_NATUREZ := "203001"
			cA2_END		:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XLGR:TEXT)
			cA2_NR_END	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_NRO:TEXT)
			cA2_BAIRRO	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT)
			cA2_EST		:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT)
			cA2_COD_MUN := Posicione("CC2",4,xFilial("CC2")+cA2_EST+Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XMUN:TEXT),"CC2_CODMUN")
			//cA2_COD_MUN	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CMUN:TEXT)
			cA2_MUN		:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XMUN:TEXT)
			cA2_CEP		:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CEP:TEXT)
			cA2_CGC 	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT)
			If SA2->(DbSeek(xFilial("SA2")+cA2_CGC))
				Loop
			EndIf
			cA2_TIPO	:= IIF(Len(cA2_CGC) == 14, "J", "F")
			cA2_GRPTRIB := CriaVar("A2_GRPTRIB")
			cA2_DDI		:= "55"
			cA2_DDD		:= CriaVar("A2_DDD")
			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT, "_FONE") != Nil
				cA2_TEL	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_FONE:TEXT)
				cA2_FAX	:= Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_FONE:TEXT)
			Else
				cA2_TEL	:= CriaVar("A2_TEL")
				cA2_FAX := CriaVar("A2_FAX")
			EndIf
			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT, "_IE") != Nil
				cA2_INSCR := Upper(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_IE:TEXT)	
			Else
				cPara := ""
			EndIf
			cA2_INSCRM := CriaVar("A2_INSCRM")

			aFieldFill := {}

			aAdd(aFieldFill, "01") 			//A2_LOJA
			aAdd(aFieldFill, SubStr(cA2_NOME,1,TamSx3("A2_NOME")[1])) 		//A2_NOME
			aAdd(aFieldFill, SubStr(cA2_NREDUZ,1,TamSx3("A2_NREDUZ")[1])) 	//A2_NREDUZ
			aAdd(aFieldFill, cA2_NATUREZ)									//NATUREZA
			aAdd(aFieldFill, SubStr(cA2_END,1,TamSx3("A2_END")[1])) 		//A2_END
			aAdd(aFieldFill, SubStr(cA2_NR_END,1,TamSx3("A2_NR_END")[1])) 	//A2_NR_END
			aAdd(aFieldFill, SubStr(cA2_BAIRRO,1,TamSx3("A2_BAIRRO")[1])) 	//A2_BAIRRO
			aAdd(aFieldFill, cA2_EST) 		//A2_EST
			aAdd(aFieldFill, cA2_COD_MUN) 	//A2_COD_MUN
			aAdd(aFieldFill, cA2_MUN) 		//A2_MUN
			aAdd(aFieldFill, cA2_CEP) 		//A2_CEP
			aAdd(aFieldFill, cA2_TIPO) 		//A2_TIPO
			aAdd(aFieldFill, cA2_GRPTRIB)   //A2_GRPTRIB
			aAdd(aFieldFill, cA2_CGC) 		//A2_CGC
			aAdd(aFieldFill, cA2_DDI) 		//A2_DDI
			aAdd(aFieldFill, cA2_DDD) 		//A2_DDD
			aAdd(aFieldFill, cA2_TEL) 		//A2_TEL
			aAdd(aFieldFill, cA2_FAX) 		//A2_FAX
			aAdd(aFieldFill, cA2_INSCR) 	//A2_INSCR
			aAdd(aFieldFill, cA2_INSCRM) 	//A2_INSCRM

			aAdd(aFieldFill, aFiles[i,1])	//NOME DO ARQUIVO
			aAdd(aFieldFill, .F.)
			aAdd(aColsSA2, aFieldFill)

		EndIf

		oXml := Nil

	Next i

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFieldsSA2)
		If SX3->(DbSeek(aFieldsSA2[nX]))
			If AllTrim(SX3->X3_CAMPO) $ "A2_EST/A2_COD_MUN"
				aAdd(aHeaderSA2, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"u_CPOXSA2()",;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})					
			Else
				aAdd(aHeaderSA2, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			EndIf
		Endif
	Next nX

	aAdd(aHeaderSA2, {"Nome Arquivo","LOCARQ","@#",50,0,"","","C","","R","",""})

	/*
	For nX := 1 to Len(aFieldsSA2)
	If DbSeek(aFieldsSA2[nX])
	aAdd(aFieldFill, CriaVar(SX3->X3_CAMPO))
	Endif
	Next nX
	aAdd(aFieldFill, .F.)
	aAdd(aColsSA2, aFieldFill)
	*/

	DEFINE MSDIALOG oDlgDivFor TITLE "Divergência Fornecedor - Cadastro" FROM 000, 000  TO 603, 1349 COLORS 0, 16777215 PIXEL

	oDadosSA2 := MsNewGetDados():New(030,002,285,672,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterSA2,,Len(aColsSA2),"AllwaysTrue","","AllwaysTrue",oDlgDivFor,aHeaderSA2,aColsSA2)

	@ 289, 002 SAY oSay1 PROMPT "Delete a linha(fornecedor) para que não seja cadastrado no sitema" SIZE 279, 012 OF oDlgDivFor FONT oFont1 COLORS 255, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlgDivFor CENTERED ON INIT (EnchoiceBar(oDlgDivFor,{|| IIF(TUDOOKDIV(), (lConfirm := .T., oDlgDivFor:End()), Nil)},{|| oDlgDivFor:End()},,@aButtons))

	//CADASTRA FORNECEDOR
	If lConfirm

		For i := 1 To Len(oDadosSA2:aCols)

			//{"A2_LOJA","A2_NOME","A2_NREDUZ","A2_END","A2_NR_END","A2_BAIRRO","A2_EST","A2_COD_MUN","A2_MUN","A2_CEP","A2_TIPO",;
			//"A2_CGC","A2_DDI","A2_DDD","A2_TEL","A2_FAX","A2_INSCR","A2_INSCRM"}
			//aAdd(aFornece, {"A2_COD"	,cCod,})
			If !oDadosSA2:aCols[i,Len(oDadosSA2:aCols[i])]

				If SA2->(DbSeek(xFilial("SA2")+oDadosSA2:aCols[i,FG_POSVAR("A2_CGC","aHeaderSA2")]))
					//============================================================================
					//REMOVENDO ARQUIVO DE cDirDivFor PARA cPatch APÓS O CADASTRO DO FORNECEDOR  =
					//============================================================================
					cLocOrig := ""
					cLocDest := ""

					cLocOrig := cDirDivFor + oDadosSA2:aCols[i,FG_POSVAR("LOCARQ","aHeaderSA2")]
					cLocDest := cPatch + oDadosSA2:aCols[i,FG_POSVAR("LOCARQ","aHeaderSA2")]
					nStatusDir := fRename(cLocOrig,cLocDest)

					If nStatusDir < 0
						MsgInfo("Num erro FError(): "+cValToChar(FError()))
					EndIf
					//=============================================================================
					Loop
				EndIf

				Begin Transaction 		

					aFornece := {}

					aAdd(aFornece, {"A2_LOJA"		,oDadosSA2:aCols[i,FG_POSVAR("A2_LOJA"		,"aHeaderSA2")],Nil})	
					aAdd(aFornece, {"A2_NOME"		,oDadosSA2:aCols[i,FG_POSVAR("A2_NOME"		,"aHeaderSA2")],Nil})	
					aAdd(aFornece, {"A2_NREDUZ"		,oDadosSA2:aCols[i,FG_POSVAR("A2_NREDUZ"	,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_NATUREZ"    ,oDadosSA2:aCols[i,FG_POSVAR("A2_NATUREZ"	,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_END"		,oDadosSA2:aCols[i,FG_POSVAR("A2_END"		,"aHeaderSA2")],Nil})	
					aAdd(aFornece, {"A2_NR_END"		,oDadosSA2:aCols[i,FG_POSVAR("A2_NR_END"	,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_BAIRRO"		,oDadosSA2:aCols[i,FG_POSVAR("A2_BAIRRO"	,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_EST"		,oDadosSA2:aCols[i,FG_POSVAR("A2_EST"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_COD_MUN"	,oDadosSA2:aCols[i,FG_POSVAR("A2_COD_MUN"	,"aHeaderSA2")],Nil}) //Vazio() .Or. ExistCpo("CC2",xFilial("CC2")+M->A2_EST+M->A2_COD_MUN)
					aAdd(aFornece, {"A2_MUN"		,oDadosSA2:aCols[i,FG_POSVAR("A2_MUN"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_CEP"		,oDadosSA2:aCols[i,FG_POSVAR("A2_CEP"		,"aHeaderSA2")],Nil})	
					aAdd(aFornece, {"A2_TIPO"		,oDadosSA2:aCols[i,FG_POSVAR("A2_TIPO"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_GRPTRIB"	,oDadosSA2:aCols[i,FG_POSVAR("A2_GRPTRIB"	,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_CGC"		,oDadosSA2:aCols[i,FG_POSVAR("A2_CGC"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_DDI"		,oDadosSA2:aCols[i,FG_POSVAR("A2_DDI"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_DDD"		,oDadosSA2:aCols[i,FG_POSVAR("A2_DDD"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_TEL"		,oDadosSA2:aCols[i,FG_POSVAR("A2_TEL"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_FAX"		,oDadosSA2:aCols[i,FG_POSVAR("A2_FAX"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_INSCR"		,oDadosSA2:aCols[i,FG_POSVAR("A2_INSCR"		,"aHeaderSA2")],Nil})
					aAdd(aFornece, {"A2_INSCRM"		,oDadosSA2:aCols[i,FG_POSVAR("A2_INSCRM"	,"aHeaderSA2")],Nil})

					//MANUAL
					aAdd(aFornece, {"A2_CODPAIS"	,"01058",Nil}) //01058 - BRASIL
					aAdd(aFornece, {"A2_PAIS"	    ,"105"  ,Nil}) //105 - BRASIL

					DbSelectArea("CC2")
					CC2->(DbSetOrder(1))
					M->A2_EST := oDadosSA2:aCols[i,FG_POSVAR("A2_EST","aHeaderSA2")]
					M->A2_COD_MUN := oDadosSA2:aCols[i,FG_POSVAR("A2_COD_MUN","aHeaderSA2")]
					If !CC2->(DbSeek(xFilial("CC2")+M->A2_EST+M->A2_COD_MUN))
						MsgStop("Algo de errado no codigo/municipio, favor rever!")
						Return
					EndIf

					lMsErroAuto := .F.
					MsgRun("Cadastrando Fornecedor ["+aFornece[3,2]+"] Aguarde...","Processando",{|| MSExecAuto({|x,y| MATA020(x,y)},aFornece,3)})		

					If !lMsErroAuto
						MsgInfo("       Cadastro Realizado com Sucesso!"+CRLF+CRLF+;
						"Cod. Fornecedor: "+SA2->A2_COD+CRLF+;
						"Nome Fornecedor: "+SA2->A2_NOME)	

						//============================================================================
						//REMOVENDO ARQUIVO DE cDirDivFor PARA cPatch APÓS O CADASTRO DO FORNECEDOR  =
						//============================================================================
						cLocOrig := ""
						cLocDest := ""

						cLocOrig := cDirDivFor + oDadosSA2:aCols[i,FG_POSVAR("LOCARQ","aHeaderSA2")]
						cLocDest := cPatch + oDadosSA2:aCols[i,FG_POSVAR("LOCARQ","aHeaderSA2")]
						nStatusDir := fRename(cLocOrig,cLocDest)

						If nStatusDir < 0
							MsgInfo("Num erro FError(): "+cValToChar(FError()))
						EndIf
						//=============================================================================

					Else		
						MostraErro()
						DisarmTransaction()
					EndIf

				End Transaction

			EndIf

		Next i

		oProcess := MsNewProcess():New({|| XML02ATU()},"Lendo Arquivos XML...","Aguarde...",.F.)
		oProcess:Activate()

	EndIf

	RestArea(aAreaDiv)

Return
User Function CPOXSA2()

	Local lRet := .T.

Return lRet

//========================================
//VALIDAÇÃO DA CONFIRMAÇÃO DA XMLDIVFOR  =
//========================================
Static Function TUDOOKDIV()

	Local lRet := .T.

	If !MsgYesNo("Deseja Continuar?"+CRLF+CRLF+;
	"Todos os registros não deletados serão cadastrado no sistema!")
		lRet := .F.
	EndIf

Return lRet


//========================================
//ENVIA E-MAIL                           =
//========================================
Static Function ENVMAIL(cNotaFiscal)

	Local oServer 	:= Nil
	Local oMessage 	:= Nil
	Local nSMTPTime := 60 // Timeout SMTP
	Local cFrom		:= ''
	Local cPass 	:= ''
	Local cPopAddr	:= ''
	Local cPOPPort 	:= ''
	Local cSMTPAddr	:= ''
	Local cSMTPPort := ''
	Local lSSL		:= .F.
	Local lTLS		:= .F.
	Local cTo				
	Local cCc       
	Local cSubject	:= ''

	cFrom 		:= 'no-reply@jaracatiapecas.com.br'                         
	cPass 		:= 'APjl0695'            
	cPopAddr 	:= 'mail.jaracatiapecas.com.br'                        
	cPOPPort 	:= 110
	cSMTPAddr 	:= 'mail.jaracatiapecas.com.br'                        
	cSMTPPort 	:= 25
	lSSL 		:= .F.
	lTLs 		:= .F.

	oServer := tMailManager():New()

	// Usa SSL na conexao
	//oServer:setUseSSL(.T.)
	oServer:setUseSSL(lSSL)
	oServer:SetUseTLS(lTLs)

	// Inicializa
	oServer:init("",alltrim(cSMTPAddr), alltrim(cFrom), Alltrim(cPass),cPOPPort,cSMTPPort)
	// Define o Timeout SMTP
	If oServer:SetSMTPTimeout(nSMTPTime) != 0
		return .F.
	endif

	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	if nErr <> 0
		oServer:smtpDisconnect()
		return .F.
	endif

	// Realiza autenticacao no servidor
	nErr := oServer:smtpAuth(AllTrim(cFrom), AllTrim(cPass))
	If nErr <> 0
		oServer:smtpDisconnect()
		return .F.
	Endif

	// Cria uma nova mensagem (TMailMessage)
	oMessage 			:= tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom 		:= cFrom  

	//TESTE
	//cCc := 'maycon.bianchine@hotmail.com'
	cTo := 'fiscal@jaracatiapecas.com.br'
	oMessage:cTo := cTo

	cAssunto := "Pré-Nota Gerada com sucesso. Nf encontra-se disponível para Classificação."

	oMessage:cSubject 	:= cAssunto
	oMessage:cBody 		:= CRIABODY(cNotaFiscal)

	//Envia a mensagem
	nErr := oMessage:send(oServer)
	if nErr <> 0
		oServer:smtpDisconnect()
		return .F.
	Else	
		ConOut('E-mail enviado com sucesso!')
	Endif

	// Disconecta do Servidor
	oServer:smtpDisconnect()

Return
//===========================
//CRIA CORPO DO E-MAIL      =
//===========================
Static Function CRIABODY(cNotaFiscal)

	Local cEnt	:= Chr(10)+ Chr(13)
	Local cBody

	cBody := '<table border="1" cellpadding="0" cellspacing="0" width="60%">'+cEnt
	cBody += '	<tr>'+cEnt
	cBody += '		<td>'+cEnt
	cBody += '			Nota Fiscal: '+cValToChar(cNotaFiscal)+''+cEnt
	cBody += '		</td>'+cEnt
	cBody += '	</tr>'+cEnt
	cBody += '	<tr>'+cEnt
	cBody += '		<td>'+cEnt
	cBody += '			Usuário: '+cValToChar(cUserName)+''+cEnt
	cBody += '		</td>'+cEnt
	cBody += '	</tr>'+cEnt
	cBody += '	<tr>'+cEnt
	cBody += '		<td>'+cEnt
	cBody += '			Data/Hora: '+cValToChar(dDataBase)+' - '+Time()+''+cEnt
	cBody += '		</td>'+cEnt
	cBody += '	</tr>'+cEnt
	cBody += '</table>'+cEnt

Return cBody


//=============================================
//VISUALIZADOR DE XML EM FORMATO DE ARVORE    =
//=============================================
Static Function XMLTREE()

	Local cFile
	Local oXmlTree
	Local oDlgTree
	Local oBtClose

	SZX->(DbGoTo(aGetXml[oGetXml:nAt,Len(aGetXml[oGetXml:nAt])]))

	cFile := cDirDest+SZX->ZX_CHVNFE+".xml"

	DEFINE MSDIALOG oDlgTree TITLE "Arvore do XML - "+SZX->ZX_CHVNFE+".xml" FROM 000, 000  TO 603, 1349 COLORS 0, 16777215 PIXEL

	oXmlTree := TXMLViewer():New(002,002,oDlgTree,cFile,673,280,.T.)

	If oXmlTree:setXML(cFile)
		MsgAlert("Arquivo não encontrado")
	EndIf

	@ 285, 636 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlgTree ACTION oDlgTree:End() PIXEL 

	ACTIVATE MSDIALOG oDlgTree CENTERED

Return


//===========================================================================
//CRIA VARIAVEL COM CONTEUDO DO XML PARA GRAVAR NO CAMPO XML MEMO DA SZX    =
//===========================================================================
Static function GRVMOMOXML(cFile)

	Local cArquivo := ""

	FT_FUSE(cFile)
	FT_FGOTOP()
	While !FT_FEOF()

		cArquivo += FT_FREADLN()

		FT_FSKIP()
	EndDo

	FT_FUSE()

Return cArquivo


//===================================================
//VOLTA A NOTA FISCAL PARA STATUS ZX_ENTRADA = .F.  =
//===================================================
Static Function XMLVOLTA()

	Local cSqlVolt
	Local cAliasVolt
	Local oBtClose
	Local oBtOk
	Local oDlgVolta
	Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Local oBrVolta
	Local aBrVolta 	:= {}
	Local lVolta	:= .F.
	Local i

	If Pergunte("XMLVOLTA", .T.)

		cAliasVolt := GetNextAlias()
		cSqlVolt := "SELECT SZX.R_E_C_N_O_ AS RECNOSZX "+CRLF
		cSqlVolt += "FROM "+RetSqlName("SZX")+" SZX "+CRLF
		cSqlVolt += "WHERE "+CRLF
		cSqlVolt += "      SZX.ZX_DOC        BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'       AND "+CRLF
		cSqlVolt += "      SZX.ZX_SERIE      BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'       AND "+CRLF
		cSqlVolt += "      SZX.ZX_FORNECE    BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'       AND "+CRLF
		cSqlVolt += "      SZX.ZX_LOJA       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'       AND "+CRLF
		cSqlVolt += "      SZX.ZX_TIPOXML    = '"+IIF(cTpNfota == "NF-e","NFE  ","CTE  ")+"' AND "+CRLF
		cSqlVolt += "      SZX.ZX_ENTRADA    = 'T'                                           AND "+CRLF
		cSqlVolt += "      SZX.D_E_L_E_T_    = ''"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlVolt),cAliasVolt,.T.,.F.)

		(cAliasVolt)->(DbGoTop())

		If !(cAliasVolt)->(Eof())
			While !(cAliasVolt)->(Eof())

				SZX->(DbGoTo((cAliasVolt)->RECNOSZX))

				aAdd(aBrVolta,{.F.,SZX->ZX_FILIAL,SZX->ZX_DOC,SZX->ZX_SERIE,;
				SZX->ZX_FORNECE,SZX->ZX_LOJA,SZX->ZX_NOMEFOR,SZX->ZX_VALBRUT,;
				(cAliasVolt)->RECNOSZX})

				(cAliasVolt)->(DbSkip())
			EndDo
		Else
			(cAliasVolt)->(DbCloseArea())
			Return
		EndIf
		(cAliasVolt)->(DbCloseArea())

		DEFINE MSDIALOG oDlgVolta TITLE "Voltando Status da Nota Fiscal" FROM 000, 000  TO 300, 1000 COLORS 0, 16777215 PIXEL

		oBrVolta := TWBrowse():New(002, 002,497, 130,,{"","Filial","Doc","Serie","Fornecedor","Loja","Nome","Valor"},{},oDlgVolta,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oBrVolta:SetArray(aBrVolta)
		oBrVolta:bLine := {|| {If(aBrVolta[oBrVolta:nAT,1],oOk,oNo),;
		aBrVolta[oBrVolta:nAt,2],aBrVolta[oBrVolta:nAt,3],;
		aBrVolta[oBrVolta:nAt,4],aBrVolta[oBrVolta:nAt,5],;
		aBrVolta[oBrVolta:nAt,6],aBrVolta[oBrVolta:nAt,7],;
		aBrVolta[oBrVolta:nAt,8]}}
		oBrVolta:bLDblClick := {|| aBrVolta[oBrVolta:nAt,1] := !aBrVolta[oBrVolta:nAt,1],oBrVolta:DrawSelect()}

		@ 135, 418 BUTTON oBtOk PROMPT "Confirmar" SIZE 037, 012 OF oDlgVolta ACTION {lVolta := .T., oDlgVolta:End()} PIXEL
		@ 135, 460 BUTTON oBtClose PROMPT "Fechar" SIZE 037, 012 OF oDlgVolta ACTION oDlgVolta:End() PIXEL

		ACTIVATE MSDIALOG oDlgVolta CENTERED

		If lVolta
			For i := 1 To Len(aBrVolta)
				If aBrVolta[i,1]

					SZX->(DbGoTo(aBrVolta[i,Len(aBrVolta[i])]))

					RecLock("SZX", .F.)
					SZX->ZX_ENTRADA := .F.
					SZX->(MsUnLock())

				EndIf
			Next i			
		EndIf

		REFRESHXML()

	EndIf

Return


//===================================================
//ATUALIZA OS ITENS DA NOTA FISCAL DE ENTRADA/CTE	=
//===================================================
Static Function ATAUMATA116()

	Local cAliasSD1 := GetNextAlias()
	Local cSqlSD1 
	Local lMono

	cSqlSD1 := "SELECT SD1.R_E_C_N_O_ AS RECNOSD1 "+CRLF
	cSqlSD1 += "FROM "+RetSqlName("SD1")+" SD1 "+CRLF
	cSqlSD1 += "WHERE "+CRLF
	cSqlSD1 += "      SD1.D1_FILIAL  = '"+SZX->ZX_FILIAL+"'  AND "+CRLF
	cSqlSD1 += "      SD1.D1_FORNECE = '"+SZX->ZX_FORNECE+"' AND "+CRLF
	cSqlSD1 += "      SD1.D1_LOJA    = '"+SZX->ZX_LOJA+"'    AND "+CRLF
	cSqlSD1 += "	  SD1.D1_DOC     = '"+SZX->ZX_DOC+"'     AND "+CRLF
	cSqlSD1 += "	  SD1.D1_SERIE   = '"+SZX->ZX_SERIE+"'   AND "+CRLF
	cSqlSD1 += "	  SD1.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSD1),cAliasSD1,.T.,.F.)

	(cAliasSD1)->(DbGoTop())

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))

	While !(cAliasSD1)->(Eof())

		SD1->(DbGoTo((cAliasSD1)->RECNOSD1))

		lMono := u_PRODREAL(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI")) //CONSULTA O TIPO DE TRIBUTAÇÃO DO PRODUTO

		RecLock("SD1", .F.)
		SD1->D1_YPOSIPI := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI")
		SD1->D1_YCREPF  := IIF(lMono,"MONOFASICO","TRIBUTADO")
		SD1->D1_YCEST	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_CEST")
		SD1->D1_YORIGEM	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_ORIGEM")
		SD1->D1_YCLAFIS	:= Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_CLASFIS")
		SD1->D1_TES		:= IIF(lMono,"300","302")
		SD1->(MsUnLock())

		(cAliasSD1)->(DbSkip())
	EndDo
	(cAliasSD1)->(DbCloseArea())

Return


//=======================
//ATAUALIZA A SBZ		=
//=======================
Static Function ATUASBZ()

	Local aArea		:= GetArea()
	Local cCod 		:= SB1->B1_COD	
	Local cArm 		:= SB1->B1_LOCPAD
	Local cCustd 	:= SB1->B1_CUSTD
	Local cPicmret 	:= SB1->B1_PICMRET
	Local cIPI 		:= SB1->B1_IPI
	Local cClasfis 	:= SB1->B1_CLASFIS
	Local cOrigem 	:= SB1->B1_ORIGEM
	Local cGrtrib 	:= SB1->B1_GRTRIB
	Local cRastro 	:= SB1->B1_RASTRO
	Local cCodIte 	:= SB1->B1_CODITE 
	Local cFilSBZ

	DbSelectArea("SBZ")
	SBZ->(DbSetOrder(1))

	For i := 1 To 2

		DbSelectArea("SBZ")
		SBZ->(DbSetOrder(1))

		If i == 1
			cFilSBZ := "0101"
		ElseIf i == 2
			cFilSBZ := "0102"
		EndIf

		If DbSeek(cFilSBZ+cCod)

			RecLock("SBZ", .F.)
			SBZ->BZ_CUSTD 	:= cCustd
			SBZ->BZ_PICMRET := cPicmret
			SBZ->BZ_IPI 	:= cIPI
			SBZ->BZ_CLASFIS := cClasfis
			SBZ->BZ_ORIGEM 	:= cOrigem
			SBZ->BZ_GRTRIB 	:= cGrtrib
			SBZ->BZ_YCODITE := cCodIte
			SBZ->(MsUnlock())

		Else

			RecLock("SBZ", .T.)
			SBZ->BZ_FILIAL  := cFilSBZ    
			SBZ->BZ_COD 	:= cCod               
			SBZ->BZ_LOCPAD 	:= cArm
			SBZ->BZ_RASTRO 	:= cRastro
			SBZ->BZ_CUSTD 	:= cCustd
			SBZ->BZ_PICMRET := cPicmret 
			SBZ->BZ_IPI 	:= cIPI
			SBZ->BZ_CLASFIS := cClasfis
			SBZ->BZ_ORIGEM 	:= cOrigem
			SBZ->BZ_GRTRIB 	:= cGrtrib
			SBZ->BZ_YCODITE := cCodIte
			SBZ->(MsUnlock())

		EndIf

	Next i

	RestArea(aArea)

Return


//===========================================
//SEMI-AUTOMATIZAÇÃO DO CADASTRO DO PRODUTO	=
//===========================================
Static Function CHCADPROD()
	u_XML02SB1()
	CHANGEXML()
Return
