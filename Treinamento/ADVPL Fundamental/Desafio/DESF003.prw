#include "protheus.ch"

/*
DATA:   30/06/2021

DESC:   VALIDAÇÃO DA SOMA DE DOIS NUMEROS

AUTOR:  MAYCON A. BIANCHINE
*/

User Function DESF003()

	Local nResultado := 0
	Local nNum1      := 0
	Local nNum2      := 0
	Local nSoma      := 0
	Local cPerg      := " "
	Local lPerg      := .T.

	While lPerg

		nNum1 := Randomize(1,100)
		nNum2 := Randomize(1,100)
		nSoma := nNum1 + nNum2
		cPerg := "Qual é o Resultadado da Seguinte Expressão? " + cValToChar(nNum1) + " + " + cValToChar(nNum2)

		nResultado := Val(FWInputBox(cPerg))

		If nResultado == nSoma

			MsgInfo("Resultado Correto!", "Resultado")

			MsgAlert("Resultado Correto!", "Resultado")

			MsgStop("Resultado Correto!", "Resultado")

		Else
			MsgStop("Resultado Errado!", "Resultado")
		EndIf

        lPerg := MsgYesNo("Deseja Inserir o Resultado Novamente?")

	EndDo

Return
