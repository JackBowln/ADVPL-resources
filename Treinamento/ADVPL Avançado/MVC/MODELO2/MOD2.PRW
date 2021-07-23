#INCLUDE "TOTVS.CH"
#include 'fileio.ch'
#INCLUDE "protheus.CH"
#Include "Parmtype.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"


Static cTitulo := "Tabela SX5"

User Function MOD2()

    Local aArea   		:= GetArea()
    Local oBrowse       := Nil

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de comprovante de entrega
    oBrowse:SetAlias("SX5")

    //Posiciona o MenuDef
    oBrowse:SetMenuDef("MOD2")

    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()

    RestArea(aArea)

Return


Static Function MenuDef()

    Local aRot := {}

    //Adicionando opções
    aAdd(aRot,{'Pesquisar'	,'VIEWDEF.MOD2'	,0,1,0,NIL})
    aAdd(aRot,{'Visualizar'	,'VIEWDEF.MOD2'	,0,2,0,NIL})
    aAdd(aRot,{'Incluir' 	,'VIEWDEF.MOD2'	,0,3,0,NIL})
    aAdd(aRot,{'Alterar' 	,'VIEWDEF.MOD2'	,0,4,0,NIL})
    aAdd(aRot,{'Excluir' 	,'VIEWDEF.MOD2'	,0,5,0,NIL})


Return aRot


Static Function ModelDef()

    //Criação do objeto do modelo de dados
    Local oModel  := Nil
    Local oStSX5B := FWFormStruct(1, "SX5")

    //Cria uma estrutura, sera o cabelho
    oStrField := FWFormModelStruct():New()
    oStrField:AddTable('SX5', {'X5_FILIAL'  , 'X5_TABELA'}, "Cabecalho SX5")

    //Adicionando os campos do cabeçario
    oStrField:AddField( 'Filial'   ,'Filial'    , 'X5_FILIAL' , 'C' ,TamSX3("X5_FILIAL")[1])
    oStrField:AddField( 'Tabela'   ,'Tabela'    , 'X5_TABELA'  , 'C' ,TamSX3("X5_TABELA")[1])
    
    //Informando se o campo pode ser alterado (Campo fica cinza)
    //https://tdn.totvs.com/display/framework/FWFormModelStruct
    //oStrField:SetProperty("X5_TABELA", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, "INCLUI"))

    //Deixar os campos como obrigatorio
    //oStSX5B:SetProperty("X5_TABELA", MODEL_FIELD_OBRIGAT,.f.)
 
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("MMOD2",/*bPre*/,/* bPos */ ,/*{|oModel| SaveModel(oModel)}*/,/*bCancel*/)

    //Atribuindo formulários para o modelo
    oModel:AddFields('CABMASTER', , oStrField)

    oModel:AddGrid( "SX5DETAIL"  , "CABMASTER"  , oStSX5B)

     //Adiciona o relacionamento da grid com o cabeçario
    oModel:SetRelation( 'SX5DETAIL', { { 'X5_FILIAL', 'xFilial("SX5")' },{'X5_TABELA','X5_TABELA'} })

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey( { 'X5_FILIAL','X5_TABELA','X5_CHAVE' } )

    //Adicionando descrição ao modelo
    oModel:SetDescription(cTitulo)

Return oModel


Static Function ViewDef()

    
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("MOD2")

    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStrSX5 := FWFormStruct( 2, 'SX5' )
    Local oStrCab  := Nil

    //Criando oView como nulo
    Local oView := Nil

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()

    //Seta o modelo
    oView:SetModel(oModel)

    //Criando uma estrutura para o cabeçario
    oStrCab := FWFormViewStruct():New()

    //Adicionando um campo a estrutura
    oStrCab:AddField( 'X5_TABELA'    , '01' , 'Tabela'  , 'Tabela' , , 'C' )
    
    //Removendo campos da view
     oStrSX5:RemoveField( 'X5_TABELA' )

    //Atribuindo formulários para interface
    oView:AddField('View_LOTE', oStrCab, 'CABMASTER')
    oView:AddGrid('View_SX5'  , oStrSX5, 'SX5DETAIL')

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("SUPERIOR",010)
    oView:CreateHorizontalBox("INFERIOR",090)

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("View_LOTE" , "SUPERIOR")
    oView:SetOwnerView("View_SX5" , "INFERIOR")

    oView:EnableTitleView("View_SX5", "Registros do arquivo" )

Return oView
