#include 'protheus.ch'
#include 'parmtype.ch'

user function RELAT11()
	
	Local oReport
	Private cAlias := GetNextAlias()

    //Função que retorna objeto de impressão
	oReport := ReportDef()

	//Apresenta a tela para configurar os dados de impressora
	oReport:PrintDialog()
	
return


Static Function ReportDef()
	
	Local cTitle	:= "GRUPO E PRODUTO"
	Local cNomeRep	:= "RELA11"
	Local cPerg     := ''
	Local oReport
	
	Private oSecao1	
	 
	//Classe de impressão
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)
	
    //Define se a pagina de parametros sera impressa
	oReport:lParamPage := .F.

	oReport:SetLineHeight(50) 

	oReport:cFontBody := 'Courier New' 

	oReport:nFontBody := 15 


	//Cria uma seção
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	oSecao1:SetLinesBefore(2)
	
	//TamSX3( "BM_GRUPO" )[1] //Função para pegar o tamanho do campo
	
	//Metodo para informar os campos para o relatorio
	TRCell():New(oSecao1,"BM_GRUPO" 			,(cAlias) ,"Grupo"		,/*Mascara*/	,6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSecao1,"BM_DESC"  			,(cAlias) ,"Desc."			,/*Mascara*/	,TamSX3( "BM_DESC" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)

	//INFORMAÇÕES DOS TOTALIZADORES
    //TRFunction():New(oSecao1:Cell("BM_GRUPO"),NIL,"COUNT")
Return(oReport)


Static Function ReportPrint(oReport)
	
	Local oSecao1 		 := oReport:Section(1)
	
	oSecao1:BeginQuery()
	
	BeginSQL Alias cAlias
				
		SELECT * FROM SBM990 SBM
    
	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()

return


