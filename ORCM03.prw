#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Orçamento"

/*
DATA:

DESC:

AUTOR:
*/
User Function ORCM03()

	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZE2")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("ORCM03")

	//Legendas
	oBrowse:AddLegend("ZE2->ZE2_STATUS == 'A'", "GREEN", "Aberto")
	oBrowse:AddLegend("ZE2->ZE2_STATUS == 'F'", "BLACK", "Faturado")
	oBrowse:AddLegend("ZE2->ZE2_STATUS == 'C'", "RED"  , "Cancelado")

	//Ativa a Browse
	oBrowse:Activate()

Return


//===================
//Definição do Menu =
//===================
Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ORCM03' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.ORCM03' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ORCM03' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.ORCM03' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina TITLE 'Faturar'    ACTION 'u_ORCM03F()'    OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Cancelar'   ACTION 'u_ORCM03C()'    OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4

Return aRotina


//===============================
//Criação do Modelo de Dados    =
//===============================
Static Function ModelDef()

	Local oModel
	Local oStZE2    := FWFormStruct(1, "ZE2")
	Local oStZE3    := FWFormStruct(1, "ZE3")
	Local aGatilhos := {}
	Local cFuncao
	Local i

	//Adicionando um gatilho, da estrutura oStZE2
	cFuncao := 'Posicione("SA1",1,xFilial("SA1") + FwFldGet("ZE2_CODCLI") + FwFldGet("ZE2_LOJA"), "A1_NOME")'
	aAdd(aGatilhos, FWStruTriggger("ZE2_LOJA","ZE2_NOMCLI",cFuncao,.F.,"",0,'',NIL,"01"))

	//Percorrendo os gatilhos e adicionando da estrutura oStZE2
	For i := 1 To Len(aGatilhos)
		oStZE2:AddTrigger(aGatilhos[i][01],aGatilhos[i][02],aGatilhos[i][03],aGatilhos[i][04])
	Next i

	//Adicionando um gatilho, da estrutura oStZE3
	aGatilhos := {}
	cFuncao := 'Posicione("SB1",1,xFilial("SB1") + FwFldGet("ZE3_PROD"), "B1_DESC")'
	aAdd(aGatilhos, FWStruTriggger("ZE3_PROD","ZE3_DESC",cFuncao,.F.,"",0,'',NIL,"01"))

	cFuncao := 'FwFldGet("ZE3_QTD") * FwFldGet("ZE3_PRECO")'
	aAdd(aGatilhos, FWStruTriggger("ZE3_QTD","ZE3_TOTAL",cFuncao,.F.,"",0,'',NIL,"01"))

	cFuncao := 'FwFldGet("ZE3_QTD") * FwFldGet("ZE3_PRECO")'
	aAdd(aGatilhos, FWStruTriggger("ZE3_PRECO","ZE3_TOTAL",cFuncao,.F.,"",0,'',NIL,"01"))

	cFuncao := 'ROUND((FwFldGet("ZE3_DESCON")/100) * (FwFldGet("ZE3_QTD") * FwFldGet("ZE3_PRECO")),2)'
	aAdd(aGatilhos, FWStruTriggger("ZE3_DESCON","ZE3_VLDESC",cFuncao,.F.,"",0,'',NIL,"01"))
	aAdd(aGatilhos, FWStruTriggger("ZE3_PRECO" ,"ZE3_VLDESC",cFuncao,.F.,"",0,'',NIL,"02"))
	aAdd(aGatilhos, FWStruTriggger("ZE3_QTD"   ,"ZE3_VLDESC",cFuncao,.F.,"",0,'',NIL,"02"))

	cFuncao := '(FwFldGet("ZE3_QTD") * FwFldGet("ZE3_PRECO")) - FwFldGet("ZE3_VLDESC")'
	aAdd(aGatilhos, FWStruTriggger("ZE3_QTD"   ,"ZE3_TOTAL",cFuncao,.F.,"",0,'',NIL,"03"))
	aAdd(aGatilhos, FWStruTriggger("ZE3_PRECO" ,"ZE3_TOTAL",cFuncao,.F.,"",0,'',NIL,"03"))
	aAdd(aGatilhos, FWStruTriggger("ZE3_VLDESC","ZE3_TOTAL",cFuncao,.F.,"",0,'',NIL,"01"))

	//Percorrendo os gatilhos e adicionando da estrutura oStZE3
	For i := 1 To Len(aGatilhos)
		oStZE3:AddTrigger(aGatilhos[i][01],aGatilhos[i][02],aGatilhos[i][03],aGatilhos[i][04])
	Next i

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("ORCM03M")

	//Montando nosso Formulario
	oModel:AddFields("ZE2MASTER", /*cOwner*/, oStZE2)

	//Montando nosso Grid
	oModel:AddGrid("ZE3DETAIL", "ZE2MASTER", oStZE3)

	//Criando a Relação entre as Tabelas ZE2 e ZE3
	oModel:SetRelation("ZE3DETAIL", {{"ZE3_FILIAL", "xFilial('ZE3')"}, {"ZE3_NUM", "ZE2_NUM"}}, ZE3->(IndexKey(1)))

	//Setando a Chave Primaria
	oModel:SetPrimaryKey({"ZE2_FILIAL","ZE2_NUM"})

	//Setando as descrições
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZE2MASTER"):SetDescription("Cab. Orçamento")
	oModel:GetModel("ZE3DETAIL"):SetDescription("Itens do Orçamento")

Return oModel


//===============================
//Criação do Modelo Visual      =
//===============================
Static Function ViewDef()

	Local oView
	Local oModel := FWLoadModel("ORCM03")
	Local oStZE2 := FWFormStruct(2, "ZE2")
	Local oStZE3 := FWFormStruct(2, "ZE3")

	//Criando a View
	oView := FWFormView():New()

	//Setando o Modelo de Dados na View
	oView:SetModel(oModel)

	//Removendo campo que não queremos que apareça no Grid de Itens
	oStZE3:RemoveField("ZE3_NUM")

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField("VIEW_ZE2", oStZE2, "ZE2MASTER") //Formulario
	oView:AddGrid("VIEW_ZE3" , oStZE3, "ZE3DETAIL") //Grid

	//Adicionando um Auto-Increment no campo ZE3_ITEM
	oView:AddIncrementField("VIEW_ZE3", "ZE3_ITEM")

	//Setando o dimensionamento de tamanho das telas
	oView:CreateHorizontalBox("TELAZE2", 30)
	oView:CreateHorizontalBox("TELAZE3", 70)

	//Amarrando a view com as box
	oView:SetOwnerView("VIEW_ZE2", "TELAZE2")
	oView:SetOwnerView("VIEW_ZE3", "TELAZE3")

	//Habilitando título
	oView:EnableTitleView("VIEW_ZE2", "Cab. Orçamento")
	oView:EnableTitleView("VIEW_ZE3", "Itens do Orçamento")

Return oView


//======================================
//Rotina de Faturamento do Orçamento   =
//======================================
User Function ORCM03F()

	Local aArea  := GetArea()
	Local nOpcao := 3 //Inclusão
	Local aCabec := {}
	Local aItens := {}
	Local aLinha
	Local cItem

	private lMsErroAuto := .F.

	DbSelectArea("ZE3")
	ZE3->(DbSetOrder(1)) // Indice 1 da Tabela SIX = ZE3_FILIAL + ZE3_NUM
	
	If ZE3->(DbSeek(ZE2->ZE2_FILIAL + ZE2->ZE2_NUM))


		//Monta Cabeçalho - aCabec
		aAdd( aCabec, {"C5_TIPO"     	, "N"       , Nil} )
		aAdd( aCabec, {"C5_CLIENTE"     , ZE2->ZE2_CODCLI     , Nil} )
		aAdd( aCabec, {"C5_LOJACLI"     , ZE2->ZE2_LOJA    , Nil} )
		aAdd( aCabec, {"C5_LOJAENT"     , ZE2->ZE2_LOJA    , Nil} )
		aAdd( aCabec, {"C5_CONDPAG"     , ZE2->ZE2_CONDPG    , Nil} )
		//Loop na Tabela de Itens do Orçamento para montar - aItens
		cItem := "00"
		While !ZE3->(Eof()) .AND. (ZE3->ZE3_FILIAL + ZE3->ZE3_NUM) == (ZE2->ZE2_FILIAL + ZE2->ZE2_NUM)

			cItem := Soma1(cItem) //Incremento Manual do C6_ITEM

			aLinha := {}
			aAdd(aLinha, {"C6_ITEM"   , cItem							, Nil})
			aAdd(aLinha, {"C6_PRODUTO", ZE3->ZE3_PROD					, Nil})
			aAdd(aLinha, {"C6_QTDVEN" , ZE3->ZE3_QTD					, Nil})
			aAdd(aLinha, {"C6_PRCVEN" , ZE3->ZE3_PROD					, Nil})
			aAdd(aLinha, {"C6_PRUNIT" , ZE3->ZE3_PRECO					, Nil})
			aAdd(aLinha, {"C6_VALOR"  , ZE3->ZE3_QTD * ZE3->ZE3_PRECO	, Nil})
			aAdd(aLinha, {"C6_DESCONT", ZE3->ZE3_DESCON					, Nil})
			aAdd(aLinha, {"C6_VALDESC", ZE3->ZE3_VLDESC					, Nil})
			aAdd(aLinha, {"C6_TES"    , "501"							, Nil})

			aAdd(aItens, aLinha)

			ZE3->(DbSkip())
		EndDo

		MSExecAuto({|a,b,c| MATA410(a,b,c)}, aCabec, aItens, nOpcao)

		If lMsErroAuto
			MostraErro()
		Else
			MsgInfo("Pedido Criado Com Sucesso!")

			RecLock("ZE2", .F.)
			ZE2->ZE2_PEDIDO := SC5->C5_NUM
			ZE2->ZE2_STATUS := "F"
			ZE2->(MsUnLock())

		EndIf

	EndIf

	RestArea(aArea)

Return


//======================================
//Rotina de Cancelamento               =
//======================================
User Function ORCM03C()

	Local aArea  := GetArea()
	Local nOpcao := 5 //EXCLUIR
	Local aCabec := {}
	Local aItens := {}
	Local aLinha
	Local cItem

	private lMsErroAuto := .F.

	DbSelectArea("ZE3")
	ZE3->(DbSetOrder(1)) // Indice 1 da Tabela SIX = ZE3_FILIAL + ZE3_NUM

	If ZE3->(DbSeek(ZE2->ZE2_FILIAL + ZE2->ZE2_NUM))


		//Monta Cabeçalho - aCabec
		aAdd( aCabec, {"C5_TIPO"     	, "N"       , Nil} )
		aAdd( aCabec, {"C5_CLIENTE"     , ZE2->ZE2_CODCLI     , Nil} )
		aAdd( aCabec, {"C5_LOJACLI"     , ZE2->ZE2_LOJA    , Nil} )
		aAdd( aCabec, {"C5_LOJAENT"     , ZE2->ZE2_LOJA    , Nil} )
		aAdd( aCabec, {"C5_CONDPAG"     , ZE2->ZE2_CONDPG    , Nil} )
		//Loop na Tabela de Itens do Orçamento para montar - aItens
		cItem := "00"
		While !ZE3->(Eof()) .AND. (ZE3->ZE3_FILIAL + ZE3->ZE3_NUM) == (ZE2->ZE2_FILIAL + ZE2->ZE2_NUM)

			cItem := Soma1(cItem) //Incremento Manual do C6_ITEM

			aLinha := {}
			aAdd(aLinha, {"C6_ITEM"   , cItem							, Nil})
			aAdd(aLinha, {"C6_PRODUTO", ZE3->ZE3_PROD					, Nil})
			aAdd(aLinha, {"C6_QTDVEN" , ZE3->ZE3_QTD					, Nil})
			aAdd(aLinha, {"C6_PRCVEN" , ZE3->ZE3_PROD					, Nil})
			aAdd(aLinha, {"C6_PRUNIT" , ZE3->ZE3_PRECO					, Nil})
			aAdd(aLinha, {"C6_VALOR"  , ZE3->ZE3_QTD * ZE3->ZE3_PRECO	, Nil})
			aAdd(aLinha, {"C6_DESCONT", ZE3->ZE3_DESCON					, Nil})
			aAdd(aLinha, {"C6_VALDESC", ZE3->ZE3_VLDESC					, Nil})
			aAdd(aLinha, {"C6_TES"    , "501"							, Nil})

			aAdd(aItens, aLinha)

			ZE3->(DbSkip())
		EndDo

		MSExecAuto({|a,b,c| MATA410(a,b,c)}, aCabec, aItens, nOpcao)

		If lMsErroAuto
			MostraErro()
		Else
			MsgInfo("Pedido cancelado Com Sucesso!")

			RecLock("ZE2", .F.)
			ZE2->ZE2_PEDIDO := SC5->C5_NUM
			ZE2->ZE2_STATUS := "C"
			ZE2->(MsUnLock())

		EndIf

	EndIf

	RestArea(aArea)

Return
