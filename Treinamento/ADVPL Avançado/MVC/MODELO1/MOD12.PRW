//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "rwmake.ch"

//Vari�veis Est�ticas
Static cTitulo := "Cliente"

User Function MOD12()
    Local aArea    := GetArea()
    Local oBrowse  := Nil

    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SA1")

    //Posiciona o MenuDef
    oBrowse:SetMenuDef("MOD12")

    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()

    RestArea(aArea)

Return Nil

Static Function MenuDef()

    Local aRot := {}

    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MOD12' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil

    //Cria��o da estrutura de dados utilizada na interface
    Local oStSA1 := FWFormStruct(1, "SA1")

    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("MMOD12",/*bPre*/,  {|oModel| ModelTOK(oModel)},/*bCommit*/,/*bCancel*/)

    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMSA1",/*cOwner*/,oStSA1)

    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'A1_FILIAL','A1_COD'})

    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMSA1"):SetDescription("Formul�rio do Cadastro "+cTitulo)

Return oModel


Static Function ViewDef()

    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete (Nome do PRW)
    Local oModel := FWLoadModel("MOD12")

    //Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSA1 := FWFormStruct(2, "SA1")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'A1_COD|A1_NOME|'}

    //Criando oView
    Local oView := FWFormView():New()

    //Adicionando o modelo a view
    oView:SetModel(oModel)

    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_SA1", oStSA1, "FORMSA1")

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_SA1', 'Dados - '+cTitulo )

    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_SA1","TELA")

Return oView



Static function ModelTOK(oModel)
    Local lReturn := .T.
    Local cCod := '000000'
    
    If RetCodUsr() == cCod
        lReturn := .f.
    EndIf

Return lReturn
