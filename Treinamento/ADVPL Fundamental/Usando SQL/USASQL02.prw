#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:   01/07/2021

DESC:   Treinamento usando BeginSql

AUTOR:  MAYCON A. BIANCHINE
*/

User Function USASQL02()

	Local cAliasSB1 := GetNextAlias()
	Local lSaldoZera:= GetMv("MV_SZERA",.F.,.F.)

	IF lSaldoZera
		BeginSql Alias cAliasSB1
        
            SELECT TOP 5 * 
                FROM %Table:SB1% SB1 
                    WHERE 
                            SB1.%NotDel%      

        EndSql
	Else
		BeginSql Alias cAliasSB1
            
            SELECT TOP 5 * 
                FROM %Table:SB1% SB1 
                    WHERE 
                            SB1.%NotDel%

		EndSql
	EndIf



	(cAliasSB1)->(DbGoTop())

Return
