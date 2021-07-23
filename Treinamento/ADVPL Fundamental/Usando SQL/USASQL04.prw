#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:   01/07/2021

DESC:   Treinamento usando DbUseArea

AUTOR:  MAYCON A. BIANCHINE
*/

User Function USASQL04()

	Local cSqlSB2
	Local cAliasSB2 := GetNextAlias()
	Local aEstoque  := {}
	Local cDesc
	Local lSaldoZera:= GetMv("MV_SZERA",.F.,.F.)

	cSqlSB2 := "SELECT * " + CRLF
	cSqlSB2 += "FROM " + RetSqlName("SB2") + " SB2 " + CRLF
	cSqlSB2 += "WHERE " + CRLF
	cSqlSB2 += "      SB2.B2_FILIAL  = '" + xFilial("SB2") + "' AND " + CRLF
	If lSaldoZera
		cSqlSB2 += "      SB2.B2_QATU    > 0 AND " + CRLF
	EndIf
	cSqlSB2 += "      SB2.D_E_L_E_T_ = '' " + CRLF
	cSqlSB2 := ChangeQuery(cSqlSB2)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSB2),cAliasSB2,.T.,.T.)

	(cAliasSB2)->(DbGoTop()) //força posicionamento no primeiro registro da tabela temporaria

	If !(cAliasSB2)->(Eof()) //verifica se alias esta vazia

		While !(cAliasSB2)->(Eof()) //verifica se alias esta vazia

			//Adiciona dentro da Matriz cod e quantidade em estoque
			cDesc := Posicione("SB1",1,xFilial("SB1") + (cAliasSB2)->B2_COD, "B1_DESC")
			aAdd(aEstoque, {(cAliasSB2)->B2_COD,cDesc,(cAliasSB2)->B2_QATU})

			(cAliasSB2)->(DbSkip()) //posiciona no proximo registro da alias
		EndDo

	Else
		MsgStop("Tabela esta vazia!")
	EndIf
	(cAliasSB2)->(DbCloseArea()) //fecha a area de trabalho da alias

	If !Empty(aEstoque)
		ExibeTela(aEstoque)
	EndIf

    //

Return

Static Function ExibeTela(aEstoque)

	Local oEstoque
	Local aHeader   := {FWX3Titulo("B2_COD",FWX3Titulo("B2_QATU")}
	Local aTam      := {TamSX3("B2_COD")[1],TamSX3("B2_QATU")[1]}
	Local cTitle    := "Estoque Atual"
	Local oDlg

	DEFINE MSDIALOG oDlg TITLE cTitle FROM 000, 000 TO 500, 600 COLORS 0, 16777215 PIXEL

	oEstoque := TWBrowse():New(002,002,295,230,,aHeader,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oEstoque:SetArray(aEstoque)
	oEstoque:bLine := {|| {aEstoque[oEstoque:nAt,1],aEstoque[oEstoque:nAt,2]}}
	oEstoque:bLDblClick := {|| }
	oEstoque:Refresh()

	ACTIVATE MSDIALOG oDlg CENTERED

Return
