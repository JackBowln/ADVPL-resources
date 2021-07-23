#include "protheus.ch"

/*
DATA:   

DESC:   

AUTOR:
*/
User Function DESF002()

	Local aNumeros  := {1,2,3,4,5,6,7,8,9,10,11,12,13,45,40,56,80,90}
	Local nX        := 0

	for nX := 1 To  Len (aNumeros)

		Msginfo( "Numero " + cValToChar(aNumeros[nX]) + " é " + CalculaPar(aNumeros[nX]))

	Next nX 

Return

Static Function CalculaPar(cNum)
    
    Local cMsg := ""

    If Mod(cNUm,2) == 0
		cMsg := "Par"
	Else
		cMsg := "Impar"
	Endif

Return cMsg  
