#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:

DESC:

AUTOR:
*/

User Function REL001()

	//Função que retorna objeto de impressão
	Local oReport

	Private cAliasRel := GetNextAlias()

	oReport := ReportDef()

	//Apresenta a tela para configurar os dados de impressora
	oReport:PrintDialog()

Return


//===================================
//Definição do Modelo do Relatorio  =
//===================================
Static Function ReportDef()

	Local oReport
	Local cTitle	:= "Grupo de Produtos"
	Local cNomeRep	:= FunName()
	Local cPerg     := "REL001" //Não vamos trabalhar com Grupo de Pergunta neste exemplo
	Local oSection
	Local oBreak

	//Classe de impressão
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)

	//Proproedade da Classe TReport, Define se a pagina de parametros sera impressa
	oReport:lParamPage := .F.

	//Define a altura da linha na impressão
	oReport:SetLineHeight(50)

	//Cria uma seção
	oSection := TRSection():New(oReport,cTitle,/*{"SBM"} cAliasRel */)

	//Celulas ou Colunar que seram exibida no relatorio
	//Célula de impressão pertencente a uma seção oSection(TRSection) de um relatório que utiliza a classe TReport.
	TRCell():New(oSection,"B1_COD" 		,cAliasRel ,RetTitle("B1_COD")   ,/*Mascara*/	 	 , TamSX3("BM_GRUPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"B1_DESC"  	,cAliasRel ,RetTitle("B1_DESC")  ,/*Mascara*/		 , TamSX3("BM_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"BM_GRUPO"  	,cAliasRel ,RetTitle("BM_GRUPO") ,/*Mascara*/		 , TamSX3("BM_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"BM_DESC"  	,cAliasRel ,RetTitle("BM_DESC")  ,/*Mascara*/		 , TamSX3("BM_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"B1_CUSTD"  	,cAliasRel ,RetTitle("B1_CUSTD") ,"@E 999,999,999.99", TamSX3("B1_CUSTD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

	//TRBreak():New( <oParent> , <uBreak> , <uTitle> , <lTotalInLine> , <cName> , <lPageBreak> 
	oBreak := TRBreak():New(oSection,oSection:Cell("BM_GRUPO"),"Total Por Grupo",.F.,Nil)

	//INFORMAÇÕES DOS TOTALIZADORES
	//SUM - Somar
	//COUNT - Contar
	//MAX - Valor máximo
	//MIN - Valor mínimo
	//AVERAGE - Valor médio
	//ONPRINT - Valor atual
	//TIMESUM - Somar horas
	//TIMEAVERAGE - Valor médio de horas
	//TIMESUB - Subtrai horas
	//TRFunction():New( <oCell> , <cName> , <cFunction> , <oBreak> , <cTitle> , <cPicture> , <uFormula> , <lEndSection> , <lEndReport> , <lEndPage> , <oParent> , <bCondition> , <lDisable> , <bCanPrint> )
	TRFunction():New(oSection:Cell("B1_CUSTD"),Nil,"SUM"  ,oBreak    ,"Total Por Grupo"                      ,"@E 999,999,999.99",,.F.,.F.)

	//Final da Pagina
	TRFunction():New(oSection:Cell("B1_COD")  ,Nil,"COUNT"  ,/*oBreak*/,"Quantidade de Produto................","@E 9999"          ,/*uFormula*/,.T.,.F.)
	TRFunction():New(oSection:Cell("B1_CUSTD"),Nil,"SUM"    ,/*oBreak*/,"Total Custo..........................","@E 999,999,999.99",/*uFormula*/,.T.,.F.)

Return oReport


//===================================
//Definição do Scopo de Impressão   =
//===================================
Static Function ReportPrint(oReport)

	Local oSecao1 := oReport:Section(1)

	//Chama Grupo de Perguntas
	//Enfatizando a chamada do grupo
	Pergunte("REL001", .F.)

	//Carregando nossa cAliasRel
	GetDadosImp()

	oSecao1:Cell("B1_COD"):SetBlock(	{|| (cAliasRel)->B1_COD 	})
	oSecao1:Cell("B1_DESC"):SetBlock(	{|| (cAliasRel)->B1_DESC 	})
	oSecao1:Cell("BM_GRUPO"):SetBlock(	{|| (cAliasRel)->BM_GRUPO 	})
	oSecao1:Cell("BM_DESC"):SetBlock(	{|| (cAliasRel)->BM_DESC 	})
	oSecao1:Cell("B1_CUSTD"):SetBlock(	{|| (cAliasRel)->B1_CUSTD 	})

	//Inicia a Impressão da Seção
	oSecao1:Init()

	(cAliasRel)->(DbGoTop())
	While !(cAliasRel)->(Eof())

		oSecao1:PrintLine()

		(cAliasRel)->(DbSkip())
	EndDo
	(cAliasRel)->(DbCloseArea())
	oSecao1:Finish()

Return


//===================================================
//Função de carregamento dos dados á serem exibidos =
//Carregando nossa cAliasRel                        =
//===================================================
Static Function GetDadosImp()

	Local cSql

	cSql := "SELECT SB1.B1_COD, SB1.B1_DESC, SBM.BM_GRUPO, SBM.BM_DESC, SB1.B1_CUSTD " + CRLF
	cSql += "FROM " + RetSqlName("SB1") + " SB1 " + CRLF
	cSql += "JOIN " + RetSqlName("SBM") + " SBM " + CRLF
	cSql += "ON " + CRLF
	cSql += "   SBM.BM_GRUPO   = SB1.B1_GRUPO AND " + CRLF
	cSql += "   SBM.D_E_L_E_T_ = '' " + CRLF
	cSql += "WHERE " + CRLF 
	cSql += "      SB1.B1_COD   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
	cSql += "      SBM.BM_GRUPO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND " + CRLF
	cSql += "      SB1.D_E_L_E_T_ = '' " + CRLF
	cSql += "ORDER BY SBM.BM_GRUPO"
	cSql := ChangeQuery(cSql)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasRel,.T.,.F.)

Return
