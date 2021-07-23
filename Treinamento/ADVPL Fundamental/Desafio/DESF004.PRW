#include "protheus.ch"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:   30/06/2021

DESC:   

AUTOR:  MAYCON A. BIANCHINE
*/
User Function DESF004()

	Local cPerg     := "informe o Cod do Produto, Quantidade e Valor neste formato: PPPPPPQQQVVV"
	Local cCod      := ""
	Local cPedido   := ""
	Local aPedido   := ""
	Local cQtd      := ""
	Local cValo     := ""
	Local nVtotal   := 0
	Local lPerg     := .T.
	Local aItem     := {}
    Local aRet

	While lPerg

		cCod := FwinputBox(cPerg)
		aPedido := STRTOKARR(cCod,";")

		If Len(aPedido) == 3

			cPedido := aPedido[1]
			cQtd    := val(aPedido[2])
			cValo   := val(aPedido[3])

			nVtotal := cQtd * cValo

			aAdd(aItem, aPedido)

			MsgInfo("Pedido: " + cPedido + CRLF + ;
				"Quantidade: " + cValToChar(cQtd) + CRLF + ;
				"Valor Un: " + cValToChar(cValo) + CRLF + ;
				"Valor total: " + cValToChar(nVtotal),"Pedido")

		Else
			MsgAlert("Dados invalidos")
		EndIf

		lPerg := MsgYesNo("Deseja inserir o resultado novamente? ")

	EndDo

	If !Empty(aItem)
		aRet := ExibParImp(aItem)

		MsgInfo("Numeros Pares: " + aRet[1] + CRLF + ;
			"Numeros Impares: " + aRet[2])

	EndIf

Return


Static Function ExibParImp(aItem)

	Local i
	Local cPares    := ""
	Local cImpares  := ""

	For i := 1 To Len(aItem)

		If Mod(Val(aItem[i,2]),2) == 0

			// é par
			cPares += aItem[i,2] + ", "

		Else

			// é impar
			cImpares += aItem[i,2] + ", "

		EndIf

	Next i

Return {cPares,cImpares}
