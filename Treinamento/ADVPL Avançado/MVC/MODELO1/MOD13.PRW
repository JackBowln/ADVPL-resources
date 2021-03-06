//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Vari�veis Est�ticas
Static cTitulo := "TELA DE CADASTRO"
 
User Function MOD13()
    Local aArea    := GetArea()
    Local oBrowse  := Nil  

    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZZZ")
 
    //Posiciona o MenuDef
    oBrowse:SetMenuDef("MOD13")
    
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
    
Return Nil
 
Static Function MenuDef()

    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MOD13' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MOD13' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MOD13' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MOD13' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot

Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStZZZ := FWFormStruct(1, "ZZZ")

    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("MMOD13",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMZZZ",/*cOwner*/,oStZZZ)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'ZZZ_FILIAL','ZZZ_COD'})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMZZZ"):SetDescription("Formul�rio do Cadastro "+cTitulo)
         
Return oModel
 

Static Function ViewDef()
     
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete (Nome do PRW)
    Local oModel := FWLoadModel("MOD13")
     
    //Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZZZ := FWFormStruct(2, "ZZZ")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'A1_COD|A1_NOME|'}
    
    //Criando oView
    Local oView := FWFormView():New()

    //Adicionando o modelo a view
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_ZZZ", oStZZZ, "FORMZZZ")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_ZZZ', 'Dados - '+cTitulo )  
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_ZZZ","TELA")

Return oView
