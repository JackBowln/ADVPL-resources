#include 'protheus.ch'

/*
DATA:   02/07/2021

DESC:   CADASTRO DE EMPRESTIMOS DE PRODUTOS

AUTOR:  MAYCON A BIANCHINE
*/

User Function ZE1001()

	Private cCadastro 	:= "Cadastro de Emprestimos de Produto"
	Private oBrowse 	:= Nil
	Private aRotina 	:= MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZE1")
	oBrowse:SetDescription(cCadastro)

	oBrowse:AddLegend("ZE1->ZE1_STATUS == '1'"  , "GREEN" ,"Pendente")
	oBrowse:AddLegend("ZE1->ZE1_STATUS == '2'"  , "BLACK" ,"Entregue")

	oBrowse:Activate()

Return


//======================
//CRIAÇÃO DOS MENUS    =
//======================
Static Function MenuDef()

	Local aRotina := {}
	Local aRot    := {}

	aAdd(aRotina, {"Incluir"		,"AxInclui"	,0,3})
	aAdd(aRotina, {"Alterar"		,"AxAltera"	,0,4})
	aAdd(aRotina, {"Excluir"		,"AxDeleta"	,0,5})
	aAdd(aRotina, {"Visualizar"	    ,"AxVisual"	,0,2})

	//Encerrando o Emprestimo
	aAdd(aRot, {"Encerrar Emprestimo"	    ,"u_ZE1001A(1)"	,0,4})
	aAdd(aRot, {"Encerrar Todos Emprestimos","u_ZE1001A(2)"	,0,4})
	aAdd(aRotina, {"Encerrar"	        ,aRot	,0,4})

	//Copia
	aAdd(aRotina, {"Copia"	            ,"u_ZE1001B()"	,0,4})

Return aRotina


//===============================
//ENCERRAMENTO DO EMPRESTIMO    =
//===============================
User Function ZE1001A(nOpcao)

	Local aArea := GetArea()

	If nOpcao == 1

		If MsgYesNo("Deseja Realmente Encerrar este Emprestimo?")

			RecLock("ZE1", .F.)
			ZE1->ZE1_SALDO  := 0
			ZE1->ZE1_STATUS := "2"
			//ZE1->ZE1_DTEN   := dDataBase
			ZE1->(MsUnLock())

		EndIf

	ElseIf nOpcao == 2

		If MsgYesNo("Deseja Realmente Encerrar Todos os Emprestimos?")

			DbSelectArea("ZE1")

			ZE1->(DbGoTop())

			While !ZE1->(Eof())

				If  ZE1->ZE1_STATUS == "1" .AND. ZE1->ZE1_SALDO > 0
					RecLock("ZE1", .F.)
					ZE1->ZE1_SALDO  := 0
					ZE1->ZE1_STATUS := "2"
					//ZE1->ZE1_DTEN   := dDataBase
					ZE1->(MsUnLock())
				EndIf

				ZE1->(DbSkip())
			EndDo
            
		EndIf

	EndIf

	RestArea(aArea)

Return


//===============================
//CRIA UMA COPIA DO EMPRESTIMO  =
//===============================
User Function ZE1001B()

	Local aArea         := GetArea()
	Local cZE1_FILIAL   := ZE1->ZE1_FILIAL
	Local cZE1_CODCLI   := ZE1->ZE1_CODCLI
	Local cZE1_LOJA     := ZE1->ZE1_LOJA
	Local cZE1_PRODUT   := ZE1->ZE1_PRODUT
	Local nZE1_QTD      := ZE1->ZE1_QTD

	If MsgYesNo("Deseja Realmente Copiar este Emprestimo?")

		RecLock("ZE1", .T.)
		ZE1->ZE1_FILIAL := cZE1_FILIAL
		ZE1->ZE1_STATUS := "1"
		ZE1->ZE1_COD    := GETSX8NUM("ZE1","ZE1_COD")
		ZE1->ZE1_CODCLI := cZE1_CODCLI
		ZE1->ZE1_LOJA   := cZE1_LOJA
		ZE1->ZE1_PRODUT := cZE1_PRODUT
		ZE1->ZE1_QTD    := nZE1_QTD
		ZE1->ZE1_SALDO  := nZE1_QTD
		ZE1->(MsUnLock())

		ConfirmSx8()

	EndIf

	RestArea(aArea)

Return
