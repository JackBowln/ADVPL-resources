#include 'FWMVCDef.ch'
#include 'Totvs.ch'
#include 'Protheus.ch'


Static cTitulo      := "Cadastro de Empréstimo de peaças"
Static cMasterZE1   := "MASTERZE1"
Static cVIEW_ZE1    := "VIEW_ZE1"


User Function ZE1MVC()
	Local oBrowse := FWMBrowse():New()

	//Setando a COD de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZE1")

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("ZE1MVC")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Adicionando Legendas
	oBrowse:AddLegend("ZE1->ZE1_STATUS == '1'"  , "GREEN" ,"PENDENTE")
	oBrowse:AddLegend("ZE1->ZE1_STATUS == '2'"  , "BLACK" ,"ENTREGUE")

	//Ativa a Browse
	oBrowse:Activate()
Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.ZE1MVC' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    	ACTION 'VIEWDEF.ZE1MVC' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.ZE1MVC' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.ZE1MVC' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina Title 'Imprimir'   	ACTION "VIEWDEF.ZE1MVC" 	OPERATION 8                      ACCESS 0 //OPERATION 8
	ADD OPTION aRotina Title 'Copiar'     	ACTION "VIEWDEF.ZE1MVC" 	OPERATION 9                      ACCESS 0 //OPERATION 9

Return aRotina

Static Function ModelDef()

//Criação do objeto do modelo de dados
	Local oModel     := Nil
	Local oStrDetail := FWFormStruct(1, "ZE1")
	Local oStrMaster

	//Cria uma estrutura, sera o cabelho
	oStrMaster := FWFormModelStruct():New()
	oStrMaster:AddTable("ZE1", {"ZE1_FILIAL", "ZE1_COD"}, "Cabecalho ZE1")

	//Adicionando os campos do cabeçario
	oStrMaster:AddField('Filial', 'Filial', 'ZE1_FILIAL', 'C', TamSX3("ZE1_FILIAL")[1])
	oStrMaster:AddField('COD', 'COD', 'ZE1_COD', 'C', TamSX3("ZE1_COD")[1])

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("ZE1MVCM",/*bPre*/,/* bPos */ ,/*{|oModel| SaveModel(oModel)}*/,/*bCancel*/)

	//Informando se o campo pode ser alterado (Campo fica cinza)
	oStrMaster:SetProperty("ZE1_COD", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, "INCLUI"))

	//Atribuindo formulários para o modelo
	oModel:AddFields("ZE1MASTER",,oStrMaster)

	//Atribuindo Grid para o modelo ZE1MASTER
	oModel:AddGrid("ZE1DETAIL", "ZE1MASTER", oStrDetail)

	//Adiciona o relacionamento da grid com o cabeçario
	oModel:SetRelation("ZE1DETAIL", {{"ZE1_FILIAL", "xFilial('ZE1')"},{"ZE1_COD","ZE1_COD"} })

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"ZE1_FILIAL","ZE1_COD"})

	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	oModel:SetActivate({ |oModel| ForceValue(oModel)})


Return oModel


//===================
//Definição da View	=
//===================
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oStrDetail := FWFormStruct(2, "ZE1")
	Local oModel := FWLoadModel("ZE1MVC")
	Local oView := Nil

	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStrMaster := FWFormViewStruct():New()
    
	//Adicionando um campo a estrutura
	oStrMaster:AddField("ZE1_COD", "01", "COD", "COD",,"C")

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Criando uma estrutura para o cabeçario
	// oStrMaster := FWFormViewStruct():New()

	//Adicionando um campo a estrutura
	// oStrMaster:AddField("ZE1_COD", "01", "COD", "COD",,"C")

	//Informando se o campo pode ser alterado (Campo fica cinza)
	oStrMaster:SetProperty("ZE1_COD", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN,"INCLUI"))
	
    //Removendo campos da view
	oStrDetail:RemoveField("ZE1_COD")

	//Atribuindo formulários para interface
	oView:AddField("VIEW_MASTER", oStrMaster, "ZE1MASTER")
	oView:AddGrid("VIEW_DETAIL" , oStrDetail, "ZE1DETAIL")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA_MASTER", 010)
	oView:CreateHorizontalBox("TELA_DETAIL", 090)

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_MASTER" , "TELA_MASTER")
	oView:SetOwnerView("VIEW_DETAIL" , "TELA_DETAIL")

	oView:EnableTitleView("VIEW_DETAIL", "Registros do Arquivo - " + cTitulo)

Return oView


Static Function ForceValue(oModel)

	//Só efetua a alteração do campo para inserção
	//If  oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. ;
		//		oModel:GetOperation() == MODEL_OPERATION_UPDATE

	//	FwFldPut("ZZ4_FILIAL",xFilial('ZZ4'),/nLinha/,oModel)
	//Endif

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE

		oModel:LoadValue("ZE1MASTER","ZE1_COD",ZE1->ZE1_COD)

	Endif

Return
