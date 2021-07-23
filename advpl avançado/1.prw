#include "protheus.ch"

User Function cadCli()

	local oDlg
	// Local lCadastra := .f.
	Local oSay1
	Local oCodigo
	Local cCodigo	:= Space(TamSx3("A1_COD")[1]) // tamanho 6
	Local oSay2
	Local oLoja
	Local cLoja		:= Space(TamSx3("A1_LOJA")[1]) 
	Local oSay3
	Local oNome
	Local cNome	:= Space(TamSx3("A1_NOME")[1]) 
	Local oSay4
	Local oEnd
	Local cEnd		:= Space(TamSx3("A1_END")[1]) 

	Local aComboTipo := {"F=Cons.Final", "L=Produtor Rural","R=Revendedor", "S=Solidario", "X=Exportacao"}
	Local cComboTipo

	Local oTipo
	Local cTipo	:= Space(TamSx3("A1_TIPO")[1]) 
	Local oSay5
	Local oNreduz
	Local cNreduz		:= Space(TamSx3("A1_NREDUZ")[1]) 
	Local oSay6
	Local oBairro
	Local cBairro		:= Space(TamSx3("A1_BAIRRO")[1]) 
	Local oSay7
	Local oEst
	Local cEst		:= Space(TamSx3("A1_EST")[1]) 
	Local oSay8
	Local oSay9
	Local oMun
	Local cMun		:= Space(TamSx3("A1_MUN")[1]) 

	Local bOk       := {| | Cadastrar(cCodigo, cLoja, CNome, cEnd, cTipo, cNreduz, cBairro, cEst, cMun)}
	Local bCancel   := {| | oDlg:end()}

	DEFINE MsDialog oDlg TITLE "CADASTRO DE CLIENTS" From 000, 000 to 500, 800 colors 0, 16777215 PIXEL

	@ 060, 002 MSGET oCodigo VAR cCodigo SIZE 030, 010 OF oDlg PIXEL
	oSay1 := TSay():New(050,002,{|| "Codigo do Cliente"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	@ 060, 055 MSGET oLoja VAR cLoja SIZE 030, 010 OF oDlg PIXEL
	oSay2 := TSay():New(050,055,{|| "Loja"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	@ 060, 95 MSGET onome VAR cnome SIZE 090, 010 OF oDlg PIXEL
	oSay3 := TSay():New(050,95,{|| "Nome"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	cComboTipo := aComboTipo[1]
	@ 060, 205 MSCOMBOBOX oTipo VAR cTipo ITEMS aComboTipo SIZE 060,10 OF oDlg PIXEL
	oSay5 := TSay():New(050,215,{|| "Tipo"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	@ 090, 002 MSGET oEnd VAR cEnd SIZE 90, 010 OF oDlg PIXEL
	oSay4 := TSay():New(80,002,{|| "Endereco"},oDlg,,,,,,.T.,,,044,007,,,,,,)


	@ 90, 135 MSGET oNreduz VAR cNreduz SIZE 90, 010 OF oDlg PIXEL
	oSay6 := TSay():New(80,135,{|| "Nome Fantasia"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	@ 120, 002 MSGET oBairro VAR cBairro SIZE 90, 010 OF oDlg PIXEL
	oSay7 := TSay():New(110,002,{|| "Bairro"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	@ 120, 110 MSGET oEst VAR cEst SIZE 30, 010 OF oDlg PIXEL
	oSay8 := TSay():New(110,110,{|| "Estado"},oDlg,,,,,,.T.,,,044,007,,,,,,)

	@ 120, 155 MSGET oMun VAR cMun SIZE 50, 010 OF oDlg PIXEL
	oSay9 := TSay():New(110,155,{|| "Município"},oDlg,,,,,,.T.,,,044,007,,,,,,)
	ACTIVATE MsDialog oDlg ON INIT enchoiceBar(oDlg, bOk, bCancel) CENTERED



Return

Static Function Cadastrar(cod, loja, nome, ende, tipo, nreduz, bairro, est, mun)

	Local aSA1Auto  := {}
	Local nOpcAuto  := 3 //MODEL_OPERATION_INSERT
	// Local lRet      := .T.

	Private lMsErroAuto := .F.
	Private lMsHelpAuto	:= .T.

	lRet := RpcSetEnv("99","01","Admin","")

	If lRet

		//----------------------------------
		// Dados do Cliente
		//----------------------------------
		aAdd(aSA1Auto, {"A1_COD"       ,cod            ,Nil})
		aAdd(aSA1Auto, {"A1_LOJA"      ,loja           ,Nil})
		aAdd(aSA1Auto, {"A1_NOME"      ,nome           ,Nil})
		aAdd(aSA1Auto, {"A1_NREDUZ"    ,nreduz         ,Nil})
		aAdd(aSA1Auto, {"A1_TIPO"      ,tipo           ,Nil})
		aAdd(aSA1Auto, {"A1_END"       ,ende           ,Nil})
		aAdd(aSA1Auto, {"A1_BAIRRO"    ,bairro         ,Nil})
		aAdd(aSA1Auto, {"A1_EST"       ,est            ,Nil})
		aAdd(aSA1Auto, {"A1_MUN"       ,mun            ,Nil})

		//------------------------------------
		// Chamada para cadastrar o cliente.
		//------------------------------------
		MSExecAuto({|a,b| CRMA980(a,b)}, aSA1Auto, nOpcAuto)

		If !lMsErroAuto
			MsgInfo("Cliente incluído com sucesso!")
		EndIf

	Else
		MsgStop("Não foi Possivel abrir o Ambiente.")
	EndIf

	RpcClearEnv()
return

