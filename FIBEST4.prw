#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:	13/01/2021	

DESCR:	Cadastro de Regras de Condição de Pagamento
		
AUTOR:	MAYCON ANHOLETI BIANCHINE - TOTVS
*/
User Function FIBEST4()

	Local oBrowse
	Local cFiltro

	Private cTitulo := "Cadastro de Regras de Condição de Pagamento"

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("ZZ4")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("FIBEST4")
	oBrowse:SetCacheView(.F.)

	/*
	cFiltro := " R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) AS R_E_C_N_O_ "+CRLF
	cFiltro += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
	cFiltro += "WHERE "+CRLF
	cFiltro += "      ZZ4.D_E_L_E_T_ = '' "+CRLF
	cFiltro += "GROUP BY ZZ4.ZZ4_FILIAL, ZZ4.ZZ4_CODVEN, ZZ4.ZZ4_DTINI, ZZ4.ZZ4_DTFIM) "
	oBrowse:SetFilterDefault("@" + cFiltro)
	oBrowse:SetOnlyFields({'ZZ4_FILIAL','ZZ4_CODVEN','ZZ4_NOMVEN','ZZ4_DTINI','ZZ4_DTFIM'})
	*/
	
	oBrowse:AddLegend("DtoS(dDataBase) >= DtoS(ZZ4_DTINI) .AND. DtoS(dDataBase) <= DtoS(ZZ4_DTFIM)"			,"GREEN" ,"Periodo Valido")
	oBrowse:AddLegend("DtoS(dDataBase) >= DtoS(ZZ4_DTINI) .AND. DtoS(dDataBase) >= DtoS(ZZ4_DTFIM)"			,"RED"   ,"Periodo Invalido")
	oBrowse:AddLegend("!(DtoS(dDataBase) >= DtoS(ZZ4_DTINI)) .AND. !(DtoS(dDataBase) >= DtoS(ZZ4_DTFIM))"	,"BLUE"	 ,"Periodo Provisionado")

	oBrowse:Activate()

Return Nil


//=======================
//Definições dos menus	=
//=======================
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FIBEST4'  OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3

	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FIBEST4'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FIBEST4' 	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FIBEST4'  OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Encerrar'   ACTION 'u_FIBEST4E()' 	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Copiar' 	  ACTION 'VIEWDEF.FIBEST4'  OPERATION 9 					 ACCESS 0 //OPERATION 9
	ADD OPTION aRotina TITLE 'Importação de Regras Condição de Pagamento'    ACTION 'u_FIBEST4I()' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3

	//rotinas temporarias
	//ADD OPTION aRotina TITLE 'Unificação Condição de Pagamento - Parte 1' ACTION 'u_FIBEST4U(1)' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRotina TITLE 'Unificação Condição de Pagamento - Parte 2' ACTION 'u_FIBEST4U(2)' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3

Return aRotina

//===================================
//Modelo 2 de dados da tabela ZZ4	=
//===================================
Static Function ModelDef()

	//Criação do objeto do modelo de dados
	Local oModel  := Nil
	Local oStZZ4 := FWFormStruct(1,"ZZ4")
	Local aAuxGat := {}

	//Cria uma estrutura, sera o cabelho
	oStrField := FWFormModelStruct():New()
	oStrField:AddTable('ZZ4',{'ZZ4_FILIAL','ZZ4_CODVEN','ZZ4_DTINI','ZZ4_DTFIM'},"Cabecalho ZZ4")

	//Adicionando os campos do cabeçario
	//oStrField:AddField('Filial','Filial','ZZ4_FILIAL','C',TamSX3("ZZ4_FILIAL")[1])
	oStrField:AddField('Cod. Vend.  '	,'Cod. Vend.  '		,'ZZ4_CODVEN'	,'C',TamSX3("ZZ4_CODVEN")[1])
	oStrField:AddField('Nome Vend.  '	,'Nome Vend.  '		,'ZZ4_NOMVEN'	,'C',TamSX3("ZZ4_NOMVEN")[1])
	oStrField:AddField('Data Inicial'	,'Data Inicial'		,'ZZ4_DTINI'	,'D',TamSX3("ZZ4_DTINI")[1])
	oStrField:AddField('Data Final'		,'Data Final'		,'ZZ4_DTFIM'	,'D',TamSX3("ZZ4_DTFIM")[1])

	//oStrField:SetProperty('ZZ4_CODVEN',MODEL_FIELD_OBRIGAT,.T.)
	oStrField:SetProperty('ZZ4_DTINI' ,MODEL_FIELD_OBRIGAT,.T.)
	oStrField:SetProperty('ZZ4_DTFIM' ,MODEL_FIELD_OBRIGAT,.T.)

	//Deixar o campo não alterado
	oStrField:SetProperty("ZZ4_CODVEN",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"IIF(INCLUI,.T.,.F.)"))
	oStrField:SetProperty("ZZ4_NOMVEN",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
	oStrField:SetProperty("ZZ4_DTINI" ,MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"IIF(INCLUI,.T.,.F.)"))
	oStrField:SetProperty("ZZ4_DTFIM" ,MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"IIF(INCLUI,.T.,.F.)"))

	//Inicializador padrão
	//oStrField:SetProperty('ZZ4_DTINI', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'dDataBase')) //Ini Padrão
	//oStrField:SetProperty('ZZ4_DTFIM', MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'dDataBase + 30')) //Ini Padrão

	aAuxGat := {}
	aAuxGat := FwStruTrigger("ZZ4_CODVEN","ZZ4_NOMVEN","POSICIONE('SA3',1,xFilial('SA3')+M->ZZ4_CODVEN,'A3_NOME')",.F.,NIL,NIL,NIL)
	oStrField:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("FIBEST4M",/*bPre*/,/* bPos */ ,/*{|oModel| SaveModel(oModel)}*/,/*bCancel*/)

	// É necessário que haja alguma alteração na estrutura Field
	oModel:SetActivate({ |oModel| ForceValue(oModel)})

	//Atribuindo formulários para o modelo
	oModel:AddFields('ZZ4MASTER',,oStrField)

	//Gatilhos 
	aAuxGat := FwStruTrigger("ZZ4_CONDPG","ZZ4_DESCPG","POSICIONE('SE4',1,xFilial('SE4')+M->ZZ4_CONDPG,'E4_DESCRI')",.F.,NIL,NIL,NIL)
	oStZZ4:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	aAuxGat := {}
	aAuxGat := FwStruTrigger("ZZ4_CODCLI","ZZ4_NOMCLI","POSICIONE('SA1',1,xFilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA,'A1_NOME')",.F.,NIL,NIL,NIL)
	oStZZ4:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	aAuxGat := {}
	aAuxGat := FwStruTrigger("ZZ4_LOJA","ZZ4_NOMCLI","POSICIONE('SA1',1,xFilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA,'A1_NOME')",.F.,NIL,NIL,NIL)
	oStZZ4:AddTrigger(aAuxGat[1],aAuxGat[2],aAuxGat[3],aAuxGat[4])

	oStZZ4:SetProperty('ZZ4_CONDPG',MODEL_FIELD_OBRIGAT,.T.)
	oStZZ4:SetProperty("ZZ4_CONDPG",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"IIF(INCLUI .OR. ALTERA,.T.,.F.)"))

	oModel:AddGrid("ZZ4DETAIL","ZZ4MASTER",oStZZ4)

	//Adiciona o relacionamento da grid com o cabeçario
	//oModel:SetRelation('ZZ4DETAIL',{{'ZZ4_FILIAL','xFilial("ZZ4")'}})
	oModel:SetRelation('ZZ4DETAIL',{{'ZZ4_FILIAL','xFilial("ZZ4")'},{'ZZ4_CODVEN','ZZ4_CODVEN'},{'ZZ4_DTINI','ZZ4_DTINI'},{'ZZ4_DTFIM','ZZ4_DTFIM'}}, ZZ4->(IndexKey(3)))

	//Não será permitida duplicidade de registros para o mesmo período, parâmetro e grupo de produto
	oModel:GetModel("ZZ4DETAIL"):SetUniqueLine({'ZZ4_FILIAL','ZZ4_CONDPG','ZZ4_CODVEN','ZZ4_CODCLI','ZZ4_LOJA','ZZ4_DTINI','ZZ4_DTFIM'})

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZZ4_FILIAL','ZZ4_CONDPG','ZZ4_CODVEN','ZZ4_CODCLI','ZZ4_LOJA','ZZ4_DTINI','ZZ4_DTFIM'})

	//Permite salvar o GRID sem dados.
	oModel:GetModel("ZZ4DETAIL"):SetOptional(.T.)

	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

Return oModel
Static Function ForceValue(oModel)

	Local i,n

	//Só efetua a alteração do campo para inserção
	//If  oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. ;
		//		oModel:GetOperation() == MODEL_OPERATION_UPDATE

	//	FwFldPut("ZZ4_FILIAL",xFilial('ZZ4'),/*nLinha*/,oModel)
	//Endif

	If oModel:GetOperation() == MODEL_OPERATION_VIEW .OR. ;
			oModel:GetOperation() == MODEL_OPERATION_UPDATE


		M->ZZ4_NOMVEN := POSICIONE('SA3',1,xFilial('SA3')+ZZ4->ZZ4_CODVEN,'A3_NOME')
		oModel:LoadValue("ZZ4MASTER","ZZ4_NOMVEN",M->ZZ4_NOMVEN)

		n := oModel:GetModel():GetModel("ZZ4DETAIL"):Length()
		For i := 1 To n

			oModel:GetModel():GetModel("ZZ4DETAIL"):GoLine(i)
			oModel:GetModel():GetModel("ZZ4DETAIL"):SetLine(i)

			//oModel:LoadValue("ZZ4DETAIL","ZZ4_NOMVEN",Posicione("SA3",1,xFilial("SA3")+oModel:GetValue("ZZ4DETAIL", "ZZ4_CODVEN"),"A3_NOME"))
			oModel:LoadValue("ZZ4DETAIL","ZZ4_NOMCLI",Posicione("SA1",1,xFilial("SA1")+oModel:GetValue("ZZ4DETAIL", "ZZ4_CODCLI")+oModel:GetValue("ZZ4DETAIL", "ZZ4_LOJA"),"A1_NOME"))
			oModel:LoadValue("ZZ4DETAIL","ZZ4_DESCPG",Posicione("SE4",1,xFilial("SE4")+oModel:GetValue("ZZ4DETAIL", "ZZ4_CONDPG"),"E4_DESCRI"))

		Next i

		oModel:GetModel():GetModel("ZZ4DETAIL"):GoLine(1)
		oModel:GetModel():GetModel("ZZ4DETAIL"):SetLine(1)

	Endif

Return


//===========================================
//View com os dados apresentados em tela	=
//===========================================
Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel  := FWLoadModel("FIBEST4")

	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStrZZ4 := FWFormStruct(2,'ZZ4')
	Local oStrCab := Nil

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()

	//Seta o modelo
	oView:SetModel(oModel)

	//Criando uma estrutura para o cabeçario
	oStrCab := FWFormViewStruct():New()

	//Adicionando um campo a estrutura
	//oStrCab:AddField('ZZ4_FILIAL','01','Filial','Filial',,'C')
	oStrCab:AddField('ZZ4_CODVEN'	,'01','Cod. Vend.'		,'Cod. Vend.'		,,'C')
	oStrCab:AddField('ZZ4_NOMVEN'	,'02','Nome Vend.'		,'Nome Vend.' 		,,'C')
	oStrCab:AddField('ZZ4_DTINI'	,'03','Data Inicial'	,'Data Inicial'		,,'D')
	oStrCab:AddField('ZZ4_DTFIM'	,'04','Data Final'		,'Data Final'		,,'D')

	//adicionando filtro F3
	oStrCab:SetProperty('ZZ4_CODVEN',MVC_VIEW_LOOKUP,'SA3')

	//Removendo campos da view - grid
	oStrZZ4:RemoveField('ZZ4_FILIAL')
	oStrZZ4:RemoveField('ZZ4_CODVEN')
	oStrZZ4:RemoveField('ZZ4_NOMVEN')
	oStrZZ4:RemoveField('ZZ4_DTINI')
	oStrZZ4:RemoveField('ZZ4_DTFIM')

	//Atribuindo formulários para interface
	oView:AddField('View_CABE',oStrCab,'ZZ4MASTER')
	oView:AddGrid('View_ZZ4'  ,oStrZZ4,'ZZ4DETAIL')

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("SUPERIOR",020)
	oView:CreateHorizontalBox("INFERIOR",080)

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("View_CABE","SUPERIOR")
	oView:SetOwnerView("View_ZZ4" ,"INFERIOR")

	oView:EnableTitleView("View_ZZ4","Regras - "+cTitulo)

Return oView


/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da alteração de qualquer campo do modelo. (requer retorno lógico)
MODELPOS 			Na validação total do modelo (requer retorno lógico)

FORMPRE 			Antes da alteração de qualquer campo do formulário. (requer retorno lógico)
FORMPOS 			Na validação total do formulário (requer retorno lógico)

FORMLINEPRE 		Antes da alteração da linha do formulário GRID. (requer retorno lógico)
FORMLINEPOS 		Na validação total da linha do formulário GRID. (requer retorno lógico)

MODELCOMMITTTS 		Apos a gravação total do modelo e dentro da transação
MODELCOMMITNTTS 	Apos a gravação total do modelo e fora da transação

FORMCOMMITTTSPRE 	Antes da gravação da tabela do formulário
FORMCOMMITTTSPOS 	Apos a gravação da tabela do formulário

FORMCANCEL 			No cancelamento do botão.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formulário ou model, conforme o caso.
PARAMIXB[2] - Id do local de execução do ponto de entrada
PARAMIXB[3] - Id do formulário

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid

*/
/*
-------------------------------------------------------------------------------------------------------------------------
Rotina: MD_RESERVA
Descri: Rotina utilizada para utilizar os pontos de entradas disponiveis nas telas MVC
-------------------------------------------------------------------------------------------------------------------------
*/
User Function FIBEST4M()

	Local aParam		:= PARAMIXB
	Local lRet      	:= .T.
	Local oObj      	:= aParam[1] // este é o model carregado
	Local cIdPonto  	:= aParam[2] //Conjunto de string que identifica o momento que a rotina esta sendo chamada.
	Local aArea     	:= GetArea()
	Local oModel	    := FWModelActive()
	Local cZZ4_CODVEN
	Local cZZ4_CODCLI
	Local cZZ4_LOJA
	Local cZZ4_CONDPG
	Local cZZ4_DTINI
	Local cZZ4_DTFIM
	Local i,n
	Local cAliasSql
	Local cSql

	If cIdPonto ==  'MODELCOMMITTTS'

		//If oModel:GetOperation() == 4 //Alteração
		//	FWMsgRun(, {|| MANUALT(oModel:GetOperation(),oModel,.T.)},"Regra de Condição de Pagamento","Validando a Regra de Condição de Pagamento..." )
		//EndIf

	ElseIf cIdPonto ==  'FORMLINEPRE'

	ElseIf cIdPonto ==  'MODELPRE'

	ElseIf cIdPonto ==  'FORMPOS'

		//If PARAMIXB[3] == "ZZ4DETAIL"
		If oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4 //inclusão e alteração

			cZZ4_CODVEN := oModel:GetValue('ZZ4MASTER', 'ZZ4_CODVEN')
			cZZ4_DTINI  := DtoS(oModel:GetValue('ZZ4MASTER', 'ZZ4_DTINI'))
			cZZ4_DTFIM  := DtoS(oModel:GetValue('ZZ4MASTER', 'ZZ4_DTFIM'))
			n := oModel:GetModel():GetModel("ZZ4DETAIL"):Length()

			For i := 1 To n

				oModel:GetModel():GetModel("ZZ4DETAIL"):GoLine(i)
				oModel:GetModel():GetModel("ZZ4DETAIL"):SetLine(i)

				
				cZZ4_CONDPG := oModel:GetValue('ZZ4DETAIL', 'ZZ4_CONDPG')
				cZZ4_CODCLI := oModel:GetValue('ZZ4DETAIL', 'ZZ4_CODCLI')
				cZZ4_LOJA   := oModel:GetValue('ZZ4DETAIL', 'ZZ4_LOJA')

				cAliasSql := GetNextAlias()
				cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
				cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
				cSql += "WHERE "+CRLF
				cSql += "	    ZZ4.ZZ4_FILIAL = '"+xFilial("ZZ4")+"'    AND "+CRLF
				cSql += "		ZZ4.ZZ4_CODVEN = '"+cZZ4_CODVEN+"'       AND "+CRLF
				cSql += "		ZZ4.ZZ4_CODCLI = '"+cZZ4_CODCLI+"' 	     AND "+CRLF
				cSql += "		ZZ4.ZZ4_LOJA   = '"+cZZ4_LOJA+"' 		 AND "+CRLF
				cSql += "		ZZ4.ZZ4_CONDPG = '"+cZZ4_CONDPG+"'       AND "+CRLF
				cSql += "      "+ValToSql(cZZ4_DTINI)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
				cSql += "      "+ValToSql(cZZ4_DTFIM)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
				cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
				cSql += "ORDER BY ZZ4.ZZ4_DTINI"
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

				If (cAliasSql)->RECNOZZ4 > 0
					Help(,,"Já Gravei",,"Não é permitido duplicidade de registros. Ou inserção de Regras iguais dentro do mesmo periodo de Vigência."+CRLF+;
						"Linha: "+cValToChar(i)+CRLF+;
						"Cod. Vend. + Cod. Cliente + Loja Cliente + Cond. Pagt. + Periodo de Vigência.",1,0)

					RestArea(aArea)
					(cAliasSql)->(DbCloseArea())
					Return .F.
				EndIf
				(cAliasSql)->(DbCloseArea())

			Next i

			//CASO ESTEJA CADASTRANDO UM PERIDO COM O GRID VAZIO VERIFICA SE JA EXISTE A ZZ4_CONDPG, ZZ4_DTINI e ZZ4_DTFIM
			If n == 0
				cAliasSql := GetNextAlias()
				cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
				cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
				cSql += "WHERE "+CRLF
				cSql += "	    ZZ4.ZZ4_FILIAL = '"+xFilial("ZZ4")+"'    AND "+CRLF
				cSql += "		ZZ4.ZZ4_CODVEN = ' '       				 AND "+CRLF
				cSql += "		ZZ4.ZZ4_CODCLI = ' ' 	    			 AND "+CRLF
				cSql += "		ZZ4.ZZ4_LOJA   = ' ' 		 			 AND "+CRLF
				cSql += "		ZZ4.ZZ4_CONDPG = '"+cZZ4_CONDPG+"'       AND "+CRLF
				cSql += "      "+ValToSql(cZZ4_DTINI)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
				cSql += "      "+ValToSql(cZZ4_DTFIM)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
				cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
				cSql += "ORDER BY ZZ4.ZZ4_DTINI"
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

				If (cAliasSql)->RECNOZZ4 > 0
					Help(,,"Já Gravei",,"Não é permitido duplicidade de registros. Ou inserção de Regras iguais dentro do mesmo periodo de Vigência."+CRLF+;
						"Linha: "+cValToChar(i)+CRLF+;
						"Cod. Vend. + Cod. Cliente + Loja Cliente + Cond. Pagt. + Periodo de Vigência.",1,0)

					RestArea(aArea)
					(cAliasSql)->(DbCloseArea())
					Return .F.
				EndIf
				(cAliasSql)->(DbCloseArea())
			EndIf

		EndIf

		If oModel:GetOperation() == 4 //Alteração
			FWMsgRun(, {|| lRet := MANUALT(oModel:GetOperation(),oModel,.T.)},"Regra de Condição de Pagamento","Validando a Regra de Condição de Pagamento..." )
		EndIf
		//EndIf

	ElseIf cIdPonto ==  'FORMPRE'

		//se for alteração não deixa adicionar mais linhas
		//adição de registros só por meio de Inclusão
		If Type("PARAMIXB[4]") == "C"
			If PARAMIXB[4] == "ISENABLE"
				If oModel:GetOperation() == 4 //alterar
					oModel:GetModel():GetModel("ZZ4DETAIL"):SetMaxLine(oModel:GetModel():GetModel("ZZ4DETAIL"):Length())
				EndIf
			EndIf
		EndIf

	ElseIf cIdPonto ==  'MODELVLDACTIVE'

	ElseIf cIdPonto ==  'BUTTONBAR'

	EndIf

	RestArea(aArea)

Return lRet


//===================================================================================================
//CONSULTA PADRÃO PERSONALIZADA																		=
//PEDIDO DE VENDA = C5_CONDPAG																		=
//ORÇAMENTO = CJ_CONDPAG																			=
//As Condições de Pagamento apresentadas na consulta padrão no Pedido ou Orçamento de Venda 		=	
//serão filtradas considerando a relação 															=
//"Vendedor x Cliente", ou somente o "Vendedor", ou ainda 											=
//somente o "Cliente", sempre considerando o período de validade. 									=
//Uma condição de pagamento sem qualquer destes parâmetros será válida para todos os pedidos ou		=
//orçamentos.																						=
//O resultado final do filtro será uma lista das condições de pagamento resultante da combinação de	=
//todas as regras aplicáveis.																		=
//===================================================================================================
User Function FIBEST4F(lValida)

	Local aArea 		:= GetArea()
	Local cVarRet
	Local cVarChave
	Local cSql
	Local cAliasSql
	Local cZZ4_CODVEN	:= ""
	Local cZZ4_CODCLI	:= ""
	Local cZZ4_LOJA		:= ""
	Local aCondPag		:= {}
	Local cExpFiltro	:= ""
	Local cFiltro
	Local cChaveZZ4
	Local cContDigit
	Local nRet			:= 0
	Local nPosCond		:= 0
	Local i

	Default lValida 	:= .F.

	If FunName() == "MATA415" //chamada do Orçamento
		cVarRet   := "M->CJ_CONDPAG"
		cVarChave := "M->CJ_YCHVZZ4"

		If Empty(M->CJ_CLIENTE)
			MsgStop("Favor informar o Cliente.")
			Return .F.
		EndIf
		If Empty(M->CJ_YVEND)
			MsgStop("Favor informar o Vendedor.")
			Return .F.
		EndIf

		cZZ4_CODVEN := M->CJ_YVEND
		cZZ4_CODCLI := M->CJ_CLIENTE
		cZZ4_LOJA   := M->CJ_LOJA

	ElseIf FunName() == "MATA410" //chamada do Pedido de Venda
		cVarRet   := "M->C5_CONDPAG"
		cVarChave := "M->C5_YCHVZZ4"

		If Empty(M->C5_CLIENTE)
			MsgStop("Favor informar o Cliente.")
			Return .F.
		EndIf
		If Empty(M->C5_VEND1)
			MsgStop("Favor informar o Vendedor.")
			Return .F.
		EndIf

		cZZ4_CODVEN := M->C5_VEND1
		cZZ4_CODCLI := M->C5_CLIENTE
		cZZ4_LOJA   := M->C5_LOJACLI

	EndIf

	DbSelectArea("ZZ4")
	ZZ4->(DbSetOrder(1))

	//Vendedor x Cliente
	cAliasSql := Nil
	cAliasSql := GetNextAlias()
	cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
	cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
	cSql += "WHERE "+CRLF
	cSql += "	    ZZ4.ZZ4_FILIAL = '"+xFilial("ZZ4")+"'   AND "+CRLF
	cSql += "		ZZ4.ZZ4_CODVEN = '"+cZZ4_CODVEN+"'      AND "+CRLF
	cSql += "		ZZ4.ZZ4_CODCLI = '"+cZZ4_CODCLI+"' 	    AND "+CRLF
	cSql += "		ZZ4.ZZ4_LOJA   = '"+cZZ4_LOJA+"' 		AND "+CRLF
	cSql += "      "+ValToSql(dDataBase)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
	cSql += "      "+ValToSql(dDataBase)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
	cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
	cSql += "ORDER BY ZZ4.ZZ4_DTINI"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

	If !(cAliasSql)->(Eof())
		While !(cAliasSql)->(Eof())

			ZZ4->(DbGoTo((cAliasSql)->RECNOZZ4))
			cChaveZZ4 := ZZ4->ZZ4_FILIAL+ZZ4->ZZ4_CODVEN+ZZ4->ZZ4_CODCLI+ZZ4->ZZ4_LOJA+ZZ4->ZZ4_CONDPG+DtoS(ZZ4->ZZ4_DTINI)+DtoS(ZZ4->ZZ4_DTFIM)

			cExpFiltro += ZZ4->ZZ4_CONDPG
			aAdd(aCondPag, {ZZ4->ZZ4_CONDPG,cChaveZZ4})

			(cAliasSql)->(DbSkip())

			If !(cAliasSql)->(Eof())
				cExpFiltro += "/"
			EndIf

		EndDo
	EndIf
	(cAliasSql)->(DbCloseArea())

	//Somente o "Vendedor"
	cAliasSql := Nil
	cAliasSql := GetNextAlias()
	cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
	cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
	cSql += "WHERE "+CRLF
	cSql += "	    ZZ4.ZZ4_FILIAL = '"+xFilial("ZZ4")+"'   AND "+CRLF
	cSql += "		ZZ4.ZZ4_CODVEN = '"+cZZ4_CODVEN+"'      AND "+CRLF
	cSql += "		ZZ4.ZZ4_CODCLI = '' 	    			AND "+CRLF
	cSql += "		ZZ4.ZZ4_LOJA   = '' 					AND "+CRLF
	cSql += "      "+ValToSql(dDataBase)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
	cSql += "      "+ValToSql(dDataBase)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
	cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
	cSql += "ORDER BY ZZ4.ZZ4_DTINI"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

	If !(cAliasSql)->(Eof())
		While !(cAliasSql)->(Eof())

			ZZ4->(DbGoTo((cAliasSql)->RECNOZZ4))
			cChaveZZ4 := ZZ4->ZZ4_FILIAL+ZZ4->ZZ4_CODVEN+ZZ4->ZZ4_CODCLI+ZZ4->ZZ4_LOJA+ZZ4->ZZ4_CONDPG+DtoS(ZZ4->ZZ4_DTINI)+DtoS(ZZ4->ZZ4_DTFIM)

			If !Empty(cExpFiltro)
				cExpFiltro += "/"
			Endif

			cExpFiltro += ZZ4->ZZ4_CONDPG
			aAdd(aCondPag, {ZZ4->ZZ4_CONDPG,cChaveZZ4})

			(cAliasSql)->(DbSkip())

			If !(cAliasSql)->(Eof())
				cExpFiltro += "/"
			EndIf

		EndDo
	EndIf
	(cAliasSql)->(DbCloseArea())

	//Somente o "Cliente"
	cAliasSql := Nil
	cAliasSql := GetNextAlias()
	cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
	cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
	cSql += "WHERE "+CRLF
	cSql += "	    ZZ4.ZZ4_FILIAL = '"+xFilial("ZZ4")+"'   AND "+CRLF
	cSql += "		ZZ4.ZZ4_CODVEN = ''                     AND "+CRLF
	cSql += "		ZZ4.ZZ4_CODCLI = '"+cZZ4_CODCLI+"' 	    AND "+CRLF
	cSql += "		ZZ4.ZZ4_LOJA   = '"+cZZ4_LOJA+"' 		AND "+CRLF
	cSql += "      "+ValToSql(dDataBase)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
	cSql += "      "+ValToSql(dDataBase)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
	cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
	cSql += "ORDER BY ZZ4.ZZ4_DTINI"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

	If !(cAliasSql)->(Eof())
		While !(cAliasSql)->(Eof())

			ZZ4->(DbGoTo((cAliasSql)->RECNOZZ4))
			cChaveZZ4 := ZZ4->ZZ4_FILIAL+ZZ4->ZZ4_CODVEN+ZZ4->ZZ4_CODCLI+ZZ4->ZZ4_LOJA+ZZ4->ZZ4_CONDPG+DtoS(ZZ4->ZZ4_DTINI)+DtoS(ZZ4->ZZ4_DTFIM)

			If !Empty(cExpFiltro)
				cExpFiltro += "/"
			Endif

			cExpFiltro += ZZ4->ZZ4_CONDPG
			aAdd(aCondPag, {ZZ4->ZZ4_CONDPG,cChaveZZ4})

			(cAliasSql)->(DbSkip())

			If !(cAliasSql)->(Eof())
				cExpFiltro += "/"
			EndIf

			(cAliasSql)->(DbSkip())
		EndDo
	EndIf
	(cAliasSql)->(DbCloseArea())

	//Uma condição de pagamento sem qualquer destes parâmetros será válida para todos os pedidos ou	orçamentos
	If Empty(aCondPag)
		cAliasSql := Nil
		cAliasSql := GetNextAlias()
		cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
		cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
		cSql += "WHERE "+CRLF
		cSql += "	    ZZ4.ZZ4_FILIAL = '"+xFilial("ZZ4")+"'   AND "+CRLF
		cSql += "		ZZ4.ZZ4_CODVEN = ''                     AND "+CRLF
		cSql += "		ZZ4.ZZ4_CODCLI = '' 	     			AND "+CRLF
		cSql += "		ZZ4.ZZ4_LOJA   = '' 		 			AND "+CRLF
		cSql += "      "+ValToSql(dDataBase)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
		cSql += "      "+ValToSql(dDataBase)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
		cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
		cSql += "ORDER BY ZZ4.ZZ4_DTINI"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

		If !(cAliasSql)->(Eof())
			While !(cAliasSql)->(Eof())

				ZZ4->(DbGoTo((cAliasSql)->RECNOZZ4))
				cChaveZZ4 := ZZ4->ZZ4_FILIAL+ZZ4->ZZ4_CODVEN+ZZ4->ZZ4_CODCLI+ZZ4->ZZ4_LOJA+ZZ4->ZZ4_CONDPG+DtoS(ZZ4->ZZ4_DTINI)+DtoS(ZZ4->ZZ4_DTFIM)

				cExpFiltro += ZZ4->ZZ4_CONDPG
				aAdd(aCondPag, {ZZ4->ZZ4_CONDPG,cChaveZZ4})

				(cAliasSql)->(DbSkip())

				If !(cAliasSql)->(Eof())
					cExpFiltro += "/"
				EndIf

			EndDo
		EndIf
		(cAliasSql)->(DbCloseArea())

	EndIf
	ZZ4->(DbCloseArea())

	If lValida

		nPosCond := 0
		cContDigit := &(cVarRet)
		For i := 1 To Len(aCondPag)
			If aCondPag[i,1] == cContDigit
				nPosCond := i
				Exit
			EndIf
		Next i

		If nPosCond > 0

			DbSelectArea("SE4")
			SE4->(DbSetOrder(1))
			If SE4->(DbSeek(xFilial("SE4")+aCondPag[nPosCond,1]))
				&(cVarRet)   := SE4->E4_CODIGO
				&(cVarChave) := aCondPag[nPosCond,2]
			Else
				&(cVarRet)   := Space(TamSX3("E4_CODIGO")[1])
				&(cVarChave) := ""
				MsgStop("Condição de Pagamento Invalida!")
				Return .F.
			EndIf

		Else
			&(cVarRet)   := Space(TamSX3("E4_CODIGO")[1])
			&(cVarChave) := ""
			MsgStop("Condição de Pagamento Invalida!")
			Return .F.
		EndIf

	Else
		cFiltro := 'E4_CODIGO $ "'+cExpFiltro+'"'
		ConPad1(,,,"ZSE4",,,.F.,,,,,,cFiltro)
	EndIf

	RestArea(aArea)

Return .T.


//===============================================================================================
//Alteração/Exclusão: Bloquear se houver Notas Fiscais impactadas pela alteração ou exclusão	= 
//===============================================================================================
Static Function MANUALT(nOpc,oModel,lGrava)

	Local i
	Local cZZ4_CODVEN
	Local cZZ4_CONDPG
	Local cZZ4_CODCLI
	Local cZZ4_LOJA
	Local dZZ4_DTINI
	Local dZZ4_DTFIM
	Local cCONDPGNew
	Local cSql
	Local cAliasVal1
	Local n 			:= oModel:GetModel():GetModel("ZZ4DETAIL"):Length()
	Local cChaveZZ4
	Local cNChaveZZ4
	Local lRet			:= .T.

	Default lGrava 		:= .F.

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())

	For i := 1 To n

		oModel:GetModel():GetModel("ZZ4DETAIL"):GoLine(i)
		oModel:GetModel():GetModel("ZZ4DETAIL"):SetLine(i)

		cZZ4_CODVEN := oModel:GetValue('ZZ4MASTER', 'ZZ4_CODVEN') //busco da grid pq não pode ser alterado
		
		cZZ4_CONDPG := ZZ4->ZZ4_CONDPG
		cCONDPGNew  := oModel:GetValue('ZZ4DETAIL', 'ZZ4_CONDPG')//busco da grid pra comparar se alterou a condição de pagamento

		cZZ4_CODCLI := oModel:GetValue('ZZ4DETAIL', 'ZZ4_CODCLI')//busco da grid pq não pode ser alterado
		cZZ4_LOJA   := oModel:GetValue('ZZ4DETAIL', 'ZZ4_LOJA')//busco da grid pq não pode ser alterado
		dZZ4_DTINI  := oModel:GetValue('ZZ4MASTER', 'ZZ4_DTINI')//busco da grid pq não pode ser alterado
		dZZ4_DTFIM  := oModel:GetValue('ZZ4MASTER', 'ZZ4_DTFIM')//busco da grid pq não pode ser alterado

		cChaveZZ4 := xFilial("ZZ2")+cZZ4_CODVEN+cZZ4_CODCLI+cZZ4_LOJA+cZZ4_CONDPG+DtoS(dZZ4_DTINI)+DtoS(dZZ4_DTFIM)
		cNChaveZZ4 := xFilial("ZZ2")+cZZ4_CODVEN+cZZ4_CODCLI+cZZ4_LOJA+cCONDPGNew+DtoS(dZZ4_DTINI)+DtoS(dZZ4_DTFIM)

		cAliasVal1 := GetNextAlias()
		cSql := "SELECT SC5.R_E_C_N_O_ AS RECNOSC5 "+CRLF
		cSql += "FROM "+RetSqlName("SC5")+" SC5 "+CRLF
		cSql += "WHERE "+CRLF
		cSql += "   SC5.C5_YCHVZZ4 = '"+cChaveZZ4+"' AND "+CRLF
		cSql += "   SC5.D_E_L_E_T_ = '' "+CRLF
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasVal1,.T.,.F.)

		If !(cAliasVal1)->(Eof())
			While !(cAliasVal1)->(Eof())

				SC5->(DbGoTo((cAliasVal1)->RECNOSC5)) //posiciona no registro da SC5 para verificar a condição de pagamento

				//VERIFICA SE TEM NOTA FISCAL EMITIDA
				//SE TIVER BLOQUEIA A ALTERAÇÃO
				//SE NÃO TIVER NOTA, ALTERA A CONDIÇÃO DE PAGAMENTO
				If SC5->C5_CONDPAG != cCONDPGNew
					If !Empty(SC5->C5_NOTA+SC5->C5_SERIE)

						Help(,,"Nota Emitida",,"Não é possivel realizar esta alteração, pois ja existe Nota Fiscal emitida para esta regra de Condição de Pagamento."+CRLF+;
							"Linha: "+cValToChar(i),1,0)

						(cAliasVal1)->(DbCloseArea())
						Return .F.
					EndIf

					If lGrava
						RecLock("SC5", .F.)
						SC5->C5_CONDPAG := cCONDPGNew
						SC5->C5_YCHVZZ4 := cNChaveZZ4
						SC5->(MsUnlock())
					EndIf

				EndIf

				(cAliasVal1)->(DbSkip())
			EndDo

			//VERIFICA SE TEM ALGUM ORC. CRIADO E JA FAZ A MANUTENÇÃO NELE
			//VERIFICO SE NOS MESMO PARAMETROS QUE ACHEI UM PEDIDO DE VENDA EXISTE ALGUM ORC. QUE AINDA NÃO GEROU O PEDIDO DE VENDA
			//VERIFICO NESTE MOMENTO POIS PODE TER ALGUM ORC. CRIADO QUE AINDA NÃO GEROU PEDIDO DE VENDA
			If lGrava
				MANUORC(cChaveZZ4,cCONDPGNew,cNChaveZZ4,lGrava)
			EndIf

		Else

			//VERIFICA SE TEM ALGUM ORC. CRIADO E JA FAZ A MANUTENÇÃO NELE
			//VERIFICO NESTE MOMENTO POIS PODE TER ALGUM ORC. CRIADO QUE AINDA NÃO GEROU PEDIDO DE VENDA
			If lGrava
				MANUORC(cChaveZZ4,cCONDPGNew,cNChaveZZ4,.T.) //FORÇA A ALTERAÇÃO, POIS NESTE MOMENTO NÃO TEMOS PEDIDO DE VENDA CRIADO
			EndIf

		EndIf
		(cAliasVal1)->(DbCloseArea())

	Next i

Return lRet
//VERIFICA SE TEM ALGUM ORC. CRIADO E JA FAZ A MANUTENÇÃO NELE
Static Function MANUORC(cChaveZZ4,cCONDPGNew,cNChaveZZ4,lGrava)

	Local cAliasVal1
	Local cSql
	Local lRet := .F.

	DbSelectArea("SCJ")
	SCJ->(DbSetOrder(1))
	SCJ->(DbGoTop())

	DbSelectArea("SCK")
	SCK->(DbSetOrder(1))
	SCK->(DbGoTop())

	//PROCURO SE EXISTE ORÇAMENTO
	//PROCURO NO ORÇAMENTO PELA CHAVE INFORMADA
	cAliasVal1 := GetNextAlias()
	cSql := "SELECT SCJ.R_E_C_N_O_ AS RECNOSCJ "+CRLF
	cSql += "FROM "+RetSqlName("SCJ")+" SCJ "+CRLF
	cSql += "WHERE "+CRLF
	cSql += "   SCJ.CJ_YCHVZZ4 = '"+cChaveZZ4+"' AND "+CRLF
	cSql += "   SCJ.D_E_L_E_T_ = '' "+CRLF
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasVal1,.T.,.F.)

	If !(cAliasVal1)->(Eof())
		While !(cAliasVal1)->(Eof())

			SCJ->(DbGoTo((cAliasVal1)->RECNOSCJ)) //posiciona do registro da SCJ para verificar a condição de pagamento

			If lGrava
				RecLock("SCJ", .F.)
				SCJ->CJ_CONDPAG := cCONDPGNew
				SCJ->CJ_YCHVZZ4 := cNChaveZZ4
				SCJ->(MsUnLock())
			EndIf

			(cAliasVal1)->(DbSkip())
		EndDo
	EndIf
	(cAliasVal1)->(DbCloseArea())

Return lRet


//===============================================
//IMPORTAÇÃO DE REGRAS DE CONDIÇÃO DE PAGAMENTO	=
//ARQUIVO CSV									=
//===============================================
User Function FIBEST4I()

	Local aParamBox	:= {}
	Local aRet     	:= {}
	Local cArquivo 	:= Padr("",150)

	Private oProcess

	aAdd(aParamBox, {6,"Arquivo",cArquivo,"",,"",90,.T.,"Arquivos .CSV |*.CSV","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})
	//aAdd(aParamBox, {2,"Tipo Importação",1,{"Inclusão", "Manutenção"},60,"",.F.})
	aAdd(aParamBox, {2,"Tipo Importação",1,{"Inclusão"},60,"",.F.})

	If ParamBox(aParamBox, "Regras de Condição de Pagamento", @aRet)
		cArquivo := AllTrim(MV_PAR01)

		oProcess := MsNewProcess():New({|| F4I001(cArquivo)},"Regras de Condição de Pagamento","Validando a Estrutura do Arquivo...",.F.)
		oProcess:Activate()

	EndIf

Return
Static Function F4I001(cArquivo)

	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local cGetDeli	:= ";" //delimitador
	Local i
	Local aArea		:= GetArea()
	Local cAliasSql
	Local cSql
	Local cZZ4_FILIAL
	Local cZZ4_CODVEN
	Local cZZ4_CODCLI
	Local cZZ4_LOJA
	Local cZZ4_CONDPG
	Local dZZ4_DTINI
	Local dZZ4_DTFIM
	Local cZZ4_OBS
	Local lGravaZZ4	:= .T.

	If File(cArquivo)

		//Lendo o arquivo e reunindo as informaçãoes nos array aCampos/aDados
		FT_FUSE(cArquivo)
		oProcess:SetRegua1(FT_FLASTREC()-1)
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()

			If lPrim
				aCampos := Separa(cLinha,cGetDeli,.T.)
				lPrim := .F.
			Else
				oProcess:IncRegua1("Abrindo Arquivo...")
				aAdd(aDados, Separa(cLinha,cGetDeli,.T.))
			EndIf

			FT_FSKIP()
		EndDo
		FT_FUSE()

		oProcess:SetRegua1(0)
		oProcess:IncRegua1("Processando Dados do Arquivo...")

		oProcess:SetRegua2(Len(aDados))
		For i := 1 To Len(aDados)

			oProcess:IncRegua2("Processando Dados do Arquivo...")

			cZZ4_FILIAL := aDados[i,AScan(aCampos,"ZZ4_FILIAL")]
			cZZ4_CODVEN := aDados[i,AScan(aCampos,"ZZ4_CODVEN")]
			cZZ4_CODCLI := aDados[i,AScan(aCampos,"ZZ4_CODCLI")]
			cZZ4_LOJA 	:= aDados[i,AScan(aCampos,"ZZ4_LOJA")]
			cZZ4_CONDPG := aDados[i,AScan(aCampos,"ZZ4_CONDPG")]
			dZZ4_DTINI 	:= aDados[i,AScan(aCampos,"ZZ4_DTINI")]
			dZZ4_DTFIM 	:= aDados[i,AScan(aCampos,"ZZ4_DTFIM")]
			cZZ4_OBS	:= aDados[i,AScan(aCampos,"ZZ4_OBS")]

			If Empty(cZZ4_FILIAL)
				cZZ4_FILIAL := xFilial("ZZ4")
			Else
				cZZ4_FILIAL := AllTrim(cZZ4_FILIAL)+Space(TamSX3("ZZ4_FILIAL")[1]-Len(AllTrim(cZZ4_FILIAL)))
			EndIf
			If Empty(cZZ4_CODVEN)
				cZZ4_CODVEN := Space(TamSX3("ZZ4_CODVEN")[1])
			Else
				cZZ4_CODVEN := AllTrim(cZZ4_CODVEN)+Space(TamSX3("ZZ4_CODVEN")[1]-Len(AllTrim(cZZ4_CODVEN)))
			EndIf
			If Empty(cZZ4_CODCLI)
				cZZ4_CODCLI := Space(TamSX3("ZZ4_CODCLI")[1])
			Else
				cZZ4_CODCLI := AllTrim(cZZ4_CODCLI)+Space(TamSX3("ZZ4_CODCLI")[1]-Len(AllTrim(cZZ4_CODCLI)))
			EndIf
			If Empty(cZZ4_LOJA)
				cZZ4_LOJA := Space(TamSX3("ZZ4_LOJA")[1])
			Else
				cZZ4_LOJA := AllTrim(cZZ4_LOJA)+Space(TamSX3("ZZ4_LOJA")[1]-Len(AllTrim(cZZ4_LOJA)))
			EndIf
			If Empty(cZZ4_CONDPG)
				//cZZ4_CONDPG := Space(TamSX3("ZZ4_CONDPG")[1])
				MsgStop("Condição de Pagamento não informada, Linha: "+cValToChar(i+1))
				Loop
			Else
				cZZ4_CONDPG := AllTrim(cZZ4_CONDPG)+Space(TamSX3("ZZ4_CONDPG")[1]-Len(AllTrim(cZZ4_CONDPG)))
			EndIf
			If ValType(dZZ4_DTINI) == "C"
				If "/" $ dZZ4_DTINI
					dZZ4_DTINI := CtoD(dZZ4_DTINI)
				Else
					dZZ4_DTINI := StoD(dZZ4_DTINI)
				EndIf
			EndIf
			If Empty(dZZ4_DTINI)
				dZZ4_DTINI := dDataBase
			EndIf
			If ValType(dZZ4_DTFIM) == "C"
				If "/" $ dZZ4_DTFIM
					dZZ4_DTFIM := CtoD(dZZ4_DTFIM)
				Else
					dZZ4_DTFIM := StoD(dZZ4_DTFIM)
				EndIf
			EndIf
			If Empty(dZZ4_DTFIM)
				dZZ4_DTFIM := dDataBase + 30
			EndIf

			cAliasSql := Nil
			cAliasSql := GetNextAlias()
			cSql := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
			cSql += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
			cSql += "WHERE "+CRLF
			cSql += "	    ZZ4.ZZ4_FILIAL = '"+cZZ4_FILIAL+"'       AND "+CRLF
			cSql += "		ZZ4.ZZ4_CODVEN = '"+cZZ4_CODVEN+"'       AND "+CRLF
			cSql += "		ZZ4.ZZ4_CODCLI = '"+cZZ4_CODCLI+"' 	     AND "+CRLF
			cSql += "		ZZ4.ZZ4_LOJA   = '"+cZZ4_LOJA+"' 		 AND "+CRLF
			cSql += "		ZZ4.ZZ4_CONDPG = '"+cZZ4_CONDPG+"' 		 AND "+CRLF
			//cSql += "      "+ValToSql(dZZ4_DTINI)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
			//cSql += "      "+ValToSql(dZZ4_DTFIM)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
			cSql += "      "+ValToSql(dZZ4_DTINI)+" >= ZZ4.ZZ4_DTINI AND "+CRLF
			cSql += "      "+ValToSql(dZZ4_DTINI)+" <= ZZ4.ZZ4_DTFIM AND "+CRLF
			cSql += "		ZZ4.D_E_L_E_T_ = '' "+CRLF
			cSql += "ORDER BY ZZ4.ZZ4_DTINI"
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

			If (cAliasSql)->RECNOZZ4 > 0

				//Help(,,"Já Gravei",,"Não é permitido duplicidade de registros. Ou inserção de Regras iguais dentro do mesmo periodo de Vigência."+CRLF+;
					//	"Linha: "+cValToChar(i+1)+CRLF+;
					//	"Cod. Vend. + Cod. Cliente + Loja Cliente + Cond. Pagt. + Periodo de Vigência.",1,0)

				//Encerramento automatico para a regra posicionada
				lGravaZZ4 := .T.

				If lGravaZZ4 .AND. !Empty(cZZ4_CODVEN)
					DbSelectArea("SA3")
					SA3->(DbSetOrder(1))
					If !SA3->(DbSeek(xFilial("SA3")+cZZ4_CODVEN))
						Help(,,"No Recno",,"Cod. Vend. não encontrado no Cadastro de Vendedores(MATA040)."+CRLF+;
							"Linha do Arquivo: "+cValToChar(i+1),1,0)
						lGravaZZ4 := .F.
					EndIf
				EndIf

				If lGravaZZ4 .AND. !Empty(cZZ4_CODCLI+cZZ4_LOJA)
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					If !SA1->(DbSeek(xFilial("SA1")+cZZ4_CODCLI+cZZ4_LOJA))
						Help(,,"No Recno",,"Cod. Cliente não encontrado no Cadastro de Clientes(MATA030)."+CRLF+;
							"Linha do Arquivo: "+cValToChar(i+1),1,0)
						lGravaZZ4 := .F.
					EndIf
				EndIf

				If lGravaZZ4 .AND. !Empty(cZZ4_CONDPG)
					DbSelectArea("SE4")
					SE4->(DbSetOrder(1))
					If !SE4->(DbSeek(xFilial("SE4")+cZZ4_CONDPG))
						Help(,,"No Recno",,"Cond. Pagt. não encontrado no Cadastro de Condição de Pagamento(MATA360)."+CRLF+;
							"Linha do Arquivo: "+cValToChar(i+1),1,0)
						lGravaZZ4 := .F.
					EndIf
				EndIf

				If lGravaZZ4

					ZZ4->(DbGoTo((cAliasSql)->RECNOZZ4))

					RecLock("ZZ4", .F.)
					ZZ4->ZZ4_DTFIM := dZZ4_DTINI - 1
					ZZ4->(MsUnLock())

					RecLock("ZZ4", .T.)
					ZZ4->ZZ4_FILIAL := cZZ4_FILIAL
					ZZ4->ZZ4_CODVEN := cZZ4_CODVEN
					ZZ4->ZZ4_CODCLI := cZZ4_CODCLI
					ZZ4->ZZ4_LOJA 	:= cZZ4_LOJA
					ZZ4->ZZ4_CONDPG := cZZ4_CONDPG
					ZZ4->ZZ4_DTINI 	:= dZZ4_DTINI
					ZZ4->ZZ4_DTFIM 	:= dZZ4_DTFIM
					ZZ4->ZZ4_OBS	:= cZZ4_OBS
					ZZ4->(MsUnlock())
				EndIf

			Else

				lGravaZZ4 := .T.

				If lGravaZZ4 .AND. !Empty(cZZ4_CODVEN)
					DbSelectArea("SA3")
					SA3->(DbSetOrder(1))
					If !SA3->(DbSeek(xFilial("SA3")+cZZ4_CODVEN))
						Help(,,"No Recno",,"Cod. Vend. não encontrado no Cadastro de Vendedores(MATA040)."+CRLF+;
							"Linha do Arquivo: "+cValToChar(i+1),1,0)
						lGravaZZ4 := .F.
					EndIf
				EndIf

				If lGravaZZ4 .AND. !Empty(cZZ4_CODCLI+cZZ4_LOJA)
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					If !SA1->(DbSeek(xFilial("SA1")+cZZ4_CODCLI+cZZ4_LOJA))
						Help(,,"No Recno",,"Cod. Cliente não encontrado no Cadastro de Clientes(MATA030)."+CRLF+;
							"Linha do Arquivo: "+cValToChar(i+1),1,0)
						lGravaZZ4 := .F.
					EndIf
				EndIf

				If lGravaZZ4 .AND. !Empty(cZZ4_CONDPG)
					DbSelectArea("SE4")
					SE4->(DbSetOrder(1))
					If !SE4->(DbSeek(xFilial("SE4")+cZZ4_CONDPG))
						Help(,,"No Recno",,"Cond. Pagt. não encontrado no Cadastro de Condição de Pagamento(MATA360)."+CRLF+;
							"Linha do Arquivo: "+cValToChar(i+1),1,0)
						lGravaZZ4 := .F.
					EndIf
				EndIf

				If lGravaZZ4
					RecLock("ZZ4", .T.)
					ZZ4->ZZ4_FILIAL := cZZ4_FILIAL
					ZZ4->ZZ4_CODVEN := cZZ4_CODVEN
					ZZ4->ZZ4_CODCLI := cZZ4_CODCLI
					ZZ4->ZZ4_LOJA 	:= cZZ4_LOJA
					ZZ4->ZZ4_CONDPG := cZZ4_CONDPG
					ZZ4->ZZ4_DTINI 	:= dZZ4_DTINI
					ZZ4->ZZ4_DTFIM 	:= dZZ4_DTFIM
					ZZ4->ZZ4_OBS	:= cZZ4_OBS
					ZZ4->(MsUnlock())
				EndIf

			EndIf
			(cAliasSql)->(DbCloseArea())

		Next i

	Else
		MsgStop("O Arquivo "+cArquivo+" não foi encontrado!")
		Return
	EndIf

	RestArea(aArea)

Return


//===========================================================
//PROGRAMA TEMPORARIO										=
//UNIFAICAÇÃO DAS TABELAS DE CONDIÇÃO DE PAGAMENTO - SE4	=
//===========================================================
User Function FIBEST4U(nParte)

	Local aParamBox	:= {}
	Local aRet     	:= {}
	Local cArquivo 	:= Padr("",150)

	Private oProcess

	If nParte == 1 //PARTE 1 - UNIFICAÇÃO DAS CONDIÇÕES DE PAGAMENTO

		aAdd(aParamBox, {6,"Arquivo",cArquivo,"",,"",90,.T.,"Arquivos .CSV |*.CSV","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})

		If ParamBox(aParamBox, "Regras de Condição de Pagamento", @aRet)
			cArquivo := AllTrim(MV_PAR01)

			//oProcess := MsNewProcess():New({|| F4U001(cArquivo)},"Unificação","Validando a Unificação das Condições de Pagamento...",.F.)
			oProcess := MsNewProcess():New({|| F4U001A(cArquivo)},"Unificação","Validando a Unificação das Condições de Pagamento...",.F.)
			oProcess:Activate()

		EndIf

	ElseIf nParte == 2 //PARTE 2 - ATUALIZA AS CONDIÇÕES DE PAGAMENTO

		//ALTERA TODAS AS CODIÇÕES JA LANÇADAS NO SISTEMA
		//ALTERA A E4_CODIGO PARA E4_YREL NOS LANÇAMENTOS
		aAdd(aParamBox, {6,"Arquivo",cArquivo,"",,"",90,.T.,"Arquivos .CSV |*.CSV","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})

		If ParamBox(aParamBox, "Regras de Condição de Pagamento", @aRet)
			cArquivo := AllTrim(MV_PAR01)

			//oProcess := MsNewProcess():New({|| F4U002(cArquivo)},"Unificação","Validando a Unificação das Condições de Pagamento...",.F.)
			oProcess := MsNewProcess():New({|| F4U002A(cArquivo)},"Unificação","Validando a Unificação das Condições de Pagamento...",.F.)
			oProcess:Activate()

		EndIf

	EndIf

Return
Static Function F4U001(cArquivo)

	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local cGetDeli	:= ";" //delimitador
	Local i,nClone
	Local aArea		:= GetArea()
	Local aCondNew	:= {}
	Local nCont
	Local aClone

	If File(cArquivo)

		//Lendo o arquivo e reunindo as informaçãoes nos array aCampos/aDados
		FT_FUSE(cArquivo)
		oProcess:SetRegua1(FT_FLASTREC()-1)
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()

			If lPrim
				aCampos := Separa(cLinha,cGetDeli,.T.)
				lPrim := .F.
			Else
				oProcess:IncRegua1("Abrindo Arquivo...")
				aAdd(aDados, Separa(cLinha,cGetDeli,.T.))
			EndIf

			FT_FSKIP()
		EndDo
		FT_FUSE()

		oProcess:SetRegua1(0)
		oProcess:IncRegua1("Processando Dados do Arquivo...")

		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))

		Begin Transaction

			oProcess:SetRegua2(Len(aDados))
			For i := 1 To Len(aDados)

				If Empty(aDados[i,1]) .OR. Empty(aDados[i,2])
					DisarmTransaction()
					MsgStop("Arquivo esta com a Linha: "+cValToChar(i+1)+" Fora dos parametros obrigatórios."+CRLF+;
						"Campos E4_FILIAL e E4_CODIGO são Obrigatórios!"+CRLF+CRLF+;
						"Corrija e tente novamente!")
					Return
				EndIf

				If !Empty(aDados[i,4]) //posição do cod da condição de pagamento na empresa 01
					If SE4->(DbSeek(aDados[i,3]+aDados[i,4])) .AND. !Empty(aDados[i,2])

						RecLock("SE4", .F.)
						SE4->E4_YREL := aDados[i,2]
						SE4->(MsUnLock())

					Endif
				Else

					//preenche array com as condições de pagamento à serem cadastrada posteriormente na filial 01
					If SE4->(DbSeek(aDados[i,1]+aDados[i,2]))
						aAdd(aCondNew, {SE4->E4_FILIAL,SE4->E4_CODIGO})
					Endif

				EndIf

			Next i

			//ALTERA TODAS AS CODIÇÕES JA LANÇADAS NO SISTEMA
			//ALTERA A E4_CODIGO PARA E4_YREL NOS LANÇAMENTOS
			//PROGRAMA SERA EXECUTADO A PARTIR DE OUTRO MENU - PARTE 2

			//Cadastra as condições de pagamento inexistente na SE4 da Filial 01
			If !Empty(aCondNew)

				For i := 1 To Len(aCondNew)

					//carrega array aClone com novo conteudo a ser incluido na filial 01
					aClone := {}
					If SE4->(DbSeek(aCondNew[i,1]+aCondNew[i,2]))
						For nCont := 1 To FCOUNT()
							aAdd(aClone, {/*indice de controle*/"01"+SE4->E4_CODIGO,"SE4->"+Field(nCont),&("SE4->"+Field(nCont))})
						Next nCont
					EndIf

					//cadastra a nova condição de pagamento
					If SE4->(DbSeek(aClone[1,1]))

						MsgAlert("Código da Codição de Pagamento já existe na Filial: "+aClone[1,2]+CRLF+CRLF+;
							"Realize o Ajuste no arquivo e refaça a Operação.")
						DisarmTransaction()

						Return
					Else

						RecLock("SE4", .T.)
						For nClone := 1 To Len(aClone)
							If AllTrim(aClone[nClone,2]) == "SE4->E4_FILIAL"
								&(aClone[nClone,2]) := "01"
							Else
								&(aClone[nClone,2]) := aClone[nClone,3]
							EndIf
						Next nClone
						SE4->(MsUnLock())

					EndIf

				Next i

			EndIf

		End Transaction

	Else
		MsgStop("O Arquivo "+cArquivo+" não foi encontrado!")
		Return
	EndIf

	RestArea(aArea)

Return
Static Function F4U002(cArquivo)

	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local cGetDeli	:= ";" //delimitador
	Local i
	Local aArea		:= GetArea()
	Local cAliasSql
	Local cSql
	Local nStatus
	Local cUpdate
	Local nQtdReg	:= 0
	Local cPasta
	Local lCreatDir	:= .F.
	Local nHandle
	Local cCampoFil

	If File(cArquivo)

		//Lendo o arquivo e reunindo as informaçãoes nos array aCampos/aDados
		FT_FUSE(cArquivo)
		oProcess:SetRegua1(FT_FLASTREC()-1)
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()

			If lPrim
				aCampos := Separa(cLinha,cGetDeli,.T.)
				lPrim := .F.
			Else
				oProcess:IncRegua1("Abrindo Arquivo...")
				aAdd(aDados, Separa(cLinha,cGetDeli,.T.))
			EndIf

			FT_FSKIP()
		EndDo
		FT_FUSE()

		cAliasSql := GetNextAlias()
		cSql := "SELECT SE4.E4_FILIAL, SE4.E4_CODIGO, SE4.E4_YREL "+CRLF
		cSql += "FROM "+RetSqlName("SE4")+" SE4 "+CRLF
		cSql += "WHERE "+CRLF
		cSql += "      SE4.E4_FILIAL  =  '01'        AND "+CRLF
		cSql += "      SE4.E4_YREL    != ''          AND "+CRLF
		cSql += "      SE4.E4_CODIGO  != SE4.E4_YREL AND "+CRLF
		cSql += "      SE4.D_E_L_E_T_ = ''"+CRLF
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

		Count To nQtdReg

		(cAliasSql)->(DbGoTop())

		oProcess:SetRegua1(nQtdReg)
		If !(cAliasSql)->(Eof())

			cPasta := "\resultF4U002"
			If !ExistDir(cPasta)
				If MakeDir(cPasta) == 0
					lCreatDir := .T.
				EndIf
			Else
				lCreatDir := .T.
			EndIf
			nHandle := FCreate(cPasta+"\F4U002.txt")
			If nHandle == -1
				lCreatDir := .F.
			EndIf

			While !(cAliasSql)->(Eof())

				oProcess:IncRegua1("Processando Dados do Arquivo...")

				oProcess:SetRegua2(Len(aDados))

				For i := 1 To Len(aDados)

					oProcess:IncRegua2("Processando Dados do Arquivo...")

					cUpdate := "BEGIN TRANSACTION "+CRLF
					cCampoFil := Separa(aDados[i,2],"_")[1]+"_FILIAL"
					cUpdate += "UPDATE "+RetSqlName(aDados[i,1])+" SET "+aDados[i,2]+" = '"+(cAliasSql)->E4_YREL+"' WHERE "+cCampoFil+" = '"+xFilial(aDados[i,1])+"' AND "+aDados[i,2]+" = '"+(cAliasSql)->E4_CODIGO+"' AND D_E_L_E_T_ = '' "+CRLF
					cUpdate += "IF @@ERROR = 0 "+CRLF
					cUpdate += "	COMMIT "+CRLF
					cUpdate += "ELSE "+CRLF
					cUpdate += "	ROLLBACK "//+CRLF
					//cUpdate += "END"
					nStatus := TCSqlExec(cUpdate)

					If (nStatus < 0)
						If lCreatDir
							FWrite(nHandle, CRLF + "-----------------" + CRLF + "Erro ao executar SQL: " + CRLF + cUpdate + "Erro" + CRLF + TCSQLError() + CRLF + "-----------------" + CRLF + CRLF + CRLF)
						EndIf
					Else
						If lCreatDir
							FWrite(nHandle, CRLF + "-----------------" + CRLF + "Update realizado com Sucesso! " + CRLF + cUpdate + "-----------------" + CRLF + CRLF + CRLF)
						EndIf
					EndIf

				Next i

				(cAliasSql)->(DbSkip())
			EndDo

			If lCreatDir
				FClose(nHandle)
			EndIf

		EndIf
		(cAliasSql)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return
Static Function F4U001A(cArquivo)

	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local cGetDeli	:= ";" //delimitador
	Local i,nClone
	Local aArea		:= GetArea()
	Local aCondNew	:= {}
	Local nCont
	Local aClone

	If File(cArquivo)

		//Lendo o arquivo e reunindo as informaçãoes nos array aCampos/aDados
		FT_FUSE(cArquivo)
		oProcess:SetRegua1(FT_FLASTREC()-1)
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()

			If lPrim
				aCampos := Separa(cLinha,cGetDeli,.T.)
				lPrim := .F.
			Else
				oProcess:IncRegua1("Abrindo Arquivo...")
				aAdd(aDados, Separa(cLinha,cGetDeli,.T.))
			EndIf

			FT_FSKIP()
		EndDo
		FT_FUSE()

		oProcess:SetRegua1(0)
		oProcess:IncRegua1("Processando Dados do Arquivo...")

		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))

		Begin Transaction

			oProcess:SetRegua2(Len(aDados))
			For i := 1 To Len(aDados)

				If Empty(aDados[i,1]) .OR. Empty(aDados[i,2])
					DisarmTransaction()
					MsgStop("Arquivo esta com a Linha: "+cValToChar(i+1)+" Fora dos parametros obrigatórios."+CRLF+;
						"Campos E4_FILIAL e E4_CODIGO são Obrigatórios!"+CRLF+CRLF+;
						"Corrija e tente novamente!")
					Return
				EndIf

				If !Empty(aDados[i,1]) 
					If SE4->(DbSeek(aDados[i,1]+aDados[i,2])) .AND. !Empty(aDados[i,3])

						RecLock("SE4", .F.)
						SE4->E4_YREL := aDados[i,3]
						SE4->(MsUnLock())

					Endif
				EndIf

			Next i

		End Transaction

	Else
		MsgStop("O Arquivo "+cArquivo+" não foi encontrado!")
		Return
	EndIf

	RestArea(aArea)

Return
Static Function F4U002A(cArquivo)

	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local cGetDeli	:= ";" //delimitador
	Local i
	Local aArea		:= GetArea()
	Local cAliasSql
	Local cSql
	Local nStatus
	Local cUpdate
	Local nQtdReg	:= 0
	Local cPasta
	Local lCreatDir	:= .F.
	Local nHandle
	Local cCampoFil

	If File(cArquivo)

		//Lendo o arquivo e reunindo as informaçãoes nos array aCampos/aDados
		FT_FUSE(cArquivo)
		oProcess:SetRegua1(FT_FLASTREC()-1)
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()

			If lPrim
				aCampos := Separa(cLinha,cGetDeli,.T.)
				lPrim := .F.
			Else
				oProcess:IncRegua1("Abrindo Arquivo...")
				aAdd(aDados, Separa(cLinha,cGetDeli,.T.))
			EndIf

			FT_FSKIP()
		EndDo
		FT_FUSE()

		cAliasSql := GetNextAlias()
		cSql := "SELECT SE4.E4_FILIAL, SE4.E4_CODIGO, SE4.E4_YREL " + CRLF
		cSql += "FROM "+RetSqlName("SE4")+" SE4 " + CRLF
		cSql += "WHERE " + CRLF
		cSql += "      SE4.E4_YREL   != '' AND " + CRLF
		cSql += "      SE4.D_E_L_E_T_ = ''"
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSql,.T.,.F.)

		Count To nQtdReg

		(cAliasSql)->(DbGoTop())

		oProcess:SetRegua1(nQtdReg)
		If !(cAliasSql)->(Eof())

			cPasta := "\resultF4U002"
			If !ExistDir(cPasta)
				If MakeDir(cPasta) == 0
					lCreatDir := .T.
				EndIf
			Else
				lCreatDir := .T.
			EndIf
			nHandle := FCreate(cPasta+"\F4U002.txt")
			If nHandle == -1
				lCreatDir := .F.
			EndIf

			While !(cAliasSql)->(Eof())

				oProcess:IncRegua1("Processando Dados do Arquivo...")

				oProcess:SetRegua2(Len(aDados))

				For i := 1 To Len(aDados)

					oProcess:IncRegua2("Processando Dados do Arquivo...")

					cUpdate := "BEGIN TRANSACTION "+CRLF
					cCampoFil := Separa(aDados[i,2],"_")[1]+"_FILIAL"
					cUpdate += "UPDATE "+RetSqlName(aDados[i,1])+" SET "+aDados[i,2]+" = '"+(cAliasSql)->E4_YREL+"' WHERE "+cCampoFil+" = '"+(cAliasSql)->E4_FILIAL+"' AND "+aDados[i,2]+" = '"+(cAliasSql)->E4_CODIGO+"' AND D_E_L_E_T_ = '' "+CRLF
					cUpdate += "IF @@ERROR = 0 "+CRLF
					cUpdate += "	COMMIT "+CRLF
					cUpdate += "ELSE "+CRLF
					cUpdate += "	ROLLBACK "//+CRLF
					//cUpdate += "END"
					nStatus := TCSqlExec(cUpdate)

					If (nStatus < 0)
						If lCreatDir
							FWrite(nHandle, CRLF + "-----------------" + CRLF + "Erro ao executar SQL: " + CRLF + cUpdate + "Erro" + CRLF + TCSQLError() + CRLF + "-----------------" + CRLF + CRLF + CRLF)
						EndIf
					Else
						If lCreatDir
							FWrite(nHandle, CRLF + "-----------------" + CRLF + "Update realizado com Sucesso! " + CRLF + cUpdate + "-----------------" + CRLF + CRLF + CRLF)
						EndIf
					EndIf

				Next i

				(cAliasSql)->(DbSkip())
			EndDo

			If lCreatDir
				FClose(nHandle)
			EndIf

		EndIf
		(cAliasSql)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return


//=======================================
//ENCERRAMENTO DAS REGRA POSICIONADA	=
//=======================================
User Function FIBEST4E()

	Local cSqlZZ4
	Local cAliasZZ4 := GetNextAlias()
	Local aArea		:= GetArea()

	cSqlZZ4 := "SELECT ZZ4.R_E_C_N_O_ AS RECNOZZ4 "+CRLF
	cSqlZZ4 += "FROM "+RetSqlName("ZZ4")+" ZZ4 "+CRLF
	cSqlZZ4 += "WHERE "+CRLF
	cSqlZZ4 += "      ZZ4.ZZ4_FILIAL = '"+ZZ4->ZZ4_FILIAL+"' 		AND "+CRLF
	cSqlZZ4 += "	  ZZ4.ZZ4_CODVEN = '"+ZZ4->ZZ4_CODVEN+"' 		AND "+CRLF
	cSqlZZ4 += "	  ZZ4.ZZ4_DTINI  = "+ValToSql(ZZ4->ZZ4_DTINI)+" AND "+CRLF
	cSqlZZ4 += "	  ZZ4.ZZ4_DTFIM  = "+ValToSql(ZZ4->ZZ4_DTFIM)+" AND "+CRLF
	cSqlZZ4 += "	  ZZ4.D_E_L_E_T_ = ''"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlZZ4),cAliasZZ4,.T.,.F.)

	(cAliasZZ4)->(DbGoTop())

	If !(cAliasZZ4)->(Eof())
		If MsgYesNo("Deseja Realmente Encerrar essa Regra?")
			While !(cAliasZZ4)->(Eof())

				ZZ4->(DbGoTo((cAliasZZ4)->RECNOZZ4))

				RecLock("ZZ4", .F.)
				ZZ4_DTFIM := dDataBase - 1
				ZZ4->(MsUnLock())

				(cAliasZZ4)->(DbSkip())

				If (cAliasZZ4)->(Eof())
					MsgInfo("Regra Encerrada!")
				EndIf

			EndDo
		EndIf
	EndIf
	(cAliasZZ4)->(DbCloseArea())

	RestArea(aArea)

Return
