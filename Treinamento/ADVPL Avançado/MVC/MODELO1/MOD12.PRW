//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "rwmake.ch"

//Variáveis Estáticas
Static cTitulo := "Cliente"

User Function MOD12()
    Local aArea    := GetArea()
    Local oBrowse  := Nil

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SA1")

    //Posiciona o MenuDef
    oBrowse:SetMenuDef("MOD12")

    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()

    RestArea(aArea)

Return Nil

Static Function MenuDef()

    Local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil

    //Criação da estrutura de dados utilizada na interface
    Local oStSA1 := FWFormStruct(1, "SA1")

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("MMOD12",/*bPre*/,  {|oModel| ModelTOK(oModel)},/*bCommit*/,/*bCancel*/)

    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSA1",/*cOwner*/,oStSA1)

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'A1_FILIAL','A1_COD'})

    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

    //Setando a descrição do formulário
    oModel:GetModel("FORMSA1"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel


Static Function ViewDef()

    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete (Nome do PRW)
    Local oModel := FWLoadModel("MOD12")

    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSA1 := FWFormStruct(2, "SA1")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'A1_COD|A1_NOME|'}

    //Criando oView
    Local oView := FWFormView():New()

    //Adicionando o modelo a view
    oView:SetModel(oModel)

    //Atribuindo formulários para interface
    oView:AddField("VIEW_SA1", oStSA1, "FORMSA1")

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SA1', 'Dados - '+cTitulo )

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SA1","TELA")

Return oView



Static function ModelTOK(oModel)
    Local lReturn := .T.
    Local cCod := '000000'
    
    If RetCodUsr() == cCod
        lReturn := .f.
    EndIf

Return lReturn
