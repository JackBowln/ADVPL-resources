#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


User Function ETIQ002()
	
	Local cSql      := ""
	Local qQuery    := ""	
	Local cPergunte := "ETIQ002"
	
	AtuSx1(cPergunte)

	If Pergunte(cPergunte, .T.)
	
		cSql := "     SELECT * " + CHR(10)
		cSql += "       FROM " + RETSQLNAME("SBE") + " SBE " + CHR(10)
		cSql += "      WHERE SBE.BE_FILIAL  = '" + xFilial("SBE") + "' " + CHR(10)
		cSql += "        AND SBE.BE_LOCAL   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CHR(10) 
		cSql += "        AND SBE.BE_LOCALIZ BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CHR(10) 
		cSql += "        AND SBE.D_E_L_E_T_ = '' " + CHR(10) 
		
		TCQUERY cSQL NEW ALIAS qQUERY
	
		MsAguarde({|| setEtiqueta(qQUERY) },"Impressão de etiqueta...","Aguarde...")
	
		qQUERY->(DbCloseArea())	
		
	EndIf
			
Return Nil


Static Function setEtiqueta(qQUERY)

	Local cCodBar  := ""
	Local cImpress := "" //"PDFCreator"
	Local oFontGN  := Nil
	Local oPrinter := Nil

	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .F.

	MsProcTxt("Iniciando impressão...")

	oFontGN  := TFont():New('Consolas',,20,,.T.,,,,.T.,.F.,.F.)
	oPrinter := FWMSPrinter():New("endereco"+Alltrim(__cUserID)+".etq", IMP_SPOOL, lAdjustToLegacy, "/spool/", lDisableSetup,,, Alltrim(cImpress))
    
    //Define as margens (superior, inferior e laterais) do gráfico.
	oPrinter:SetMargin(005,005,005,005)
		
	While qQUERY->(!(EOF()))

        cCodBar  := AllTrim(qQUERY->BE_LOCAL + qQUERY->BE_LOCALIZ)
        cLocaliz := AllTrim(qQUERY->BE_LOCAL + "-" + qQUERY->BE_LOCALIZ)

		MsProcTxt("Imprimindo etiqueta " + cCodBar + "...")

		oPrinter:StartPage()
    	oPrinter:Say(30, 30, cLocaliz,  oFontGN,,,0)
		oPrinter:Code128B(65, 30, cCodBar, 032)
		oPrinter:EndPage()

		qQUERY->(DbSkip())
		
	EndDo
		
	oPrinter:Preview()

Return Nil

Static Function AtuSx1(cPerg)

	Local aDados := {}
	
	aAdd( aDados, {cPerg,'01','Material De ?',  '','','MV_CH0','C',02,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','NNR','','','','',''} )
	aAdd( aDados, {cPerg,'02','Material Até ?', '','','MV_CH0','C',02,0,0,'G','','MV_PAR02','','','','ZZ','','','','','','','','','','','','','','','','','','','','','NNR','','','','',''} )
	aAdd( aDados, {cPerg,'03','Lote De ?',      '','','MV_CH0','C',15,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','SBE','','','','',''} )
	aAdd( aDados, {cPerg,'04','Lote Ate ?',     '','','MV_CH0','C',15,0,0,'G','','MV_PAR04','','','','ZZZZZZZZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','SBE','','','','',''} )

	U_AtuSx1(aDados)	

Return Nil
