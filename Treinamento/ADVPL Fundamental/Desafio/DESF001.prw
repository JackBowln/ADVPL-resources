#include "protheus.ch"

/*
DATA:	  

DESC:   

AUTOR:  
*/
User Function DESF001()

	Local nX            := 0
	Local nResultado    := 1
	Local nFator        := 5
	Local cMsg          := " "
	Local cTitulo       := "Resultado do Fatorial"

	Local cPerg         := "Qual resultado do Fatorial de 5 ?"
	Local cResposta

	cResposta := FWInputBox(cMsg,cPerg)

	For nX := nFator To 1 Step -1
		nResultado *= nFator
	Next nX

	//cMsg := "O Resultado do Fatorial de " + cValToChar(nFator) + " é: " + cValToChar(nResultado)
	//MsgInfo(cMsg,cTitulo)

	If cResposta == nResultado
		MsgInfo("Resultado Correto!")
	Else
		MsgStop("Resultado Errado!")
	EndIf

Return Nil


User function InputBox()

	Local cRetorno := ""
	Local nRetorno := 0

	cRetorno := FWInputBox("Informe o texto", "")

	MsgInfo(cRetorno)

	nRetorno := Val(FWInputBox("Escolha um numero [1-100]:", ""))

	MsgInfo( cValToChar(nRetorno) )

Return
