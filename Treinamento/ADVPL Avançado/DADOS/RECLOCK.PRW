#Include "Protheus.ch"
#Include "Totvs.ch"

/*
DATA:

DESC:   EXEMPLIFICAÇÃO DE RECLOCK

AUTOR:
*/

//=======================
//INCLUSÃO DE REGISTRO  =
//=======================
User function EXC001()

	DbSelectArea("SA1")

	RecLock("SA1", .T.)
	SA1->A1_COD      := "XBX139"
	SA1->A1_LOJA     := "01"
    SA1->A1_NOME     := "USANDO RECLOCK"
    SA1->A1_NREDUZ   := "RECLOCK"
    SA1->A1_TIPO     := "F"
    SA1->A1_END      := "BRAZ LEME"
    SA1->A1_BAIRRO   := "CASA VERDE"
    SA1->A1_EST      := "SP"
	SA1->A1_MUN := "SÃO PAULO"
	SA1->(MsUnlock())

	MsgInfo("Cliente Cadastrado!")

Return


//=======================
//DELETAR REGISTRO      =
//=======================
User function EXEC002(cCodigo,cLoja)

	DEFAULT cCodigo := "XBX139"
	DEFAULT cLoja   := "01"

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	If SA1->(MsSeek(xFilial("SA1") + cCodigo + cLoja))

		RecLock("SA1", .F.)
		SA1->(DbDelete())
		SA1->(MsUnlock())

		MsgInfo("Cliente Deletado!")

	EndIf

Return


//=======================
//ALTERAÇÃO DE REGISTRO =
//=======================
User function EXEC003(cCodigo,cLoja)

	DEFAULT cCodigo := "XBX139"
	DEFAULT cLoja   := "01"

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	If SA1->(MsSeek(xFilial("SA1") + cCodigo + cLoja))

		RecLock("SA1", .F.)
		SA1->A1_EST := "ES"
		SA1->(MsUnlock())

		MsgInfo("Cliente Atualizado!")

	EndIF

Return
