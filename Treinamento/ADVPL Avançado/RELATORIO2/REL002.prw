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
