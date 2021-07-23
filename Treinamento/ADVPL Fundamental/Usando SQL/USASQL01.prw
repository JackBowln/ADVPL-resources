#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:   01/07/2021

DESC:   Treinamento usando DbUseArea

AUTOR:  MAYCON A. BIANCHINE
*/

User Function USASQL01()

    Local cSqlSB1
    Local cAliasSB1 := GetNextAlias()

	cSqlSB1 := "SELECT TOP 5 * " + CRLF
	cSqlSB1 += "FROM " + RetSqlName("SB1") + " SB1 " + CRLF 
	cSqlSB1 += "WHERE " + CRLF 
	cSqlSB1 += "      SB1.D_E_L_E_T_ = '' " + CRLF
    cSqlSB1 := ChangeQuery(cSqlSB1)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlSB1),cAliasSB1,.T.,.T.)

    (cAliasSB1)->(DbGoTop()) //força posicionamento no primeiro registro da tabela temporaria

    If !(cAliasSB1)->(Eof()) //verifica se alias esta vazia
        
        While !(cAliasSB1)->(Eof()) //verifica se alias esta vazia

            // meus codigos
            MsgInfo("Passei pelo produto: " + (cAliasSB1)->B1_COD)

            (cAliasSB1)->(DbSkip()) //posiciona no proximo registro da alias
        EndDo

    Else
        MsgStop("Tabela esta vazia!")
    EndIf
    (cAliasSB1)->(DbCloseArea()) //fecha a area de trabalho da alias

Return
