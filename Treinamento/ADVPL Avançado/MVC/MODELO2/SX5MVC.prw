#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Tabela Generica"

/*
DATA:   

DESC:   

AUTOR:
*/
User Function SX5MVC()

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	Local oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SX5")

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("SX5MVC")

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()

Return


//======================
//CRIA��O DOS MENUS    =
//======================
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.SX5MVC' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    	ACTION 'VIEWDEF.SX5MVC' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.SX5MVC' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.SX5MVC' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina Title 'Imprimir'   	ACTION "VIEWDEF.SX5MVC" 	OPERATION 8                      ACCESS 0 //OPERATION 8
	ADD OPTION aRotina Title 'Copiar'     	ACTION "VIEWDEF.SX5MVC" 	OPERATION 9                      ACCESS 0 //OPERATION 9

Return aRotina



//===============================
//Defini��o do Modelo de Dados	=
//===============================
Static Function ModelDef()

	//Cria��o do objeto do modelo de dados
	Local oModel     := Nil
	Local oStrDetail := FWFormStruct(1, "SX5")
	Local oStrMaster

	//Cria uma estrutura, sera o cabelho
	oStrMaster :=�FWFormModelStruct():New()
	oStrMaster:AddTable("SX5", {"X5_FILIAL", "X5_TABELA"}, "Cabecalho SX5")

	//Adicionando os campos do cabe�ario
	oStrMaster:AddField('Filial', 'Filial',�'X5_FILIAL',�'C', TamSX3("X5_FILIAL")[1])
	oStrMaster:AddField('Tabela', 'Tabela',�'X5_TABELA',�'C', TamSX3("X5_TABELA")[1])

	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("SX5MVCM",/*bPre*/,/* bPos */ ,/*{|oModel| SaveModel(oModel)}*/,/*bCancel*/)

    //Informando se o campo pode ser alterado (Campo fica cinza)
    oStrMaster:SetProperty("X5_TABELA", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, "INCLUI"))
	
	//Removendo campo obrigadorio
	oStrDetail:SetProperty("X5_TABELA", MODEL_FIELD_OBRIGAT, .F.)

	//Atribuindo formul�rios para o modelo
	oModel:AddFields("SX5MASTER",,oStrMaster)

	//Atribuindo Grid para o modelo SX5MASTER
	oModel:AddGrid("SX5DETAIL", "SX5MASTER", oStrDetail)

	//Adiciona o relacionamento da grid com o cabe�ario
	oModel:SetRelation("SX5DETAIL",�{{"X5_FILIAL",�"xFilial('SX5')"},{"X5_TABELA","X5_TABELA"}�})

	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({"X5_FILIAL","X5_TABELA","X5_CHAVE"})

	//Adicionando descri��o ao modelo
	oModel:SetDescription(cTitulo)

Return oModel


//===================
//Defini��o da View	=
//===================
Static Function ViewDef()

	//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("SX5MVC")

	//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStrDetail :=�FWFormStruct(2,�"SX5")
	Local oStrMaster := Nil

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Criando uma estrutura para o cabe�ario
	oStrMaster :=�FWFormViewStruct():New()

	//Adicionando um campo a estrutura
	oStrMaster:AddField("X5_TABELA",�"01",�"Tabela", "Tabela",,"C")

	//Removendo campos da view
	oStrDetail:RemoveField("X5_TABELA")

	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_MASTER", oStrMaster,�"SX5MASTER")
	oView:AddGrid("VIEW_DETAIL" , oStrDetail,�"SX5DETAIL")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA_MASTER", 010)
	oView:CreateHorizontalBox("TELA_DETAIL", 090)

	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_MASTER" , "TELA_MASTER")
	oView:SetOwnerView("VIEW_DETAIL" , "TELA_DETAIL")

	oView:EnableTitleView("VIEW_DETAIL", "Registros do Arquivo - " + cTitulo)

Return oView
