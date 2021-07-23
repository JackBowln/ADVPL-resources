#include 'protheus.ch'
#include 'parmtype.ch'

user function RELAT12()
	
	Local oReport
	Private cAlias := GetNextAlias()
	
    //Função que retorna objeto de impressão
	oReport:= ReportDef()
    
    //Apresenta a tela para configurar os dados de impressora
	oReport:PrintDialog()
	
return


Static Function ReportDef()
	
	Local cTitle	:= "GRUPO E PRODUTO"
	Local cNomeRep	:= cTitle
	Local cPerg     := 'RELAT12'
	Local oReport
	
	Private oSecao1	
	CriaP12(cPerg)

	//Classe de impressão
	oReport:= TReport():New(cNomeRep,cTitle,cPerg, {|oReport| ReportPrint(oReport)},cTitle)

    //Define se a pagina de parametros sera impressa
	oReport:lParamPage := .F.

	//Cria uma seção
	oSecao1:= TRSection():New(oReport,"",{})
		
	// Pula linha antes de imprimir
	oSecao1:SetLinesBefore(2)

	// Retira todas as bordas da secao 1
	oSecao1:SetBorder("ALL",0,1,.T.)
	
	// Acerta Margens
	oReport:SetLeftMargin(1)
    
	// Papel A4
	oReport:OPAGE:NPAPERSIZE:= 9

	//Define se os totalizadores serão impressos em linha ou coluna
	oSecao1:SetTotalInLine(.F.)
	
    //Metodo para informar os campos para o relatorio
	TRCell():New(oSecao1,"BM_GRUPO" 			,(cAlias) ,"Grupo"		,/*Mascara*/	,TamSX3( "BM_GRUPO" )[1],/*lPixel*/,/*{|| code-block de impressao }*/,	 ,,)
	TRCell():New(oSecao1,"BM_DESC"  			,(cAlias) ,"Descrição"			,/*Mascara*/	,TamSX3( "BM_DESC" )[1],/*lPixel*/,/*{|| code-block de impressao }*/,	 ,,)

	//INFORMAÇÕES DOS TOTALIZADORES
    TRFunction():New(oSecao1:Cell("BM_GRUPO"),NIL,"COUNT")
    
	oSecao1:SetPageBreak(.F.)

Return(oReport)


Static Function ReportPrint(oReport)
	
	Local oSecao1 		 := oReport:Section(1)
	
	oSecao1:BeginQuery()
	BeginSQL Alias cAlias
				
		SELECT * FROM %Table:SBM% SBM
        WHERE SBM.BM_GRUPO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
    
	EndSQL
	
	oSecao1:EndQuery()	
	oSecao1:Print()

return



static Function CriaP12(cPerg)

    Local _sAlias	:= Alias() 
    Local aArea	:= GetArea() 
    Local aRegs	:= {}
    Local nI	:= 0 
    Local nJ	:= 0 
    Local nCampo:= 0 
    Local nX	:= 0

    dbSelectArea("SX1") 
    dbSetOrder(1)

    cPerg := PADR(cPerg,10)

    //   Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt 01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
   // aCampos :=  {"GRUPO","ORDEM","PERGUNT","VARIAVL","TIPO","TAMANHO","DECIMAL","PRESEL","GSC","VAL ID","VAR01","DEF01","CNT01","VAR01","DEF01","CNT01","VAR02","DEF02","CNT02","VAR03","DEF03","CNT03","VAR04","DEF04","CNT04","VAR05","DEF05","CNT05","F3"}

    aAdd(aRegs,{cPerg,"01","Grupo de	","","","MV_PAR01" ,"C",TamSX3("B1_GRUPO")[1],0,0,"G","" ,"MV_PAR01","","","","","","","","","","","","","","","SBM"})
    aAdd(aRegs,{cPerg,"02","Grupo ate	","","","MV_PAR02" ,"C",TamSX3("B1_GRUPO")[1],0,0,"G","" ,"MV_PAR02","","","","","","","","","","","","","","","SBM"})

    dbSelectArea("SX1")
    dbSetOrder(1)
    For nX:=1 to Len(aRegs)
        If DbSeek( cPerg + aRegs[nx][02] )
            If RecLock('SX1',.F.)
                Replace SX1->X1_GRUPO	 With aRegs[nx][01]
                Replace SX1->X1_ORDEM	 With aRegs[nx][02]
                Replace SX1->X1_PERGUNTE With aRegs[nx][03]
                Replace SX1->X1_PERSPA	With aRegs[nx][04]
                Replace SX1->X1_PERENG	With aRegs[nx][05]
                Replace SX1->X1_VARIAVL	With aRegs[nx][06]
                Replace SX1->X1_TIPO	With aRegs[nx][07]
                Replace SX1->X1_TAMANHO	With aRegs[nx][08]
                Replace SX1->X1_DECIMAL	With aRegs[nx][09]
                Replace SX1->X1_PRESEL	With aRegs[nx][10]
                Replace SX1->X1_GSC		With aRegs[nx][11]
                Replace SX1->X1_VALID	With aRegs[nx][12]
                Replace SX1->X1_VAR01	With aRegs[nx][13]
                Replace SX1->X1_DEF01	With aRegs[nx][14]
                Replace SX1->X1_DEF02	With aRegs[nx][17]
                Replace SX1->X1_DEF03	With aRegs[nx][20]
                Replace SX1->X1_DEF04	With aRegs[nx][23]
                Replace SX1->X1_DEF05	With aRegs[nx][26]
                Replace SX1->X1_F3	    With aRegs[nx][28] 
                SX1->(MsUnlock())
            Else
                Help('',1,'REGNOIS')
            EndIf
        Else
            If RecLock('SX1',.T.)
                Replace SX1->X1_GRUPO		With aRegs[nx][01]
                Replace SX1->X1_ORDEM	With aRegs[nx][02]
                Replace SX1->X1_PERGUNTE With aRegs[nx][03]
                Replace SX1->X1_PERSPA	With aRegs[nx][04]
                Replace SX1->X1_PERENG	With aRegs[nx][05]
                Replace SX1->X1_VARIAVL	With aRegs[nx][06]
                Replace SX1->X1_TIPO	With aRegs[nx][07]
                Replace SX1->X1_TAMANHO	With aRegs[nx][08]
                Replace SX1->X1_DECIMAL	With aRegs[nx][09]
                Replace SX1->X1_PRESEL	With aRegs[nx][10]
                Replace SX1->X1_GSC		With aRegs[nx][11]
                Replace SX1->X1_VALID	With aRegs[nx][12]
                Replace SX1->X1_VAR01	With aRegs[nx][13]
                Replace SX1->X1_DEF01	With aRegs[nx][14]
                Replace SX1->X1_DEF02	With aRegs[nx][17]
                Replace SX1->X1_DEF03	With aRegs[nx][20]
                Replace SX1->X1_DEF04	With aRegs[nx][23]
                Replace SX1->X1_DEF05	With aRegs[nx][26]
                Replace SX1->X1_F3	    With aRegs[nx][28]
                SX1->(MsUnlock())
            Else
                Help('',1,'REGNOIS')
            EndIf
        Endif
    Next nX

    dbSelectArea(_sAlias)
    RestArea(aArea)
Return NIL
