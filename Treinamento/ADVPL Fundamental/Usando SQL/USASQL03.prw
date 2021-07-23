#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:   01/07/2021

DESC:   Treinamento usando TCQUERY

AUTOR:  MAYCON A. BIANCHINE
*/

User Function USASQL03()

	Local cSqlSB1

	cSqlSB1 := "SELECT TOP 5 * " + CRLF
	cSqlSB1 += "FROM " + RetSqlName("SB1") + " SB1 " + CRLF
	cSqlSB1 += "WHERE " + CRLF
	cSqlSB1 += "      SB1.D_E_L_E_T_ = '' " + CRLF
	cSqlSB1 := ChangeQuery(cSqlSB1)

	TcQuery cSqlSB1 New Alias "QRY"

    QRY->(DbGoTop())

    
Return
