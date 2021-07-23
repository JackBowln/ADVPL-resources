#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13) + CHR(10)

/*
DATA:

DESC:

AUTOR:
*/

User Function REL2()

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
	Local cTitle	:= "Grupo de clientes"
	Local cNomeRep	:= FunName()
	Local cPerg     := "REL001" //Não vamos trabalhar com Grupo de Pergunta neste exemplo
	Local oSection

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
	TRCell():New(oSection,"A1_COD" ,cAliasRel ,RetTitle("A1_COD")	,/*Mascara*/	,6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"A1_LOJA"  ,cAliasRel ,RetTitle("A1_LOJA")  ,/*Mascara*/	,6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"A1_NOME"  ,cAliasRel ,RetTitle("A1_NOME")  ,/*Mascara*/	,40,/*lPixel*/,/*{|| code-block de impressao }*/)

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
	TRFunction():New(oSection:Cell("A1_NOME"),Nil,"COUNT",/*oBreak*/,"Quantidade de Clients")

Return oReport


//===================================
//Definição do Scopo de Impressão   =
//===================================
Static Function ReportPrint(oReport)

	Local oSecao1 := oReport:Section(1)

    Pergunte("REL001",.F.)

	//Carregando nossa cAliasRel
	GetDadosImp()

	oSecao1:Cell("A1_COD"):SetBlock({|| (cAliasRel)->A1_COD })
	oSecao1:Cell("A1_LOJA"):SetBlock({|| (cAliasRel)->A1_LOJA })
	oSecao1:Cell("A1_NOME"):SetBlock({|| (cAliasRel)->A1_NOME })

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

	cSql := "SELECT A1_COD, A1_LOJA, A1_NOME " + CRLF
	cSql += "FROM " + RetSqlName("SA1") + " SA1 " + CRLF
	cSql += "WHERE " + CRLF
	cSql += "      SA1.D_E_L_E_T_ = ''"
	cSql := ChangeQuery(cSql)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasRel,.T.,.F.)

Return
