//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Orçamento de produtos"


User Function ZE2ZE3()
	Local aArea   := GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZE3")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Posiciona o MenuDef
	oBrowse:SetMenuDef("ZE2ZE3")

	//Legendas
	//oBrowse:AddLegend( "ZZZ->BM_PROORI == '1'", "GREEN",	"Original" )
	//oBrowse:AddLegend( "ZZZ->BM_PROORI == '0'", "RED",	"Não Original" )

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil


Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZE2ZE3' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZE2ZE3' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZE2ZE3' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ZE2ZE3' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot



Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZE2')
	Local oStFilho 		:= FWFormStruct(1, 'ZE3')
	Local aZZKRel		:= {}

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('MMODE3')

	oModel:AddFields('ZE2MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZE3DETAIL','ZE2MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	oModel:SetRelation('ZE3DETAIL', {{'ZE2_FILIAL','ZE3_FILIAL'}, {'ZE2_NUM', 'ZE3_NUM'}})

	oModel:SetPrimaryKey({ 'ZE2_FILIAL','ZE2_NUM' })

	//Setando as descrições
	oModel:SetDescription("ORÇAMENTO")
	oModel:GetModel('ZE2MASTER'):SetDescription('CABEÇALHO ORÇAMENTO')
	oModel:GetModel('ZE3DETAIL'):SetDescription('ITEM ORÇAMENTO')

Return oModel


Static Function ViewDef()
	Local oView			:= Nil
	Local oModel		:= FWLoadModel('ZE2ZE3')
	Local oStPai		:= FWFormStruct(2, 'ZE2')
	Local oStFilho		:= FWFormStruct(2, 'ZE3')

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// oStFilho:RemoveField( 'ZZK_CODZZZ' )

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZE2',oStPai,'ZE2MASTER')
	oView:AddGrid('VIEW_ZE3',oStFilho,'ZE3DETAIL')


	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZE2','CABEC')
	oView:SetOwnerView('VIEW_ZE3','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZE3','CABEÇALHO')
	oView:EnableTitleView('VIEW_ZE2','ITEMS')

Return oView

