#Include "Protheus.ch"
#Include "Totvs.ch"

/*
DATA:

DESC:   EXEMPLO DE EXCAUTO - CADASTRO DE CLIENTE

AUTOR:
*/
User Function CADCLI01(nOpcao)

	Local aArea		:= GetArea()
	Local oDlgCli
	Local oCodigo
	Local cCodigo	:= Space(TamSx3("A1_COD")[1])
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oLoja
	Local cLoja		:= Space(TamSx3("A1_LOJA")[1])
	Local nPercAlt  := 50
	Local nPercLar  := 50
	Local aCoors    := FWGetDialogSize(oMainWnd)
	Local oLayer 	:= FWLayer():New()
	Local oPanel
	Local aTipo 	:= {"F=Cons.Final","L=Produtor Rural","R=Revendedor","S=Solidario","X=Exportacao"}
	Local cTipo		:= aTipo[1]
	Local oTipo
	Local oNome
	Local cNome		:= Space(TamSx3("A1_NOME")[1])
	Local oNomeRed
	Local cNomeRed	:= Space(TamSx3("A1_NREDUZ")[1])
	Local oEnd
	Local cEnd		:= Space(TamSx3("A1_END")[1])
	Local oBairro
	Local cBairro	:= Space(TamSx3("A1_BAIRRO")[1])
	Local oMun
	Local cMun		:= Space(TamSx3("A1_MUN")[1])
	Local oUf
	Local cUf		:= Space(TamSx3("A1_EST")[1])
	Local bOk 		:= {|| IIF(Cadastrar(nOpcao,cCodigo,cloja,cNome,cNomeRed,cTipo,cEnd,cBairro,cMun,cUf),oDlgCli:End(),Nil)}
	Local bCancel	:= {|| oDlgCli:End()}
	Local cTitCli

	If nOpcao == 3 // INCLUSÃO
		cTitCli := "Cadastro de Cliente - Inclusão"
	ElseIf nOpcao == 4 .OR. nOpcao == 5// ALTERAÇÃO e EXCLUSÂO

		If Select("SA1") > 0

			cCodigo  := SA1->A1_COD
			cLoja 	 := SA1->A1_LOJA
			cNome	 := SA1->A1_NOME
			cNomeRed := SA1->A1_NREDUZ
			cTipo	 := SA1->A1_TIPO
			cEnd	 := SA1->A1_END
			cBairro	 := SA1->A1_BAIRRO
			cMun	 := SA1->A1_MUN
			cUf	 	 := SA1->A1_EST

		EndIf

		If nOpcao == 4
			cTitCli := "Cadastro de Cliente - Alteração"
		Else
			cTitCli := "Cadastro de Cliente - Exclusão"
		EndIf

	EndIf

	DEFINE MSDIALOG oDlgCli FROM 000,000 TO aCoors[3] * (nPercAlt / 100), aCoors[4] * (nPercLar / 100) PIXEL TITLE cTitCli

	oLayer:Init(oDlgCli, .F., .T.)

	oLayer:AddLine("LINE01", 100, .F.)
	oLayer:AddCollumn("BOX01", 100, .F., "LINE01")
	oLayer:AddWindow("BOX01", "PANEL01", "Cadastro de Cliente", 100, .F., .F.,, "LINE01")
	oPanel := oLayer:GetWinPanel("BOX01", "PANEL01", "LINE01")

	@ 002, 002 SAY oSay1 PROMPT "Codigo Cliente" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oCodigo VAR cCodigo WHEN IIF(nOpcao==3,.T.,.F.) SIZE 060, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 002, 073 SAY oSay2 PROMPT "Loja" SIZE 031, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 010, 073 MSGET oLoja VAR cLoja WHEN IIF(nOpcao==3,.T.,.F.) SIZE 033, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 002, 116 SAY oSay3 PROMPT "Nome" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 010, 116 MSGET oNome VAR cNome SIZE 130, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 025, 117 SAY oSay4 PROMPT "Nome Fanyasia" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 032, 116 MSGET oNomeRed VAR cNomeRed SIZE 130, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 025, 002 SAY oSay5 PROMPT "Tipo" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 032, 002 MSCOMBOBOX oTipo VAR cTipo ITEMS aTipo SIZE 072, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 047, 002 SAY oSay6 PROMPT "Endereço" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 055, 002 MSGET oEnd VAR cEnd SIZE 104, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 047, 116 SAY oSay7 PROMPT "Bairro" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 055, 116 MSGET oBairro VAR cBairro SIZE 130, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 070, 002 SAY oSay8 PROMPT "Municipio" SIZE 044, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 077, 002 MSGET oMun VAR cMun SIZE 104, 010 OF oPanel COLORS 0, 16777215 PIXEL

	@ 070, 116 SAY oSay9 PROMPT "UF" SIZE 031, 007 OF oPanel COLORS 0, 16777215 PIXEL
	@ 077, 116 MSGET oUf VAR cUf SIZE 033, 010 OF oPanel COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlgCli ON INIT EnchoiceBar(oDlgCli, bOk , bCancel) CENTERED

	RestArea(aArea)

Return

Static Function Cadastrar(nOpcao,cCodigo,cloja,cNome,cNomeRed,cTipo,cEnd,cBairro,cMun,cUf)

	Local aSA1Auto	:= {}
	Local cMsg		:= ""
	Local lRet 		:= .F.

	Private lMsErroAuto := .F.

	//----------------------------------
	// Dados do Cliente
	//----------------------------------
	aAdd(aSA1Auto, {"A1_COD"     ,cCodigo           ,Nil})
	aAdd(aSA1Auto, {"A1_LOJA"    ,cLoja             ,Nil})
	aAdd(aSA1Auto, {"A1_NOME"    ,cNome    			,Nil})
	aAdd(aSA1Auto, {"A1_NREDUZ"  ,cNomeRed          ,Nil})
	aAdd(aSA1Auto, {"A1_TIPO"    ,SubStr(cTipo,1,1) ,Nil})
	aAdd(aSA1Auto, {"A1_END"     ,cEnd           	,Nil})
	aAdd(aSA1Auto, {"A1_BAIRRO"  ,cBairro           ,Nil})
	aAdd(aSA1Auto, {"A1_MUN"     ,cMun           	,Nil})
	aAdd(aSA1Auto, {"A1_EST"     ,cUf               ,Nil})

	//------------------------------------
	// Chamada para cadastrar o cliente.
	//------------------------------------
	If nOpcao == 3
		cMsg := "Cadastrando Cliente..."
	ElseIf nOpcao == 4
		cMsg := "Alterando Cliente..."
	ElseIf nOpcao == 5
		cMsg := "Excluindo Cliente..."
	EndIf

	FWMsgRun(, {|| MSExecAuto({|a,b| CRMA980(a,b)}, aSA1Auto, nOpcao) }, "Processando", cMsg)

	If lMsErroAuto
		MostraErro()
	Else
		If nOpcao == 3
			MsgInfo("Cliente Incluído com Sucesso!")
		ElseIf nOpcao == 4
			MsgInfo("Cliente Alterado com Sucesso!")
		ElseIf nOpcao == 5
			MsgInfo("Cliente Excluido com Sucesso!")
		EndIf
		lRet := .T.
	EndIf

Return lRet


User Function MA030ROT()

	Local aBt := {}

	aAdd(aBt, { "Incluir", " u_CADCLI01(3)", 0, 3 })
	aAdd(aBt, { "Alterar", " u_CADCLI01(4)", 0, 4 })
	aAdd(aBt, { "Excluir", " u_CADCLI01(5)", 0, 5 })
	aAdd(aRotina, {"Treinamento ADVPL", aBt, 0, 3 })

Return
