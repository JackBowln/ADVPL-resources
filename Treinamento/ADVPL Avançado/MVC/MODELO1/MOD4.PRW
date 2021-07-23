//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Produto"
 
User Function MOD4()
    Local aArea    := GetArea()
    Local oBrowse  := Nil  

    //Instânciando FWMBrowse 
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela 
    oBrowse:SetAlias("SB1")
 
    //Posiciona o MenuDef
    oBrowse:SetMenuDef("MOD4")
    
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
    
Return Nil
 
Static Function MenuDef()

    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MOD4' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MOD4' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MOD4' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MOD4' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot

Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStSB1 := FWFormStruct(1, "SB1")

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("MMOD4",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSB1",/*cOwner*/,oStSB1)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'B1_FILIAL','B1_COD'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMSB1"):SetDescription("Formulário do Cadastro "+cTitulo)
         
Return oModel
 

Static Function ViewDef()
     
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete (Nome do PRW)
    Local oModel := FWLoadModel("MOD4")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSB1 := FWFormStruct(2, "SB1")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'B1_COD|A1_NOME|'}
    
    //Criando oView
    Local oView := FWFormView():New()

    //Adicionando o modelo a view
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SB1", oStSB1, "FORMSB1")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SB1', 'Dados - '+cTitulo )  
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SB1","TELA")

Return oView
