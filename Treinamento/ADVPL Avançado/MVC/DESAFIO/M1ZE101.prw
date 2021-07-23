#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Cadastro de Emprestimos de Produto"

/*
DATA:   

DESC:   

AUTOR:
*/

User Function M1ZE101()

	Private oBrowse := Nil

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZE1")

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("M1ZE101")

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo)

	//Adicionando Legendas
	oBrowse:AddLegend("ZE1->ZE1_STATUS == '1'"  , "GREEN" ,"Pendente")
	oBrowse:AddLegend("ZE1->ZE1_STATUS == '2'"  , "BLACK" ,"Entregue")

	//Ativa a Browse
	oBrowse:Activate()

Return


//======================
//CRIA��O DOS MENUS    =
//======================
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 					ACTION 'VIEWDEF.M1ZE101' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    					ACTION 'VIEWDEF.M1ZE101' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    					ACTION 'VIEWDEF.M1ZE101' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    					ACTION 'VIEWDEF.M1ZE101' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina Title 'Imprimir'   					ACTION "VIEWDEF.M1ZE101" 	OPERATION 8                      ACCESS 0 //OPERATION 8
	ADD OPTION aRotina Title 'Copiar'     					ACTION "VIEWDEF.M1ZE101" 	OPERATION 9                      ACCESS 0 //OPERATION 9

	//Encerramento de Emprestimo
	ADD OPTION aRotina TITLE 'Encerrar Emprestimo'    		ACTION 'u_ZE101A(1)' 		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Encerrar Todos Emprestimos'   ACTION 'u_ZE101A(2)' 		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4

Return aRotina


//===============================
//Defini��o do Modelo de Dados	=
//===============================
Static Function ModelDef()

	//Cria��o do objeto do modelo de dados
	Local oModel 	 := Nil

	//Cria uma estrutura, sera o cabelho
	Local oStrMaster :=�FWFormModelStruct():New()

	//Cria��o da estrutura de dados utilizada na interface
	Local oStZE1 	 := FWFormStruct(1, "ZE1")

	//Valida��o de Execu��o
	Local bCommit 	 := {|oModel| SaveModel(oModel)}
	Local bPos		 := {|oModel| ModelTOK(oModel)}

	//Cria uma estrutura, sera o cabelho
	oStrMaster:AddTable("ZE1", {"ZE1_FILIAL", "ZE1_STATUS", "ZE1_COD", "ZE1_CODCLI", "ZE1_LOJA"}, "Cabecalho ZE1")

	//Adicionando os campos do cabe�ario
	oStrMaster:AddField('Filial' , 'Filial' ,�'ZE1_FILIAL',�'C', TamSX3("ZE1_FILIAL")[1])
	oStrMaster:AddField('Status' , 'Status' ,�'ZE1_STATUS',�'C', TamSX3("ZE1_STATUS")[1])
	oStrMaster:AddField('Codigo' , 'Codigo' ,�'ZE1_COD'   ,�'C', TamSX3("ZE1_COD")[1])
	oStrMaster:AddField('Cliente', 'Cliente',�'ZE1_CODCLI',�'C', TamSX3("ZE1_CODCLI")[1])
	oStrMaster:AddField('Loja'	 , 'Loja'   ,�'ZE1_LOJA'  ,�'C', TamSX3("ZE1_LOJA")[1])

	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("M1ZE101M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	//oModel := MPFormModel():New("M1ZE101M",/*bPre*/, /*bPos*/, bCommit, /*bCancel*/)
	//oModel := MPFormModel():New("M1ZE101M", /*bPre*/, bPos, bCommit, /*bCancel*/)

	//Atribuindo formul�rios para o modelo
	oModel:AddFields("MASTERZE1",/*cOwner*/,oStrMaster)

	//Atribuindo Grid para o modelo SX5MASTER
	oModel:AddGrid("DETAILZE1", "MASTERZE1", oStZE1)

	//Adiciona o relacionamento da grid com o cabe�ario
	oModel:SetRelation("DETAILZE1",�{{"ZE1_FILIAL",�"xFilial('ZE1')"},{"ZE1_COD","ZE1_COD"}�})

	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({'ZE1_FILIAL','ZE1_COD'})

	//Adicionando descri��o ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)

	//Setando a descri��o do formul�rio
	oModel:GetModel("MASTERZE1"):SetDescription("Formul�rio do Cadastro " + cTitulo)

Return oModel


//===================
//Defini��o da View	=
//===================
Static Function ViewDef()

	//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete (Nome do PRW)
	Local oModel := FWLoadModel("M1ZE101")

	//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZE1 := FWFormStruct(2, "ZE1")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZE1_COD|'}

	//Criando oView
	Local oView := FWFormView():New()

	//Criando uma estrutura para o cabe�ario
	Local oStrMaster :=�FWFormViewStruct():New()

	//Adicionando um campo a estrutura
	oStrMaster:AddField("ZE1_STATUS",�"01",�"Status" , "Status" ,,"C")
	oStrMaster:AddField("ZE1_COD"   ,�"02",�"Codigo" , "Codigo" ,,"C")
	oStrMaster:AddField("ZE1_CODCLI",�"03",�"Cliente", "Cliente",,"C")
	oStrMaster:AddField("ZE1_LOJA"  ,�"04",�"Loja"   , "Loja"   ,,"C")

	//Adicionando o modelo a view
	oView:SetModel(oModel)

	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_MASTER", oStrMaster, "MASTERZE1")
	oView:AddGrid("VIEW_ZE1"    , oStZE1    , "DETAILZE1")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA_MASTER", 30)
	oView:CreateHorizontalBox("TELA_DETAIL", 70)

	//Colocando t�tulo do formul�rio
	oView:EnableTitleView("VIEW_MASTER", "Cabe�alho - " + cTitulo)
	oView:EnableTitleView("VIEW_ZE1"   , "Dados - " + cTitulo)

	//Fechamento da janela na confirma��o
	oView:SetCloseOnOk({|| .T.})

	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_MASTER", "TELA_MASTER")
	oView:SetOwnerView("VIEW_ZE1"   , "TELA_DETAIL")
	
Return oView


//=======================
//Valida��o do TUDOOK	=
//=======================
Static function ModelTOK(oModel)

	Local lRet := .T.

Return lRet


//=======================================================
//Resposavel por savvar e realizar a Grava��o do Modelo	=
//=======================================================
Static function SaveModel(oModel)

	Local lRet 		:= .T.
	Local lContinua	:= .F.

	lContinua := MsgYesNo("Deseja Realmente Salvar esta Opera��o?")

	If lContinua
		/*
		Esta fun��o realiza os tratamentos necess�rios a grava��o dos submodelos de edi��o do Microsiga Protheus. A gravacao
		� realizada em niveis onde o primeiro elemento do modelo e posteriormente seus filhos s�o gravados. O
		controle de transa��o � aberto por esta fun��o e h� um controle de RollBack para devolver o problema para a interface.
		*/
		If FWFormCommit(oModel)
			MsgInfo("Dados Salvos Com Sucesso.")
		EndIf

	Else
		lRet := .F.
	EndIf

Return lRet


//===============================
//ENCERRAMENTO DO EMPRESTIMO    =
//===============================
User Function ZE101A(nOpcao)

	FWMsgRun(, {|| FZE101A(nOpcao) }, "Processando", "Encerrando Emprestimos...")

Return
Static Function FZE101A(nOpcao)

	Local aArea := GetArea()

	If nOpcao == 1

		If MsgYesNo("Deseja Realmente Encerrar este Emprestimo?")

			RecLock("ZE1", .F.)
			ZE1->ZE1_SALDO  := 0
			ZE1->ZE1_STATUS := "2"
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
					ZE1->(MsUnLock())
				EndIf

				ZE1->(DbSkip())
			EndDo

		EndIf

	EndIf

	RestArea(aArea)

Return
