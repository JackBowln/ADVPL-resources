#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

Static cTitulo      := "Cadastro de Cliente"
Static cMasterSA1   := "MASTERSA1"
Static cVIEW_SA1    := "VIEW_SA1"

/*
DATA:   

DESC:   

AUTOR:
*/
User Function SA1MVC()

	//Instânciando FWMBrowse - Somente com dicionário de dados
	Local oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SA1")

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SA1MVC")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Adicionando Legendas
	oBrowse:AddLegend("SA1->A1_PESSOA == 'F'"  , "GREEN" ,"P.Fisica")
	oBrowse:AddLegend("SA1->A1_PESSOA == 'J'"  , "BLACK" ,"P.Juridica")

	//Ativa a Browse
	oBrowse:Activate()

Return


//======================
//CRIAÇÃO DOS MENUS    =
//======================
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.SA1MVC' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    	ACTION 'VIEWDEF.SA1MVC' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.SA1MVC' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.SA1MVC' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina Title 'Imprimir'   	ACTION "VIEWDEF.SA1MVC" 	OPERATION 8                      ACCESS 0 //OPERATION 8
	ADD OPTION aRotina Title 'Copiar'     	ACTION "VIEWDEF.SA1MVC" 	OPERATION 9                      ACCESS 0 //OPERATION 9

Return aRotina


//===============================
//Definição do Modelo de Dados	=
//===============================
Static Function ModelDef()

	//Criação do objeto do modelo de dados
	Local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStSA1 := FWFormStruct(1, "SA1")

	//Validação de Execução
	Local bCommit 	:= {|oModel| SaveModel(oModel)}
	Local bPos		:= {|oModel| ModelTOK(oModel)}

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("SA1MVCM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	//oModel := MPFormModel():New("M1ZE101M",/*bPre*/, /*bPos*/, bCommit, /*bCancel*/)
	//oModel := MPFormModel():New("M1ZE101M", /*bPre*/, bPos, bCommit, /*bCancel*/)

	//Atribuindo formulários para o modelo
	oModel:AddFields(cMasterSA1,/*cOwner*/,oStSA1)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"A1_FILIAL","A1_COD"})

	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro " + cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel(cMasterSA1):SetDescription("Formulário do Cadastro " + cTitulo)

Return oModel


//===================
//Definição da View	=
//===================
Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete (Nome do PRW)
	Local oModel := FWLoadModel("SA1MVC")

	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStSA1 := FWFormStruct(2, "SA1")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZE1_COD|'}

	//Criando oView
	Local oView := FWFormView():New()

	//Adicionando o modelo a view
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField(cVIEW_SA1, oStSA1, cMasterSA1)

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA", 100)

    //O formulário da interface será colocado dentro do container
	oView:SetOwnerView(cVIEW_SA1, "TELA")

    //Colocando título do formulário
	oView:EnableTitleView(cVIEW_SA1, "Dados - " + cTitulo)

    //Fechamento da janela na confirmação
	oView:SetCloseOnOk({|| .T.})

Return oView
