#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*

*/

User Function MBOR001()

	Local aArea := GetArea()

	If Pergunte("MBOR001", .T.)

		Begin Transaction

			//FWMsgRun(, {|| lOK := fMBOR001() }, "Processando", "Processando Bordero...")
			fMBOR001()

			If !lOK
				DisarmTransaction()
				Return
			EndIf

		End Transaction

	EndIf

	RestArea(aArea)

Return
Static Function fMBOR001()

	Local cSqlSE1
	Local cAliasSE1 := GetNextAlias()
	Local aBordero  := {}
	Local lRet      := .F.

	cSqlSE1 := "SELECT SE1.R_E_C_N_O_ AS RECNOSE1 " + CRLF
	cSqlSE1 += "FROM " + RetSqlName("SE1") + " SE1 " + CRLF
	cSqlSE1 += "WHERE "  + CRLF
	cSqlSE1 += "    SE1.E1_FILIAL = '" + MV_PAR01 + "  AND " + CRLF
	cSqlSE1 += "    SE1.E1_NUMBOR = '" + MV_PAR02 + "' AND " + CRLFD
	cSqlSE1 += "    SE1.D_E_L_E_T_= ''"
	cSqlSE1 := ChangeQuery(cSqlSE1)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSE1),cAliasSE1,.T.,.F.)

	(cAliasSE1)->(DbGoTop())

	If (cAliasSE1)->(Eof())

		aAdd(aBordero, {(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_TIPO,;
			(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_CLIENTE,(cAliasSE1)->E1_LOJA,(cAliasSE1)->RECNOSE1})

		(cAliasSE1)->(DbSkip())
	Else
		MsgStop("Nenhum Bordero Encontrado.")
	EndIf
	(cAliasSE1)->(DbCloseArea())


	//
	Local oDlgBor
	Local oOk := LoadBitmap( GetResources(), "LBOK")
	Local oNo := LoadBitmap( GetResources(), "LBNO")
	Local oBordero

	DEFINE MSDIALOG oDlgBor TITLE "Atualizaçãço de Bordero" FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL

	@ 002, 002 LISTBOX oBordero Fields HEADER "","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_NATUREZ      ","E1_CLIENTE","E1_LOJA","E1_EMISSAO","E1_VENCTO","E1_VENCREA","E1_NUMBOR","E1_VALOR","E1_SALDO" SIZE 495, 180 OF oDlgBor PIXEL ColSizes 50,50
	oBordero:SetArray(aBordero)
	oBordero:bLine := {|| {;
		If(aBordero[oBordero:nAT,1],oOk,oNo),;
			aBordero[oBordero:nAt,2],;
			aBordero[oBordero:nAt,3],;
			aBordero[oBordero:nAt,4],;
			aBordero[oBordero:nAt,5],;
			aBordero[oBordero:nAt,6],;
			aBordero[oBordero:nAt,7],;
			aBordero[oBordero:nAt,8],;
			aBordero[oBordero:nAt,9],;
			aBordero[oBordero:nAt,10],;
			aBordero[oBordero:nAt,11],;
			aBordero[oBordero:nAt,12],;
			aBordero[oBordero:nAt,13],;
			aBordero[oBordero:nAt,14];
			}}
		oBordero:bLDblClick := {|| aBordero[oBordero:nAt,1] := !aBordero[oBordero:nAt,1],oBordero:DrawSelect()}
		oBordero:nScrollType := 1

		ACTIVATE MSDIALOG oDlgBor CENTERED

		Return lRet
