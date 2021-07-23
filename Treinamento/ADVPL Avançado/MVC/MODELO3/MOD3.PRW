//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Grp.Produtos x produtos"


User Function MOD3()
	Local aArea   := GetArea()
	Local oBrowse
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZZZ")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

    //Posiciona o MenuDef
    oBrowse:SetMenuDef("MOD3")
	
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
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MOD3' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MOD3' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MOD3' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MOD3' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot



Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZZZ')
	Local oStFilho 		:= FWFormStruct(1, 'ZZK')
	Local aZZKRel		:= {}
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('MMODE3')
	
	oModel:AddFields('ZZZMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZZKDETAIL','ZZZMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	oModel:SetRelation('ZZKDETAIL', {{'ZZK_CODZZZ','ZZZ_COD'}})
    
    oModel:SetPrimaryKey({ 'ZZZ_FILIAL','ZZZ_COD' })
	
	//Setando as descrições
	oModel:SetDescription("Grupo de Produtos - Mod. 3")
	oModel:GetModel('ZZZMASTER'):SetDescription('Modelo Grupo')
	oModel:GetModel('ZZKDETAIL'):SetDescription('Modelo Produtos')

Return oModel


Static Function ViewDef()
	Local oView			:= Nil
	Local oModel		:= FWLoadModel('MOD3')
	Local oStPai		:= FWFormStruct(2, 'ZZZ')
	Local oStFilho		:= FWFormStruct(2, 'ZZK')
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oStFilho:RemoveField( 'ZZK_CODZZZ' )

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZZZ',oStPai,'ZZZMASTER')
	oView:AddGrid('VIEW_ZZK',oStFilho,'ZZKDETAIL')
	
	oView:AddIncrementField( 'VIEW_SZ6I', 'Z6_ITEM' )

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZZZ','CABEC')
	oView:SetOwnerView('VIEW_ZZK','GRID')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_ZZZ','Grupo')
	oView:EnableTitleView('VIEW_ZZK','Produtos')

Return oView

