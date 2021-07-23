#include 'protheus.ch'
#include 'parmtype.ch'

user function RELAT21()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
	//Função que retorna objeto de impressão
	oReport:= ReportDef()

    //Apresenta a tela para configurar os dados de impressora
	oReport:PrintDialog()
	
return


Static Function ReportDef()
	
	Local cTitle	:= "GRUPO E PRODUTO"
	Local cNomeRep	:= "RELA21"
	Local cPerg     := ''
	Local oReport
	
	Private oSecao1
	Private oSecao2
	
	
	//Classe de impressão
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)

    //Define se a pagina de parametros sera impressa
	oReport:lParamPage := .F.
	
	//Cria uma seção
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	//oSecao1:SetLinesBefore(2)

	// Retira todas as bordas da secao 1
	//oSecao1:SetBorder("ALL",0,1,.T.)
	
	//Metodo para informar os campos para o relatorio
	TRCell():New(oSecao1,"BM_GRUPO" 			,(cAlias) ,"Grupo"		,/*Mascara*/	,TamSX3( "BM_GRUPO" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSecao1,"BM_DESC"  			,(cAlias) ,"Descrição"			,/*Mascara*/	,TamSX3( "BM_DESC" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)

	//Cria uma seção
	oSecao2:= TRSection():New(oSecao1,"",{})

	// Retira todas as bordas da secao 1
	//oSecao2:SetBorder("ALL",0,1,.T.)

	//Define se os totalizadores serão impressos em linha ou coluna
	//oSecao2:SetTotalInLine(.f.)
	
	//Metodo para informar os campos para o relatorio
	TRCell():New(oSecao2,"B1_COD"  		,(cAlias) ,"Codigo"	     ,/*Mascara*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSecao2,"B1_DESC"		,(cAlias) ,"Descrição"	 ,/*Mascara*/	,30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSecao2,"B1_PRV1"		,(cAlias) ,"Preço"		 ,"@E 99,999,999,999.99"	,TamSX3( "B1_PRV1" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)

	//Define se a seção filha utilizara a query da seção pai 
	//no processamento do método Print
	oSecao2:SetParentQuery()

	//Define a regra de saída do loop de processamento do método 
	//Print das seções filhas
	oSecao2:SetParentFilter({|cParam| (cAlias)->(BM_FILIA) + (cAlias)->(BM_GRUPO)   = cParam }, {||  (cAlias)->(BM_FILIA) + (cAlias)->(BM_GRUPO) })
	
	//INFORMAÇÕES DOS TOTALIZADORES
	//TRFunction():New(oSecao2:Cell("B1_PRV1"),NIL,"SUM")

	//Define se salta a página na quebra de seção
	oSecao1:SetPageBreak(.F.)

Return(oReport)


Static Function ReportPrint(oReport)
	
	Local oSecao1 		 := oReport:Section(1)
	Local oSecao2 		 := oReport:Section(1):Section(1)
	
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
					
		
		SELECT * FROM %Table:SBM% SBM
        INNER JOIN %Table:SB1%  SB1
            ON SBM.BM_GRUPO = SB1.B1_GRUPO 
            AND SB1.D_E_L_E_T_=''
        WHERE 
            SBM.BM_FILIAL = %Exp:xFilial("SBM")%
            AND SBM.D_E_L_E_T_=''
		
	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()

return


